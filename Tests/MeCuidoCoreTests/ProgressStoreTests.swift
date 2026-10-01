import XCTest
@testable import MeCuidoCore

final class ProgressStoreTests: XCTestCase {
    private let routine = Routine.all[0]

    func testCompletingStepsAdvancesToNextPending() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        XCTAssertEqual(progress.nextPendingIndex(in: routine), 0)

        progress.complete(routine.steps[0])
        XCTAssertEqual(progress.nextPendingIndex(in: routine), 1)
        XCTAssertEqual(progress.completedCount(in: routine), 1)
        XCTAssertEqual(progress.progress(of: routine), 1.0 / 3.0, accuracy: 0.0001)
    }

    func testOutOfOrderStepsStillFindEarliestPending() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        progress.complete(routine.steps[1])
        XCTAssertEqual(progress.nextPendingIndex(in: routine), 0)
        progress.complete(routine.steps[0])
        progress.complete(routine.steps[2])
        XCTAssertNil(progress.nextPendingIndex(in: routine))
    }

    func testFinishAwardsMedalAndResetsRoutine() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        routine.steps.forEach(progress.complete)
        progress.finish(routine)

        XCTAssertEqual(progress.medals, 1)
        XCTAssertEqual(progress.completedCount(in: routine), 0)
        XCTAssertTrue(progress.isDoneToday(routine))
    }

    func testFinishReturnsOnlyNewlyUnlockedAccessory() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        XCTAssertEqual(progress.finish(routine)?.id, "estrella") // 1 medalla
        XCTAssertNil(progress.finish(routine))                    // 2 medallas
        XCTAssertEqual(progress.finish(routine)?.id, "gorra")     // 3 medallas
    }

    func testDoneTodayResetsOnNextDay() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Mexico_City")!
        let lateNight = calendar.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 23, minute: 50))!
        let nextMorning = calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 7))!

        progress.finish(routine, at: lateNight)
        XCTAssertTrue(progress.isDoneToday(routine, now: lateNight, calendar: calendar))
        XCTAssertFalse(progress.isDoneToday(routine, now: nextMorning, calendar: calendar))
    }

    func testCannotWearLockedAccessory() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        progress.equip(Accessory.all.last)
        XCTAssertNil(progress.equippedAccessory)
    }

    func testProgressPersistsAcrossLaunches() {
        let defaults = makeTestDefaults()
        let progress = ProgressStore(defaults: defaults)
        progress.finish(routine)
        progress.equip(Accessory.all[0])
        progress.complete(Routine.all[1].steps[0])

        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.medals, 1)
        XCTAssertEqual(reloaded.equippedAccessory?.id, "estrella")
        XCTAssertTrue(reloaded.isCompleted(Routine.all[1].steps[0]))
        XCTAssertTrue(reloaded.isDoneToday(routine))
    }
}
