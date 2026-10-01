import Foundation
import Observation

/// Fotos reales y voces grabadas de cada paso, guardadas como archivos en el iPad.
///
/// La llave es el id del paso, así que sirven también para las rutinas incluidas
/// (p. ej. una foto de la mochila del niño). Nada sale del dispositivo ni va en el respaldo JSON.
@Observable
final class MediaStore {
    enum Kind: String, CaseIterable {
        case photo
        case voice

        var fileExtension: String {
            switch self {
            case .photo: "jpg"
            case .voice: "m4a"
            }
        }
    }

    /// Sube con cada cambio para que las vistas que muestran archivos se actualicen.
    private(set) var revision = 0

    let directory: URL

    static var defaultDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("media", isDirectory: true)
    }

    init(directory: URL = MediaStore.defaultDirectory) {
        self.directory = directory
    }

    // MARK: - Consultas

    /// Nombre de archivo seguro para un id de paso (solo letras, números, punto y guion).
    static func fileName(for kind: Kind, stepID: String) -> String {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789.-")
        let safe = String(stepID.lowercased().map { allowed.contains($0) ? $0 : "_" })
            .replacingOccurrences(of: "..", with: "_")
        return "\(safe).\(kind.fileExtension)"
    }

    func url(for kind: Kind, stepID: String) -> URL {
        directory.appendingPathComponent(Self.fileName(for: kind, stepID: stepID))
    }

    /// URL del archivo si existe. Lee `revision` para que las vistas se enteren de los cambios.
    func existingURL(for kind: Kind, stepID: String) -> URL? {
        _ = revision
        let url = url(for: kind, stepID: stepID)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func has(_ kind: Kind, stepID: String) -> Bool {
        existingURL(for: kind, stepID: stepID) != nil
    }

    // MARK: - Cambios

    func save(_ data: Data, as kind: Kind, stepID: String) throws {
        try ensureDirectory()
        try data.write(to: url(for: kind, stepID: stepID), options: .atomic)
        revision += 1
    }

    /// Mueve un archivo ya creado (p. ej. una grabación temporal) a su lugar, reemplazando el anterior.
    func adopt(fileAt source: URL, as kind: Kind, stepID: String) throws {
        try ensureDirectory()
        let destination = url(for: kind, stepID: stepID)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: source, to: destination)
        revision += 1
    }

    func delete(_ kind: Kind, stepID: String) {
        try? FileManager.default.removeItem(at: url(for: kind, stepID: stepID))
        revision += 1
    }

    /// Borra foto y voz de varios pasos (al borrar pasos o una rutina).
    func deleteAll(stepIDs: [String]) {
        for stepID in stepIDs {
            for kind in Kind.allCases {
                try? FileManager.default.removeItem(at: url(for: kind, stepID: stepID))
            }
        }
        revision += 1
    }

    /// Copia foto y voz paso a paso (al duplicar una rutina, los pasos quedan en el mismo orden).
    func copyMedia(from source: [RoutineStep], to destination: [RoutineStep]) {
        guard (try? ensureDirectory()) != nil else { return }
        for (from, to) in zip(source, destination) {
            for kind in Kind.allCases {
                guard let original = existingURL(for: kind, stepID: from.id) else { continue }
                let target = url(for: kind, stepID: to.id)
                try? FileManager.default.removeItem(at: target)
                try? FileManager.default.copyItem(at: original, to: target)
            }
        }
        revision += 1
    }

    private func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}
