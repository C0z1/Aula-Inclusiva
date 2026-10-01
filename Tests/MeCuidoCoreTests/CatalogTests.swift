import XCTest
@testable import MeCuidoCore

/// Reglas del catálogo incluido (ver CLAUDE.md). Los ids no deben cambiar: el progreso guardado depende de ellos.
final class CatalogTests: XCTestCase {
    func testBuiltInRoutineIdsAreStable() {
        XCTAssertEqual(Routine.all.map(\.id), ["agujetas", "mochila", "cama", "manos", "herida"])
    }

    func testEachBuiltInRoutineHasThreeWellFormedSteps() {
        for routine in Routine.all {
            XCTAssertEqual(routine.steps.count, 3, routine.id)
            for (index, step) in routine.steps.enumerated() {
                XCTAssertEqual(step.id, "\(routine.id).\(index + 1)")
                XCTAssertGreaterThan(step.suggestedSeconds, 0, step.id)
                XCTAssertFalse(step.instruction.isEmpty, step.id)
            }
        }
    }

    func testStepIdsAreUnique() {
        let ids = Routine.all.flatMap { $0.steps.map(\.id) }
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testAccessoriesUnlockInIncreasingOrder() {
        let thresholds = Accessory.all.map(\.medalsRequired)
        XCTAssertEqual(thresholds, thresholds.sorted())
        XCTAssertEqual(Set(Accessory.all.map(\.id)).count, Accessory.all.count)
        XCTAssertEqual(thresholds.first, 1, "La primera recompensa debe llegar con la primera rutina")
    }
}
