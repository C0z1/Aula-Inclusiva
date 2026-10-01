import XCTest
@testable import MeCuidoCore

final class RoutineStoreTests: XCTestCase {
    private var fileURL: URL!

    override func setUp() {
        super.setUp()
        fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("mecuido-tests-\(UUID().uuidString)")
            .appendingPathComponent("rutinas.json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        super.tearDown()
    }

    private func makeStore() -> RoutineStore { RoutineStore(fileURL: fileURL) }

    func testStartsWithBuiltInRoutines() {
        let store = makeStore()
        XCTAssertEqual(store.visibleRoutines.map(\.id), Routine.all.map(\.id))
        XCTAssertTrue(store.customRoutines.isEmpty)
    }

    func testCorruptFileFallsBackToBuiltIns() throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try Data("no es json".utf8).write(to: fileURL)
        XCTAssertEqual(makeStore().visibleRoutines.count, Routine.all.count)
    }

    func testHidingBuiltInPersists() {
        let store = makeStore()
        store.setHidden(true, for: Routine.all[0])
        XCTAssertFalse(store.visibleRoutines.contains { $0.id == Routine.all[0].id })

        let reloaded = makeStore()
        XCTAssertTrue(reloaded.isHidden(Routine.all[0]))
        reloaded.setHidden(false, for: Routine.all[0])
        XCTAssertEqual(makeStore().visibleRoutines.count, Routine.all.count)
    }

    func testCreateEditAndReload() {
        let store = makeStore()
        var routine = store.createRoutine()
        XCTAssertFalse(store.isBuiltIn(routine))
        XCTAssertEqual(routine.steps.count, 1)

        routine.title = "  Prepararme para dormir  "
        routine.steps.append(RoutineStore.makeStep(in: routine.id, number: 2))
        store.save(routine)

        let saved = makeStore().routine(id: routine.id)
        XCTAssertEqual(saved?.title, "Prepararme para dormir")
        XCTAssertEqual(saved?.steps.count, 2)
        XCTAssertTrue(store.visibleRoutines.contains { $0.id == routine.id })
    }

    func testBuiltInsCannotBeEditedOrDeleted() {
        let store = makeStore()
        var builtIn = Routine.all[0]
        builtIn.title = "Cambiada"
        store.save(builtIn)
        store.delete(builtIn)
        XCTAssertEqual(store.routine(id: builtIn.id)?.title, Routine.all[0].title)
    }

    func testDeleteCustomRoutine() {
        let store = makeStore()
        let routine = store.createRoutine()
        store.setHidden(true, for: routine)
        store.delete(routine)
        XCTAssertNil(makeStore().routine(id: routine.id))
        XCTAssertFalse(store.hiddenIDs.contains(routine.id))
    }

    func testDuplicateBuiltInGetsNewUniqueIds() {
        let store = makeStore()
        let copy = store.duplicate(Routine.all[0])
        XCTAssertNotEqual(copy.id, Routine.all[0].id)
        XCTAssertFalse(store.isBuiltIn(copy))
        XCTAssertEqual(copy.steps.map(\.title), Routine.all[0].steps.map(\.title))

        let allStepIDs = store.allRoutines.flatMap { $0.steps.map(\.id) }
        XCTAssertEqual(allStepIDs.count, Set(allStepIDs).count, "Ningún paso puede compartir id")
        XCTAssertTrue(copy.steps.allSatisfy { $0.id.hasPrefix(copy.id + ".") })
    }

    func testRoutineWithoutStepsIsNotShownToChild() {
        let store = makeStore()
        var routine = store.createRoutine()
        routine.steps = []
        store.save(routine)
        XCTAssertFalse(store.visibleRoutines.contains { $0.id == routine.id })
        XCTAssertTrue(store.allRoutines.contains { $0.id == routine.id })
    }

    func testNormalizationLimitsStepsAndFixesValues() {
        var routine = Routine(id: "custom-x", title: "   ", symbol: "star", category: .cuidarme, steps: [])
        for number in 1...7 {
            var step = RoutineStore.makeStep(in: routine.id, number: number)
            step.title = number == 1 ? "  " : step.title
            step.suggestedSeconds = number == 2 ? 0 : 10_000
            routine.steps.append(step)
        }
        let normalized = RoutineStore.normalized(routine)
        XCTAssertEqual(normalized.title, "Mi rutina")
        XCTAssertEqual(normalized.steps.count, RoutineStore.maxSteps)
        XCTAssertEqual(normalized.steps[0].title, "Paso 1")
        XCTAssertEqual(normalized.steps[1].suggestedSeconds, RoutineStore.secondsRange.lowerBound)
        XCTAssertEqual(normalized.steps[2].suggestedSeconds, RoutineStore.secondsRange.upperBound)
    }

    func testExportImportRoundTrip() throws {
        let source = makeStore()
        var routine = source.createRoutine()
        routine.title = "Ir a natación"
        source.save(routine)
        source.setHidden(true, for: Routine.all[2])
        let data = try source.exportData()

        let otherURL = fileURL.deletingLastPathComponent().appendingPathComponent("otro.json")
        let target = RoutineStore(fileURL: otherURL)
        XCTAssertEqual(try target.importData(data), 1)
        XCTAssertEqual(target.routine(id: routine.id)?.title, "Ir a natación")
        XCTAssertTrue(target.isHidden(Routine.all[2]))

        // Importar dos veces no duplica.
        try target.importData(data)
        XCTAssertEqual(target.customRoutines.count, 1)
    }

    func testImportRejectsGarbageAndNewerVersions() throws {
        let store = makeStore()
        XCTAssertThrowsError(try store.importData(Data("{}".utf8))) {
            XCTAssertEqual($0 as? RoutineStore.ImportError, .unreadable)
        }
        var future = RoutineStore.Snapshot(customRoutines: [], hiddenIDs: [])
        future.version = RoutineStore.Snapshot.currentVersion + 1
        XCTAssertThrowsError(try store.importData(JSONEncoder().encode(future))) {
            XCTAssertEqual($0 as? RoutineStore.ImportError, .newerVersion)
        }
    }

    func testImportNeverOverridesBuiltIns() throws {
        var tampered = Routine.all[0]
        tampered.title = "Hackeada"
        let backup = RoutineStore.Snapshot(customRoutines: [tampered], hiddenIDs: ["no-existe"])
        let store = makeStore()
        XCTAssertEqual(try store.importData(JSONEncoder().encode(backup)), 0)
        XCTAssertEqual(store.routine(id: tampered.id)?.title, Routine.all[0].title)
        XCTAssertTrue(store.hiddenIDs.isEmpty)
    }
}

final class AdultGateTests: XCTestCase {
    func testAnswerChecking() {
        let gate = AdultGate(left: 17, right: 6)
        XCTAssertTrue(gate.isCorrect("102"))
        XCTAssertTrue(gate.isCorrect(" 102 "))
        XCTAssertFalse(gate.isCorrect("103"))
        XCTAssertFalse(gate.isCorrect(""))
    }

    func testRandomQuestionsStayInRange() {
        var generator = SystemRandomNumberGenerator()
        for _ in 0..<200 {
            let gate = AdultGate.random(using: &generator)
            XCTAssertTrue((12...29).contains(gate.left))
            XCTAssertTrue((3...9).contains(gate.right))
            XCTAssertLessThanOrEqual(String(gate.answer).count, AdultGate.maxDigits)
        }
    }
}
