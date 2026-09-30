import Foundation
import Observation

/// Estado del niño: pasos completados, medallas y accesorios del avatar.
/// No hay penalizaciones: nada se pierde por equivocarse o tardar.
@Observable
final class ProgressStore {
    private(set) var medals: Int
    private(set) var completedSteps: Set<String> = []
    var equippedAccessoryID: String?

    private let defaults: UserDefaults
    private static let medalsKey = "medals"
    private static let equippedKey = "equippedAccessory"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.medals = defaults.integer(forKey: Self.medalsKey)
        self.equippedAccessoryID = defaults.string(forKey: Self.equippedKey)
    }

    func isCompleted(_ step: RoutineStep) -> Bool {
        completedSteps.contains(step.id)
    }

    func completedCount(in routine: Routine) -> Int {
        routine.steps.filter(isCompleted).count
    }

    func progress(of routine: Routine) -> Double {
        guard !routine.steps.isEmpty else { return 0 }
        return Double(completedCount(in: routine)) / Double(routine.steps.count)
    }

    /// Índice del primer paso pendiente, o nil si la rutina está completa.
    func nextPendingIndex(in routine: Routine) -> Int? {
        routine.steps.firstIndex { !isCompleted($0) }
    }

    func complete(_ step: RoutineStep) {
        completedSteps.insert(step.id)
    }

    /// Termina la rutina: otorga una medalla y la reinicia para la próxima vez.
    /// Devuelve el accesorio recién desbloqueado, si lo hay.
    @discardableResult
    func finish(_ routine: Routine) -> Accessory? {
        let before = unlockedAccessories
        medals += 1
        defaults.set(medals, forKey: Self.medalsKey)
        for step in routine.steps { completedSteps.remove(step.id) }
        return unlockedAccessories.first { !before.contains($0) }
    }

    var unlockedAccessories: [Accessory] {
        Accessory.all.filter { $0.medalsRequired <= medals }
    }

    var equippedAccessory: Accessory? {
        unlockedAccessories.first { $0.id == equippedAccessoryID }
    }

    func equip(_ accessory: Accessory?) {
        equippedAccessoryID = accessory?.id
        defaults.set(accessory?.id, forKey: Self.equippedKey)
    }
}
