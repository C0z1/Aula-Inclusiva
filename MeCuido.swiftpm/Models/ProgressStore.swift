import Foundation
import Observation

/// Estado del niño: pasos completados, medallas, mascota y logros.
/// No hay penalizaciones: nada se pierde por equivocarse o tardar, y los contadores solo suben.
@Observable
final class ProgressStore {
    private(set) var medals: Int
    private(set) var completedSteps: Set<String>
    /// Última vez que se terminó cada rutina (por id), para la agenda del día.
    private(set) var lastFinished: [String: Date]
    var equippedAccessoryID: String?
    /// Cuántas veces se ha terminado cada rutina (por id), para el álbum de logros.
    private(set) var routineCounts: [String: Int]
    /// Pasos hechos en total (cada paso cuenta una vez por vuelta de la rutina).
    private(set) var stepsDone: Int
    private(set) var petID: String
    /// Nombre que le puso el niño; vacío = el nombre de fábrica de la mascota.
    private(set) var petName: String
    private(set) var backdropID: String

    private let defaults: UserDefaults
    private static let medalsKey = "medals"
    private static let equippedKey = "equippedAccessory"
    private static let completedKey = "completedSteps"
    private static let lastFinishedKey = "lastFinished"
    private static let routineCountsKey = "routineCounts"
    private static let stepsDoneKey = "stepsDone"
    private static let petKey = "pet.id"
    private static let petNameKey = "pet.name"
    private static let backdropKey = "backdrop"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.medals = defaults.integer(forKey: Self.medalsKey)
        self.equippedAccessoryID = defaults.string(forKey: Self.equippedKey)
        self.completedSteps = Set(defaults.stringArray(forKey: Self.completedKey) ?? [])
        let stamps = defaults.dictionary(forKey: Self.lastFinishedKey) as? [String: Double] ?? [:]
        self.lastFinished = stamps.mapValues { Date(timeIntervalSince1970: $0) }
        self.routineCounts = defaults.dictionary(forKey: Self.routineCountsKey) as? [String: Int] ?? [:]
        self.stepsDone = defaults.integer(forKey: Self.stepsDoneKey)
        self.petID = defaults.string(forKey: Self.petKey) ?? Pet.all[0].id
        self.petName = defaults.string(forKey: Self.petNameKey) ?? ""
        self.backdropID = defaults.string(forKey: Self.backdropKey) ?? Backdrop.all[0].id
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

    /// Si la rutina ya se terminó hoy (agenda del día).
    func isDoneToday(_ routine: Routine, now: Date = .now, calendar: Calendar = .current) -> Bool {
        guard let date = lastFinished[routine.id] else { return false }
        return calendar.isDate(date, inSameDayAs: now)
    }

    func doneTodayCount(of routines: [Routine]) -> Int {
        routines.filter { isDoneToday($0) }.count
    }

    func complete(_ step: RoutineStep) {
        // Repasar un paso ya hecho no lo cuenta dos veces.
        guard completedSteps.insert(step.id).inserted else { return }
        saveCompletedSteps()
        stepsDone += 1
        defaults.set(stepsDone, forKey: Self.stepsDoneKey)
    }

    /// Termina la rutina: otorga una medalla y la reinicia para la próxima vez.
    /// Devuelve el accesorio recién desbloqueado, si lo hay.
    @discardableResult
    func finish(_ routine: Routine, at date: Date = .now) -> Accessory? {
        let before = unlockedAccessories
        medals += 1
        defaults.set(medals, forKey: Self.medalsKey)
        for step in routine.steps { completedSteps.remove(step.id) }
        saveCompletedSteps()
        lastFinished[routine.id] = date
        defaults.set(lastFinished.mapValues(\.timeIntervalSince1970), forKey: Self.lastFinishedKey)
        routineCounts[routine.id, default: 0] += 1
        defaults.set(routineCounts, forKey: Self.routineCountsKey)
        return unlockedAccessories.first { !before.contains($0) }
    }

    // MARK: - Logros

    func timesDone(_ routine: Routine) -> Int {
        routineCounts[routine.id] ?? 0
    }

    var totalRoutinesDone: Int {
        routineCounts.values.reduce(0, +)
    }

    func album(for routines: [Routine]) -> [Achievement] {
        AchievementCatalog.album(routines: routines, timesDone: timesDone,
                                 totalRoutines: totalRoutinesDone, totalSteps: stepsDone)
    }

    func earnedAchievementIDs(for routines: [Routine]) -> Set<String> {
        Set(album(for: routines).filter(\.isEarned).map(\.id))
    }

    // MARK: - Mascota

    var pet: Pet {
        Pet.all.first { $0.id == petID } ?? Pet.all[0]
    }

    /// Nombre a mostrar: el que eligió el niño o el de fábrica.
    var displayPetName: String {
        let name = petName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? pet.defaultName : name
    }

    func choosePet(_ pet: Pet) {
        petID = pet.id
        defaults.set(pet.id, forKey: Self.petKey)
    }

    func setPetName(_ name: String) {
        petName = String(name.prefix(Pet.nameMaxLength))
        defaults.set(petName, forKey: Self.petNameKey)
    }

    var unlockedBackdrops: [Backdrop] {
        Backdrop.all.filter { $0.medalsRequired <= medals }
    }

    var backdrop: Backdrop {
        unlockedBackdrops.first { $0.id == backdropID } ?? Backdrop.all[0]
    }

    func chooseBackdrop(_ backdrop: Backdrop) {
        guard backdrop.medalsRequired <= medals else { return }
        backdropID = backdrop.id
        defaults.set(backdrop.id, forKey: Self.backdropKey)
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

    private func saveCompletedSteps() {
        defaults.set(Array(completedSteps), forKey: Self.completedKey)
    }
}
