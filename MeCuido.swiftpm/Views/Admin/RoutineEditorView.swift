import SwiftUI

/// Edición de una rutina personalizada. Los cambios se guardan solos.
struct RoutineEditorView: View {
    let routineID: String

    @Environment(RoutineStore.self) private var routines
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Routine?
    @State private var confirmingDelete = false

    var body: some View {
        Group {
            if let routine = Binding($draft) {
                form(routine)
            } else {
                ContentUnavailableView("No se encontró la rutina", systemImage: "questionmark.folder")
            }
        }
        .navigationTitle(draft.map { $0.title.isEmpty ? "Rutina" : $0.title } ?? "Rutina")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if draft != nil {
                EditButton()
                    .frame(minWidth: Theme.minTarget, minHeight: 44)
            }
        }
        .onAppear {
            if draft == nil { draft = routines.routine(id: routineID) }
        }
        .onChange(of: draft) { _, newValue in
            if let newValue { routines.save(newValue) }
        }
    }

    private func form(_ routine: Binding<Routine>) -> some View {
        Form {
            Section("Rutina") {
                TextField("Nombre (p. ej. «Prepararme para dormir»)", text: routine.title)
                Picker("Tipo", selection: routine.category) {
                    ForEach(Routine.Category.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                NavigationLink {
                    SymbolPickerView(selection: routine.symbol)
                } label: {
                    HStack {
                        Text("Pictograma")
                        Spacer()
                        Image(systemName: routine.wrappedValue.symbol)
                            .font(.title2)
                            .foregroundStyle(Theme.primary)
                            .accessibilityHidden(true)
                    }
                }
                Toggle("Mostrar en la agenda", isOn: Binding(
                    get: { !routines.isHidden(routine.wrappedValue) },
                    set: { routines.setHidden(!$0, for: routine.wrappedValue) }
                ))
            }

            Section {
                ForEach(routine.steps) { $step in
                    NavigationLink {
                        StepEditorView(step: $step)
                    } label: {
                        stepRow(step, number: (routine.wrappedValue.steps.firstIndex(of: step) ?? 0) + 1)
                    }
                }
                .onMove { routine.wrappedValue.steps.move(fromOffsets: $0, toOffset: $1) }
                .onDelete { routine.wrappedValue.steps.remove(atOffsets: $0) }

                Button {
                    let steps = routine.wrappedValue.steps
                    routine.wrappedValue.steps.append(RoutineStore.makeStep(in: routineID, number: steps.count + 1))
                } label: {
                    Label("Agregar paso", systemImage: "plus.circle.fill")
                }
                .disabled(routine.wrappedValue.steps.count >= RoutineStore.maxSteps)
            } header: {
                Text("Pasos")
            } footer: {
                Text(stepsFooter(count: routine.wrappedValue.steps.count))
            }

            PlanSections(routine: routine.wrappedValue)

            Section {
                Button {
                    confirmingDelete = true
                } label: {
                    Label("Borrar rutina", systemImage: "trash")
                }
                .confirmationDialog("¿Borrar «\(routine.wrappedValue.title)»?", isPresented: $confirmingDelete,
                                    titleVisibility: .visible) {
                    Button("Borrar rutina", role: .destructive) {
                        routines.delete(routine.wrappedValue)
                        dismiss()
                    }
                } message: {
                    Text("El progreso de esta rutina también se perderá. Las rutinas incluidas no se ven afectadas.")
                }
            }
        }
    }

    private func stepRow(_ step: RoutineStep, number: Int) -> some View {
        HStack(spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(Theme.primary)
                .frame(width: 32, height: 32)
                .background(Theme.secondaryButton, in: Circle())
            Image(systemName: step.symbol)
                .font(.title2)
                .foregroundStyle(Theme.primary)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title.isEmpty ? "Paso \(number)" : step.title)
                    .font(.body.bold())
                Text(step.instruction.isEmpty ? "Falta la instrucción" : step.instruction)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private func stepsFooter(count: Int) -> String {
        if count == 0 {
            return "Agrega al menos un paso para que la rutina aparezca en la agenda."
        }
        if count >= RoutineStore.maxSteps {
            return "Máximo \(RoutineStore.maxSteps) pasos, para no cargar la memoria. Usa Editar para reordenar o borrar."
        }
        return "Recomendado: \(RoutineStore.recommendedSteps) pasos, como las rutinas incluidas. Usa Editar para reordenar o borrar."
    }
}
