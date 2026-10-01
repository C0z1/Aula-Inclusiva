import Foundation
import Observation

/// Ajustes que configura un adulto: ritmo del temporizador y apoyo de voz.
/// Se adaptan al ritmo del niño; ninguno añade presión ni penalizaciones.
@Observable
final class SettingsStore {
    /// Multiplica el tiempo sugerido de cada paso.
    enum Pace: String, CaseIterable, Identifiable {
        case normal, calm, extraCalm

        var id: String { rawValue }

        var title: String {
            switch self {
            case .normal: "Normal"
            case .calm: "Con calma"
            case .extraCalm: "Con mucha calma"
            }
        }

        var multiplier: Double {
            switch self {
            case .normal: 1
            case .calm: 1.5
            case .extraCalm: 2
            }
        }
    }

    var pace: Pace {
        didSet { defaults.set(pace.rawValue, forKey: Self.paceKey) }
    }

    /// Narrar cada paso al llegar a él. Si está apagado, el niño usa «Escuchar de nuevo».
    var autoNarration: Bool {
        didSet { defaults.set(autoNarration, forKey: Self.autoNarrationKey) }
    }

    /// Voz más lenta que la normal.
    var slowSpeech: Bool {
        didSet { defaults.set(slowSpeech, forKey: Self.slowSpeechKey) }
    }

    /// Campanita suave al terminar un paso o una rutina.
    var soundEffects: Bool {
        didSet { defaults.set(soundEffects, forKey: Self.soundEffectsKey) }
    }

    private let defaults: UserDefaults
    private static let paceKey = "settings.pace"
    private static let autoNarrationKey = "settings.autoNarration"
    private static let slowSpeechKey = "settings.slowSpeech"
    private static let soundEffectsKey = "settings.soundEffects"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.pace = defaults.string(forKey: Self.paceKey).flatMap(Pace.init(rawValue:)) ?? .normal
        self.autoNarration = defaults.object(forKey: Self.autoNarrationKey) as? Bool ?? true
        self.slowSpeech = defaults.bool(forKey: Self.slowSpeechKey)
        self.soundEffects = defaults.object(forKey: Self.soundEffectsKey) as? Bool ?? true
    }

    /// Tiempo sugerido de un paso ajustado al ritmo elegido.
    func seconds(for step: RoutineStep) -> Int {
        Int((Double(step.suggestedSeconds) * pace.multiplier).rounded())
    }
}
