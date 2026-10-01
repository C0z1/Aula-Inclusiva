import SwiftUI
import UniformTypeIdentifiers

/// Lista de rutinas para adultos: crear, personalizar, ocultar y respaldar.
struct RoutinesAdminView: View {
    @Environment(RoutineStore.self) private var routines

    @State private var openRoutineID: String?
    @State private var pendingDelete: Routine?
    @State private var exportDocument: RoutinesBackupDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var message: String?

    var body: some View {
        List {
            Section {
                ForEach(routines.customRoutines) { routine in
                    NavigationLink {
                        RoutineEditorView(routineID: routine.id)
                    } label: {
                        RoutineAdminRow(routine: routine, isHidden: routines.isHidden(routine),
                                        plan: routines.plan(for: routine))
                    }
                }
                .onDelete { offsets in
                    pendingDelete = offsets.first.map { routines.customRoutines[$0] }
                }

                Button {
                    openRoutineID = routines.createRoutine().id
                } label: {
                    Label("Nueva rutina", systemImage: "plus.circle.fill")
                        .font(.body.bold())
                }
            } header: {
                Text("Mis rutinas")
            } footer: {
                Text("Las rutinas sin pasos o marcadas como ocultas no aparecen en la agenda del niño.")
            }

            Section {
                ForEach(Routine.all) { routine in
                    NavigationLink {
                        BuiltInRoutineView(routine: routine)
                    } label: {
                        RoutineAdminRow(routine: routine, isHidden: routines.isHidden(routine),
                                        plan: routines.plan(for: routine))
                    }
                }
            } header: {
                Text("Incluidas")
            } footer: {
                Text("En cada una puedes elegir cuándo toca, qué viene después u ocultarla. Sus pasos no se editan; duplícala para cambiarlos.")
            }

            Section {
                Button {
                    exportBackup()
                } label: {
                    Label("Guardar respaldo", systemImage: "square.and.arrow.up")
                }
                .fileExporter(isPresented: $showingExporter, document: exportDocument,
                              contentType: .json, defaultFilename: "rutinas-me-cuido") { result in
                    if case .failure = result { message = "No se pudo guardar el respaldo." }
                }

                Button {
                    showingImporter = true
                } label: {
                    Label("Importar respaldo", systemImage: "square.and.arrow.down")
                }
                .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
                    importBackup(result)
                }
            } header: {
                Text("Respaldo")
            } footer: {
                Text("Guarda tus rutinas en un archivo para pasarlas a otro iPad (por ejemplo, de casa a la escuela). Todo se queda en tus dispositivos.")
            }
        }
        .navigationTitle("Rutinas")
        .navigationDestination(item: $openRoutineID) { id in
            RoutineEditorView(routineID: id)
        }
        .confirmationDialog("¿Borrar «\(pendingDelete?.title ?? "")»?",
                            isPresented: Binding(get: { pendingDelete != nil },
                                                 set: { if !$0 { pendingDelete = nil } }),
                            titleVisibility: .visible,
                            presenting: pendingDelete) { routine in
            Button("Borrar rutina", role: .destructive) {
                routines.delete(routine)
            }
        } message: { _ in
            Text("El progreso de esta rutina también se perderá.")
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil },
                                                   set: { if !$0 { message = nil } })) {
            Button("Aceptar", role: .cancel) {}
        }
    }

    private func exportBackup() {
        do {
            exportDocument = RoutinesBackupDocument(data: try routines.exportData())
            showingExporter = true
        } catch {
            message = "No se pudo crear el respaldo."
        }
    }

    private func importBackup(_ result: Result<URL, Error>) {
        guard case .success(let url) = result else {
            message = "No se pudo abrir el archivo."
            return
        }
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }

        do {
            let count = try routines.importData(Data(contentsOf: url))
            message = count == 1 ? "Se importó 1 rutina." : "Se importaron \(count) rutinas."
        } catch RoutineStore.ImportError.newerVersion {
            message = "Este respaldo es de una versión más nueva de la app. Actualízala para importarlo."
        } catch {
            message = "No se pudo leer el archivo. Asegúrate de que sea un respaldo de Me Cuido."
        }
    }
}

private struct RoutineAdminRow: View {
    let routine: Routine
    let isHidden: Bool
    let plan: RoutinePlan

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: routine.symbol)
                .font(.title)
                .foregroundStyle(isHidden ? Color.secondary : Theme.primary)
                .frame(width: 48)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .font(.body.bold())
                Text(details)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Label(plan.summary, systemImage: plan.isAnytime ? "hand.tap.fill" : "calendar")
                    .font(.callout)
                    .foregroundStyle(isHidden ? Color.secondary : Theme.primary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var details: String {
        var parts = [routine.category.rawValue,
                     routine.steps.count == 1 ? "1 paso" : "\(routine.steps.count) pasos"]
        if isHidden { parts.append("oculta") }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    NavigationStack {
        RoutinesAdminView()
    }
    .environment(RoutineStore())
    .environment(SettingsStore())
    .fontDesign(.rounded)
}
