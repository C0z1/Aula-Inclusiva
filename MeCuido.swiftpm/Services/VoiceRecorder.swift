import AVFoundation
import Observation

/// Graba la voz de un familiar o maestra leyendo un paso (máximo 20 segundos).
/// Al terminar (a mano o por tiempo) sube `finishedCount`; la grabación queda en `recordingURL`.
@Observable
final class VoiceRecorder {
    static let maxSeconds: TimeInterval = 20

    private(set) var isRecording = false
    private(set) var elapsed: TimeInterval = 0
    /// Cambia cada vez que termina una grabación válida.
    private(set) var finishedCount = 0

    let recordingURL = FileManager.default.temporaryDirectory.appendingPathComponent("mecuido-grabacion.m4a")

    private var recorder: AVAudioRecorder?
    private var ticker: Task<Void, Never>?

    static func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    @MainActor
    func start() -> Bool {
        stopIfNeeded()
        AudioSession.beginRecording()
        try? FileManager.default.removeItem(at: recordingURL)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        guard let recorder = try? AVAudioRecorder(url: recordingURL, settings: settings),
              recorder.record(forDuration: Self.maxSeconds) else {
            AudioSession.endRecording()
            return false
        }
        self.recorder = recorder
        isRecording = true
        elapsed = 0

        ticker = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(200))
                guard let self, let recorder = self.recorder else { return }
                if recorder.isRecording {
                    self.elapsed = recorder.currentTime
                } else {
                    // Llegó al máximo de tiempo.
                    self.finish()
                    return
                }
            }
        }
        return true
    }

    @MainActor
    func stop() {
        recorder?.stop()
        finish()
    }

    /// Descarta una grabación en curso (p. ej. al salir de la pantalla).
    @MainActor
    func cancel() {
        recorder?.stop()
        recorder?.deleteRecording()
        stopIfNeeded()
    }

    @MainActor
    private func finish() {
        let wasRecording = isRecording
        stopIfNeeded()
        // Menos de medio segundo suele ser un toque accidental.
        if wasRecording, elapsed >= 0.5, FileManager.default.fileExists(atPath: recordingURL.path) {
            finishedCount += 1
        }
    }

    @MainActor
    private func stopIfNeeded() {
        ticker?.cancel()
        ticker = nil
        recorder = nil
        if isRecording {
            isRecording = false
            AudioSession.endRecording()
        }
    }
}
