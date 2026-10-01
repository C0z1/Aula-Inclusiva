import AVFoundation
import UIKit

/// Narra las instrucciones: con la voz grabada por un familiar si existe, o con la voz
/// del sistema (la elegida en Ajustes, o español de México).
/// Si VoiceOver está activo, le pasa el texto como anuncio para que no hablen dos voces a la vez.
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?

    private init() {
        AudioSession.configure()
    }

    /// Lee un texto con la voz del sistema.
    /// - Parameters:
    ///   - slow: voz más lenta (ajuste para adultos).
    ///   - voiceIdentifier: voz elegida en Ajustes; nil = automática.
    func speak(_ text: String, slow: Bool = false, voiceIdentifier: String? = nil) {
        stop()
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: text)
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.voice(identifier: voiceIdentifier)
        // Siempre un poco más lento que lo normal para facilitar la comprensión.
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * (slow ? 0.75 : 0.9)
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance)
    }

    /// Reproduce la grabación si hay una; si no, lee el texto.
    func narrate(_ text: String, recording: URL?, slow: Bool = false, voiceIdentifier: String? = nil) {
        guard let recording, !UIAccessibility.isVoiceOverRunning else {
            speak(text, slow: slow, voiceIdentifier: voiceIdentifier)
            return
        }
        stop()
        do {
            let player = try AVAudioPlayer(contentsOf: recording)
            self.player = player
            player.play()
        } catch {
            speak(text, slow: slow, voiceIdentifier: voiceIdentifier)
        }
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        player?.stop()
        player = nil
    }

    /// Voces en español instaladas, primero las de México y las de mejor calidad.
    static var spanishVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("es") }
            .sorted { lhs, rhs in
                let lhsMX = lhs.language == "es-MX", rhsMX = rhs.language == "es-MX"
                if lhsMX != rhsMX { return lhsMX }
                if lhs.quality != rhs.quality { return lhs.quality.rawValue > rhs.quality.rawValue }
                return lhs.name < rhs.name
            }
    }

    private static func voice(identifier: String?) -> AVSpeechSynthesisVoice? {
        identifier.flatMap(AVSpeechSynthesisVoice.init(identifier:))
            ?? AVSpeechSynthesisVoice(language: "es-MX")
            ?? AVSpeechSynthesisVoice(language: "es-ES")
    }
}

extension SettingsStore {
    /// Lee un texto con la voz y la velocidad elegidas por el adulto.
    func speak(_ text: String) {
        SpeechService.shared.speak(text, slow: slowSpeech, voiceIdentifier: voiceIdentifier)
    }

    /// Reproduce la voz grabada del paso o, si no hay, lee el texto.
    func narrate(_ text: String, recording: URL?) {
        SpeechService.shared.narrate(text, recording: recording, slow: slowSpeech, voiceIdentifier: voiceIdentifier)
    }
}
