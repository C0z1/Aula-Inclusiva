import Foundation
import Observation

/// Rutinas que ve el niño: las incluidas (definidas en `Routine.all`) más las que crean los adultos.
///
/// Las incluidas viven en el código y nunca se borran ni se editan: se pueden ocultar o duplicar
/// para personalizarlas. Las personalizadas y la lista de ocultas se guardan en un JSON local.
@Observable
final class RoutineStore {
    /// Máximo de pasos por rutina personalizada (memoria de trabajo del niño).
    static let maxSteps = 5
    /// Lo que se le sugiere al adulto, como las rutinas incluidas.
    static let recommendedSteps = 3
    static let defaultStepSeconds = 30
    static let secondsRange = 10...600

    private(set) var customRoutines: [Routine]
    private(set) var hiddenIDs: Set<String>

    private let fileURL: URL

    /// Formato del archivo (y del respaldo que se exporta). Subir `version` si cambia.
    struct Snapshot: Codable, Equatable {
        static let currentVersion = 1

        var version = Snapshot.currentVersion
        var customRoutines: [Routine]
        var hiddenIDs: [String]
    }

    enum ImportError: Error, Equatable {
        case unreadable
        case newerVersion
    }

    static var defaultFileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("rutinas.json")
    }

    init(fileURL: URL = RoutineStore.defaultFileURL) {
        self.fileURL = fileURL
        let snapshot = (try? Data(contentsOf: fileURL))
            .flatMap { try? JSONDecoder().decode(Snapshot.self, from: $0) }
        customRoutines = snapshot?.customRoutines ?? []
        hiddenIDs = Set(snapshot?.hiddenIDs ?? [])
    }

    // MARK: - Consultas

    /// Todas las rutinas, incluidas primero (lista de adultos).
    var allRoutines: [Routine] { Routine.all + customRoutines }

    /// Las que aparecen en la agenda del niño: no ocultas y con al menos un paso.
    var visibleRoutines: [Routine] {
        allRoutines.filter { !isHidden($0) && !$0.steps.isEmpty }
    }

    func routine(id: String) -> Routine? {
        allRoutines.first { $0.id == id }
    }

    func isBuiltIn(_ routine: Routine) -> Bool {
        Routine.all.contains { $0.id == routine.id }
    }

    func isHidden(_ routine: Routine) -> Bool {
        hiddenIDs.contains(routine.id)
    }

    // MARK: - Cambios

    func setHidden(_ hidden: Bool, for routine: Routine) {
        if hidden { hiddenIDs.insert(routine.id) } else { hiddenIDs.remove(routine.id) }
        persist()
    }

    /// Crea una rutina personalizada con un primer paso listo para editar.
    @discardableResult
    func createRoutine() -> Routine {
        let id = Self.newRoutineID()
        let routine = Routine(id: id, title: "Mi rutina", symbol: "star.fill", category: .organizarme,
                              steps: [Self.makeStep(in: id, number: 1)])
        customRoutines.append(routine)
        persist()
        return routine
    }

    /// Copia editable de cualquier rutina (útil para personalizar una incluida).
    @discardableResult
    func duplicate(_ routine: Routine) -> Routine {
        let id = Self.newRoutineID()
        let copy = Routine(
            id: id,
            title: "\(routine.title) (copia)",
            symbol: routine.symbol,
            category: routine.category,
            steps: routine.steps.prefix(Self.maxSteps).map { step in
                RoutineStep(id: Self.newStepID(in: id), title: step.title, instruction: step.instruction,
                            symbol: step.symbol, suggestedSeconds: step.suggestedSeconds)
            }
        )
        customRoutines.append(copy)
        persist()
        return copy
    }

    /// Guarda los cambios de una rutina personalizada. Las incluidas no se modifican.
    func save(_ routine: Routine) {
        guard !isBuiltIn(routine),
              let index = customRoutines.firstIndex(where: { $0.id == routine.id }) else { return }
        let normalized = Self.normalized(routine)
        guard customRoutines[index] != normalized else { return }
        customRoutines[index] = normalized
        persist()
    }

    /// Borra una rutina personalizada. Las incluidas solo se pueden ocultar.
    func delete(_ routine: Routine) {
        guard !isBuiltIn(routine) else { return }
        customRoutines.removeAll { $0.id == routine.id }
        hiddenIDs.remove(routine.id)
        persist()
    }

    // MARK: - Pasos

    /// Paso nuevo con id único dentro de la rutina.
    static func makeStep(in routineID: String, number: Int) -> RoutineStep {
        RoutineStep(id: newStepID(in: routineID), title: "Paso \(number)",
                    instruction: "", symbol: "hand.raised.fill", suggestedSeconds: defaultStepSeconds)
    }

    /// Limpia textos vacíos y valores fuera de rango antes de guardar.
    static func normalized(_ routine: Routine) -> Routine {
        var routine = routine
        let title = routine.title.trimmingCharacters(in: .whitespacesAndNewlines)
        routine.title = title.isEmpty ? "Mi rutina" : title
        routine.steps = routine.steps.prefix(maxSteps).enumerated().map { index, step in
            var step = step
            let stepTitle = step.title.trimmingCharacters(in: .whitespacesAndNewlines)
            step.title = stepTitle.isEmpty ? "Paso \(index + 1)" : stepTitle
            step.instruction = step.instruction.trimmingCharacters(in: .whitespacesAndNewlines)
            step.suggestedSeconds = min(max(step.suggestedSeconds, secondsRange.lowerBound), secondsRange.upperBound)
            return step
        }
        return routine
    }

    // MARK: - Respaldo

    /// Archivo con las rutinas personalizadas y las ocultas, para guardarlo o pasarlo a otro iPad.
    func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(snapshot)
    }

    /// Agrega las rutinas de un respaldo. Si una ya existe (mismo id) se reemplaza;
    /// nunca toca las incluidas. Devuelve cuántas rutinas se importaron.
    @discardableResult
    func importData(_ data: Data) throws -> Int {
        guard let backup = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            throw ImportError.unreadable
        }
        guard backup.version <= Snapshot.currentVersion else { throw ImportError.newerVersion }

        let incoming = backup.customRoutines
            .filter { !isBuiltIn($0) }
            .map(Self.normalized)
        for routine in incoming {
            if let index = customRoutines.firstIndex(where: { $0.id == routine.id }) {
                customRoutines[index] = routine
            } else {
                customRoutines.append(routine)
            }
        }
        hiddenIDs.formUnion(backup.hiddenIDs.filter { id in allRoutines.contains { $0.id == id } })
        persist()
        return incoming.count
    }

    // MARK: - Privado

    private var snapshot: Snapshot {
        Snapshot(customRoutines: customRoutines, hiddenIDs: hiddenIDs.sorted())
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try JSONEncoder().encode(snapshot).write(to: fileURL, options: .atomic)
        } catch {
            assertionFailure("No se pudieron guardar las rutinas: \(error)")
        }
    }

    private static func newRoutineID() -> String {
        "custom-\(UUID().uuidString.lowercased())"
    }

    private static func newStepID(in routineID: String) -> String {
        "\(routineID).\(UUID().uuidString.prefix(8).lowercased())"
    }
}
