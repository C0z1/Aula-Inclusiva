import XCTest
@testable import MeCuidoCore

final class StepTimerTests: XCTestCase {
    func testResetStartsFullAndUnpaused() {
        let timer = StepTimer()
        timer.isPaused = true
        timer.reset(seconds: 45)
        XCTAssertEqual(timer.total, 45)
        XCTAssertEqual(timer.remaining, 45)
        XCTAssertFalse(timer.isPaused)
        XCTAssertEqual(timer.fraction, 1)
    }

    func testNegativeSecondsAreClampedToZero() {
        let timer = StepTimer()
        timer.reset(seconds: -10)
        XCTAssertEqual(timer.total, 0)
        XCTAssertEqual(timer.fraction, 0)
        XCTAssertFalse(timer.isFinished, "Sin tiempo asignado no se muestra el aviso «Tómate tu tiempo»")
    }

    func testTickCountsDown() {
        let timer = StepTimer()
        timer.reset(seconds: 2)
        timer.tick()
        XCTAssertEqual(timer.remaining, 1)
        XCTAssertEqual(timer.fraction, 0.5)
    }

    func testTickDoesNothingWhilePaused() {
        let timer = StepTimer()
        timer.reset(seconds: 10)
        timer.isPaused = true
        timer.tick()
        XCTAssertEqual(timer.remaining, 10)
    }

    func testNeverGoesBelowZero() {
        let timer = StepTimer()
        timer.reset(seconds: 1)
        timer.tick()
        timer.tick()
        XCTAssertEqual(timer.remaining, 0)
        XCTAssertTrue(timer.isFinished)
    }

    func testMoreTimeAfterFinishingContinues() {
        let timer = StepTimer()
        timer.reset(seconds: 1)
        timer.tick()
        timer.addTime()
        XCTAssertEqual(timer.remaining, StepTimer.extraTime)
        XCTAssertEqual(timer.total, 1 + StepTimer.extraTime)
        XCTAssertFalse(timer.isFinished)
    }

    func testAddTimeIgnoresNonPositiveValues() {
        let timer = StepTimer()
        timer.reset(seconds: 10)
        timer.addTime(0)
        timer.addTime(-5)
        XCTAssertEqual(timer.total, 10)
        XCTAssertEqual(timer.remaining, 10)
    }
}
