import AVFoundation

/// Configura la sesión de audio compartida por la voz, los sonidos y la grabación.
enum AudioSession {
    private static let setup: Void = {
        usePlayback()
    }()

    /// Una sola vez al arrancar: reproducción hablada que baja el volumen de otras apps.
    static func configure() {
        _ = setup
    }

    /// Mientras un adulto graba una instrucción.
    static func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try? session.setActive(true)
    }

    /// Al terminar de grabar, regresa a la configuración de reproducción.
    static func endRecording() {
        usePlayback()
    }

    private static func usePlayback() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }
}
