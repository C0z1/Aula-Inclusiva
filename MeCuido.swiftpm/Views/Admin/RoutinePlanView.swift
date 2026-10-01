import SwiftUI

/// Secciones de formulario con el plan de una rutina: cuándo toca, qué viene después y
/// revisión final. Se usan dentro de un `Form` y guardan directo en `RoutineStore`.
struct PlanSections: View {
    let routine: Routine

    @Environment(RoutineStore.self) private var routines
    /// Texto de «Otra…» mientras el adulto lo escribe (puede quedar vacío un momento).
    @State private var customAfterTitle = ""
    @State private var isCustomAfter = false

    private var plan: Binding<RoutinePlan> {
        Binding(get: { routines.plan(for: routine) },
                set: { routines.setPlan($0, for: routine) })
    }

    var body: some View {
        Section {
            ForEach(DayMoment.allCases) { moment in
                Toggle(isOn: Binding(
                    get: { plan.wrappedValue.moments.contains(moment) },
                    set: { isOn in
                        if isOn { plan.wrappedValue.moments.insert(moment) } else { plan.wrappedValue.moments.remove(moment) }
                    }
                )) {
                    Label(moment.title, systemImage: moment.symbol)
                }
            }
        } header: {
            Text("¿Cuándo toca?")
        } footer: {
            Text(plan.wrappedValue.isAnytime
                 ? "Sin momento elegido, la rutina queda «cuando se necesite»: aparece en la agenda pero nunca como «Ahora toca»."
                 : "En ese momento aparecerá grande como «Ahora toca» hasta que se termine.")
        }

        if !plan.wrappedValue.isAnytime {
            Section("Días") {
                WeekdayPicker(selection: plan.weekdays)
                    .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            }
        }

        Section {
            Picker("Después", selection: afterSelection) {
                Text("Nada").tag(AfterChoice.none)
                ForEach(AfterActivity.suggestions, id: \.self) { activity in
                    Label(activity.title, systemImage: activity.symbol).tag(AfterChoice.suggestion(activity))
                }
                Text("Otra…").tag(AfterChoice.custom)
            }
            .pickerStyle(.navigationLink)

            if isCustomAfter {
                TextField("¿Qué sigue? (p. ej. «Ir con la abuela»)", text: $customAfterTitle)
                    .onChange(of: customAfterTitle) { _, title in
                        plan.wrappedValue.afterActivity = AfterActivity(title: title, symbol: "star.fill")
                    }
            }
        } header: {
            Text("Primero → Después")
        } footer: {
            Text("Algo agradable que pasa al terminar. Se muestra antes de empezar y en la celebración. Ayuda a arrancar las rutinas que cuestan más.")
        }
        .onAppear {
            if let after = plan.wrappedValue.afterActivity, !AfterActivity.suggestions.contains(after) {
                isCustomAfter = true
                customAfterTitle = after.title
            }
        }

        Section {
            Toggle("Revisar los pasos al final", isOn: plan.reviewEnabled)
        } footer: {
            Text("Antes de la celebración, el niño repasa sus pasos y puede volver a uno si se le olvidó. Útil en rutinas como la mochila.")
        }

        if plan.wrappedValue != RoutinePlan.defaultPlan(for: routine.id) {
            Section {
                Button("Volver al plan original") {
                    plan.wrappedValue = RoutinePlan.defaultPlan(for: routine.id)
                    isCustomAfter = false
                    customAfterTitle = ""
                }
            }
        }
    }

    // MARK: - Actividad de después

    private enum AfterChoice: Hashable {
        case none
        case suggestion(AfterActivity)
        case custom
    }

    private var afterSelection: Binding<AfterChoice> {
        Binding(
            get: {
                if isCustomAfter { return .custom }
                guard let after = plan.wrappedValue.afterActivity else { return .none }
                return AfterActivity.suggestions.contains(after) ? .suggestion(after) : .custom
            },
            set: { choice in
                switch choice {
                case .none:
                    isCustomAfter = false
                    plan.wrappedValue.afterActivity = nil
                case .suggestion(let activity):
                    isCustomAfter = false
                    plan.wrappedValue.afterActivity = activity
                case .custom:
                    isCustomAfter = true
                    if customAfterTitle.isEmpty { customAfterTitle = "Algo especial" }
                    plan.wrappedValue.afterActivity = AfterActivity(title: customAfterTitle, symbol: "star.fill")
                }
            }
        )
    }
}

/// Detalle de una rutina incluida: visibilidad, plan, pasos (solo lectura) y duplicar.
struct BuiltInRoutineView: View {
    let routine: Routine

    @Environment(RoutineStore.self) private var routines
    @State private var openCopyID: String?

    var body: some View {
        Form {
            Section {
                Toggle("Mostrar en la agenda", isOn: Binding(
                    get: { !routines.isHidden(routine) },
                    set: { routines.setHidden(!$0, for: routine) }
                ))
            }

            PlanSections(routine: routine)

            Section {
                ForEach(Array(routine.steps.enumerated()), id: \.element.id) { index, step in
                    Label("\(index + 1). \(step.title)", systemImage: step.symbol)
                }
                Button {
                    openCopyID = routines.duplicate(routine).id
                } label: {
                    Label("Duplicar para cambiar los pasos", systemImage: "plus.square.on.square")
                }
            } header: {
                Text("Pasos")
            } footer: {
                Text("Los pasos de las rutinas incluidas no se editan; duplica la rutina para personalizarlos.")
            }
        }
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $openCopyID) { id in
            RoutineEditorView(routineID: id)
        }
    }
}

/// Días de la semana como botones grandes (lunes primero). El estado no depende solo del color.
struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.displayOrder, id: \.self) { day in
                let isOn = selection.contains(day)
                Button {
                    if isOn { selection.remove(day) } else { selection.insert(day) }
                } label: {
                    VStack(spacing: 2) {
                        Text(Weekday.letter(day))
                            .font(.headline)
                        Image(systemName: isOn ? "checkmark" : "circle")
                            .font(.caption2.bold())
                    }
                    .frame(maxWidth: .infinity, minHeight: Theme.minTarget)
                    .foregroundStyle(isOn ? .white : Theme.primary)
                    .background(isOn ? Theme.primary : Theme.secondaryButton,
                                in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Weekday.fullName(day))
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }
}
