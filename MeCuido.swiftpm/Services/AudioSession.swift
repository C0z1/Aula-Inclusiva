import AVFoundation

/// Configura una sola vez la sesión de audio compartida por la voz y los sonidos.
enum AudioSession {
    private static let setup: Void = {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }()

    static func configure() {
        _ = setup
    }
}
