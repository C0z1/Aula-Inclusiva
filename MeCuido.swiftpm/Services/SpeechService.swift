import AVFoundation
import UIKit

/// Narra las instrucciones en voz alta (español de México).
/// Si VoiceOver está activo, le pasa el texto como anuncio para que no hablen dos voces a la vez.
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        AudioSession.configure()
    }

    /// - Parameter slow: voz más lenta (ajuste para adultos).
    func speak(_ text: String, slow: Bool = false) {
        stop()
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: text)
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") ?? AVSpeechSynthesisVoice(language: "es-ES")
        // Siempre un poco más lento que lo normal para facilitar la comprensión.
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * (slow ? 0.75 : 0.9)
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
