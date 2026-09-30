import AVFoundation

/// Narra las instrucciones en voz alta (español de México).
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }

    /// - Parameter slow: voz más lenta (ajuste para adultos).
    func speak(_ text: String, slow: Bool = false) {
        stop()
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
