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

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private var buffers: [Cue: AVAudioPCMBuffer] = [:]

    private init() {
        AudioSession.configure()
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    func play(_ cue: Cue) {
        guard let buffer = buffer(for: cue) else { return }
        do {
            if !engine.isRunning { try engine.start() }
            player.scheduleBuffer(buffer, at: nil, options: .interrupts)
            player.play()
        } catch {
            // Sin sonido no pasa nada: la vibración y la animación siguen confirmando el logro.
        }
    }

    private func buffer(for cue: Cue) -> AVAudioPCMBuffer? {
        if let cached = buffers[cue] { return cached }
        let buffer = makeChime(cue.notes)
        buffers[cue] = buffer
        return buffer
    }

    /// Campanita: notas escalonadas con ataque corto y caída suave.
    private func makeChime(_ notes: [Double]) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let noteSpacing = 0.14
        let tail = 0.45
        let duration = noteSpacing * Double(max(notes.count - 1, 0)) + tail
        let frameCount = AVAudioFrameCount(duration * sampleRate)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let samples = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = frameCount

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            var value = 0.0
            for (index, frequency) in notes.enumerated() {
                let local = time - Double(index) * noteSpacing
                guard local >= 0 else { continue }
                let attack = min(local / 0.01, 1)
                let decay = exp(-local * 8)
                value += sin(2 * .pi * frequency * local) * attack * decay
            }
            samples[frame] = Float(value * 0.15) // Volumen bajo: acompaña, no sobresalta.
        }
        return buffer
    }
}
