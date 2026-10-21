import XCTest
@testable import MeCuidoCore

/// Generador con semilla para que las pruebas sean repetibles.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

final class SequenceGameTests: XCTestCase {
    private func steps(_ count: Int) -> [RoutineStep] {
        (1...count).map {
            RoutineStep(id: "r.\($0)", title: "Paso \($0)", instruction: "", symbol: "star.fill", suggestedSeconds: 30)
        }
    }

    func testNoGameWithLessThanTwoSteps() {
        var generator = SeededGenerator(state: 1)
        XCTAssertNil(SequenceGame(steps: [], using: &generator))
        XCTAssertNil(SequenceGame(steps: steps(1), using: &generator))
        XCTAssertNil(GameKind.warmUp(for: Routine(id: "x", title: "X", symbol: "star.fill",
                                                   category: .cuidarme, steps: steps(1))))
        XCTAssertEqual(GameKind.warmUp(for: Routine.all[0]), .sequence)
    }

    func testCardsAreNeverAlreadyInOrder() throws {
        for count in 2...5 {
            for seed in 0..<200 {
                var generator = SeededGenerator(state: UInt64(seed))
                let game = try XCTUnwrap(SequenceGame(steps: steps(count), using: &generator))
                XCTAssertNotEqual(game.cards.map(\.id), game.steps.map(\.id), "\(count) pasos, semilla \(seed)")
                XCTAssertEqual(Set(game.cards.map(\.id)), Set(game.steps.map(\.id)), "Mismas cartas, otro orden")
            }
        }
    }

    func testPlayingInOrderFinishes() throws {
        var generator = SeededGenerator(state: 7)
        var game = try XCTUnwrap(SequenceGame(steps: steps(3), using: &generator))
        XCTAssertEqual(game.currentSlot, 1)
        XCTAssertEqual(game.tap("r.1"), .placed)
        XCTAssertTrue(game.isPlaced("r.1"))
        XCTAssertEqual(game.currentSlot, 2)
        XCTAssertEqual(game.tap("r.2"), .placed)
        XCTAssertEqual(game.tap("r.3"), .finished)
        XCTAssertTrue(game.isFinished)
        XCTAssertNil(game.nextStep)
        XCTAssertEqual(game.currentSlot, 3, "Nunca pasa del número de pasos")
        XCTAssertEqual(game.tap("r.1"), .ignored, "Terminado: los toques no hacen nada")
    }

    func testWrongTapGivesHintThenHighlightsWithoutBlocking() throws {
        var generator = SeededGenerator(state: 3)
        var game = try XCTUnwrap(SequenceGame(steps: steps(3), using: &generator))
        XCTAssertEqual(game.tap("r.3"), .hint)
        XCTAssertFalse(game.isHighlighted("r.1"), "La primera pista no dice la respuesta")
        XCTAssertEqual(game.tap("r.2"), .hint)
        XCTAssertTrue(game.isHighlighted("r.1"), "A la segunda se resalta la correcta")
        XCTAssertFalse(game.isHighlighted("r.2"))
        XCTAssertEqual(game.tap("r.1"), .placed)
        XCTAssertFalse(game.isHighlighted("r.2"), "Las pistas empiezan de nuevo en la siguiente casilla")
        XCTAssertEqual(game.hintsForCurrent, 0)
    }

    func testTappingAPlacedCardDoesNothing() throws {
        var generator = SeededGenerator(state: 5)
        var game = try XCTUnwrap(SequenceGame(steps: steps(2), using: &generator))
        game.tap("r.1")
        XCTAssertEqual(game.tap("r.1"), .ignored)
        XCTAssertEqual(game.hintsForCurrent, 0, "Repetir una carta colocada no cuenta como pista")
        XCTAssertEqual(game.tap("desconocido"), .hint)
    }

    func testSummaryReadsTheSequence() {
        XCTAssertEqual(GameLines.summary([]), "")
        XCTAssertEqual(GameLines.summary(["A"]), "Primero, A.")
        XCTAssertEqual(GameLines.summary(["A", "B"]), "Primero, A, y después, B.")
        XCTAssertEqual(GameLines.summary(["A", "B", "C"]), "Primero, A; luego, B; y al final, C.")
        XCTAssertEqual(GameLines.summary(["A", "B", "C", "D"]), "Primero, A; luego, B; luego, C; y al final, D.")
    }

    func testGameLinesAreNeverNegative() {
        let lines = [GameLines.sequenceIntro, GameLines.sequenceHint(slot: 1), GameLines.sequenceHint(slot: 2),
                     GameLines.sequenceReveal(title: "X"), GameLines.sequenceFinished(titles: ["X", "Y"])]
        for line in lines {
            for word in ["mal", "incorrect", "perdiste", "error", "equivoca"] {
                XCTAssertFalse(line.lowercased().contains(word), "«\(line)» contiene «\(word)»")
            }
        }
    }
}

final class GameProgressTests: XCTestCase {
    func testGamesPlayedOnlyGoesUpAndPersists() {
        let defaults = makeTestDefaults()
        let progress = ProgressStore(defaults: defaults)
        XCTAssertEqual(progress.gamesPlayed, 0)
        progress.finishGame()
        progress.finishGame()
        XCTAssertEqual(ProgressStore(defaults: defaults).gamesPlayed, 2)
        XCTAssertEqual(progress.medals, 0, "Los juegos no dan medallas")
    }

    func testCuriousMindStickerAtFiveGames() {
        let progress = ProgressStore(defaults: makeTestDefaults())
        for _ in 0..<4 { progress.finishGame() }
        XCTAssertFalse(progress.earnedAchievementIDs(for: Routine.all).contains("juegos.5"))
        progress.finishGame()
        XCTAssertTrue(progress.earnedAchievementIDs(for: Routine.all).contains("juegos.5"))
    }

    func testMiniGamesOnByDefaultAndPersist() {
        let defaults = makeTestDefaults()
        XCTAssertTrue(SettingsStore(defaults: defaults).miniGames)
        SettingsStore(defaults: defaults).miniGames = false
        XCTAssertFalse(SettingsStore(defaults: defaults).miniGames)
    }
}
