import Foundation

/// Campanita de logro como archivo WAV en memoria (PCM de 16 bits, mono): notas escalonadas con
/// ataque corto y caída suave. Vive en Models para poder probarla sin AVFoundation.
enum Chime {
    static let sampleRate = 44_100

    static func wav(notes: [Double]) -> Data {
        let noteSpacing = 0.14
        let tail = 0.45
        let duration = noteSpacing * Double(max(notes.count - 1, 0)) + tail
        let frameCount = Int(duration * Double(sampleRate))

        var samples = Data(capacity: frameCount * 2)
        for frame in 0..<frameCount {
            let time = Double(frame) / Double(sampleRate)
            var value = 0.0
            for (index, frequency) in notes.enumerated() {
                let local = time - Double(index) * noteSpacing
                guard local >= 0 else { continue }
                let attack = min(local / 0.01, 1)
                let decay = exp(-local * 8)
                value += sin(2 * .pi * frequency * local) * attack * decay
            }
            // Volumen bajo: acompaña, no sobresalta.
            let sample = Int16(max(-1, min(1, value * 0.15)) * Double(Int16.max))
            withUnsafeBytes(of: sample.littleEndian) { samples.append(contentsOf: $0) }
        }

        var wav = Data()
        func append<T: FixedWidthInteger>(_ value: T) {
            withUnsafeBytes(of: value.littleEndian) { wav.append(contentsOf: $0) }
        }
        wav.append(contentsOf: Array("RIFF".utf8))
        append(UInt32(36 + samples.count))
        wav.append(contentsOf: Array("WAVEfmt ".utf8))
        append(UInt32(16))              // tamaño del bloque fmt
        append(UInt16(1))               // PCM
        append(UInt16(1))               // mono
        append(UInt32(sampleRate))
        append(UInt32(sampleRate * 2))  // bytes por segundo
        append(UInt16(2))               // bytes por muestra
        append(UInt16(16))              // bits por muestra
        wav.append(contentsOf: Array("data".utf8))
        append(UInt32(samples.count))
        wav.append(samples)
        return wav
    }
}
