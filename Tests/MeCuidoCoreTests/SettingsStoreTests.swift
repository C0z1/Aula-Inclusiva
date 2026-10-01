import XCTest
@testable import MeCuidoCore

final class SettingsStoreTests: XCTestCase {
    private let step = RoutineStep(id: "prueba.1", title: "Paso", instruction: "Haz algo.",
                                   symbol: "star", suggestedSeconds: 30)

    func testDefaults() {
        let settings = SettingsStore(defaults: makeTestDefaults())
        XCTAssertEqual(settings.pace, .normal)
        XCTAssertTrue(settings.autoNarration)
        XCTAssertFalse(settings.slowSpeech)
        XCTAssertTrue(settings.soundEffects)
        XCTAssertNil(settings.voiceIdentifier)
    }

    func testSecondsFollowPace() {
        let settings = SettingsStore(defaults: makeTestDefaults())
        XCTAssertEqual(settings.seconds(for: step), 30)
        settings.pace = .calm
        XCTAssertEqual(settings.seconds(for: step), 45)
        settings.pace = .extraCalm
        XCTAssertEqual(settings.seconds(for: step), 60)
    }

    func testPaceNeverShortensTime() {
        for pace in SettingsStore.Pace.allCases {
            XCTAssertGreaterThanOrEqual(pace.multiplier, 1, "Ningún ritmo debe presionar más que el normal")
        }
    }

    func testSettingsPersist() {
        let defaults = makeTestDefaults()
        let settings = SettingsStore(defaults: defaults)
        settings.pace = .extraCalm
        settings.autoNarration = false
        settings.slowSpeech = true
        settings.soundEffects = false
        settings.voiceIdentifier = "com.apple.voice.compact.es-MX.Paulina"

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertEqual(reloaded.voiceIdentifier, "com.apple.voice.compact.es-MX.Paulina")
        reloaded.voiceIdentifier = nil
        XCTAssertNil(SettingsStore(defaults: defaults).voiceIdentifier, "Volver a la voz automática")
        XCTAssertEqual(reloaded.pace, .extraCalm)
        XCTAssertFalse(reloaded.autoNarration)
        XCTAssertTrue(reloaded.slowSpeech)
        XCTAssertFalse(reloaded.soundEffects)
    }
}
