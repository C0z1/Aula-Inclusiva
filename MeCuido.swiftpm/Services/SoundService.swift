import AVFoundation

/// Sonidos suaves de logro, generados en el momento (no requiere archivos de audio).
/// Solo hay sonidos alegres: nunca de error, alarma ni tiempo agotado.
final class SoundService {
    static let shared = SoundService()

    enum Cue {
        /// Al presionar «¡Hecho!» en un paso.
        case stepDone
        /// Al terminar toda la rutina.
        case routineDone

        /// Frecuencias en Hz de cada nota, en orden.
        var notes: [Double] {
            switch self {
            case .stepDone: [659.25, 880.00]                    // Mi → La
            case .routineDone: [523.25, 659.25, 783.99, 1046.50] // Do mayor ascendente
            }
        }
    }

    private var sounds: [Cue: Data] = [:]
    /// Se conserva mientras suena; uno nuevo interrumpe al anterior.
    private var player: AVAudioPlayer?

    private init() {
        AudioSession.configure()
    }

    func play(_ cue: Cue) {
        // AVAudioPlayer solo lanza errores de Swift. AVAudioEngine podía cerrar la app con una
        // excepción de Objective-C si el audio no estaba listo (llamada, audífonos, segundo plano).
        let sound = sounds[cue] ?? Chime.wav(notes: cue.notes)
        sounds[cue] = sound
        player?.stop()
        player = try? AVAudioPlayer(data: sound)
        // Sin sonido no pasa nada: la vibración y la animación siguen confirmando el logro.
        player?.play()
    }
}

extension SettingsStore {
    /// Reproduce el sonido solo si el adulto dejó encendidos los «Sonidos de logro».
    func play(_ cue: SoundService.Cue) {
        if soundEffects { SoundService.shared.play(cue) }
    }
}
