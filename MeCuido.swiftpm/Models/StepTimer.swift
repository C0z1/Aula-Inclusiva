import Foundation
import Observation

/// Temporizador de un paso. Solo acompaña: al llegar a cero no pasa nada malo,
/// el niño sigue a su ritmo y avanza cuando presiona «¡Hecho!».
@Observable
final class StepTimer {
    /// Segundos que agrega el botón «Más tiempo».
    static let extraTime = 30

    private(set) var total = 0
    private(set) var remaining = 0
    var isPaused = false

    var isFinished: Bool { total > 0 && remaining == 0 }

    /// Fracción restante (1 = recién empieza, 0 = terminó).
    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(remaining) / Double(total)
    }

    /// Empieza de nuevo con el tiempo indicado y sin pausa.
    func reset(seconds: Int) {
        total = max(seconds, 0)
        remaining = total
        isPaused = false
    }

    func addTime(_ seconds: Int = StepTimer.extraTime) {
        guard seconds > 0 else { return }
        total += seconds
        remaining += seconds
    }

    /// Avanza un segundo, salvo en pausa o si ya llegó a cero.
    func tick() {
        guard !isPaused, remaining > 0 else { return }
        remaining -= 1
    }
}
