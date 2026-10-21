import Foundation

/// Minijuegos. Siempre opcionales y sin forma de perder (ver `docs/plan-minijuegos-y-calidad.md`).
/// Los `rawValue` son ids estables: no renombrarlos.
enum GameKind: String, Codable, CaseIterable, Identifiable {
    /// «¿Qué sigue?»: ordenar los pasos de la rutina antes de hacerla.
    case sequence = "secuencia"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sequence: "¿Qué sigue?"
        }
    }

    /// Texto del botón que invita a jugar.
    var invitation: String {
        switch self {
        case .sequence: "Jugar: ¿qué sigue?"
        }
    }

    var symbol: String {
        switch self {
        case .sequence: "puzzlepiece.fill"
        }
    }

    /// Juego para antes de una rutina, o nil si no tiene (p. ej. una rutina de un solo paso).
    static func warmUp(for routine: Routine) -> GameKind? {
        routine.steps.count >= SequenceGame.minSteps ? .sequence : nil
    }
}
