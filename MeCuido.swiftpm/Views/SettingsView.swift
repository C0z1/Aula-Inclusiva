import SwiftUI

/// Ajustes para adultos (maestra, papá o mamá). Se abre manteniendo presionado el engrane
/// del inicio y respondiendo la pregunta de `AdultGateView`, para que el niño no los cambie
/// por accidente.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var unlocked = false

    var body: some View {
        if unlocked {
            SettingsForm()
        } else {
            AdultGateView(onPass: { unlocked = true }, onCancel: { dismiss() })
        }
    }
}

private struct SettingsForm: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(RoutineStore.self) private var routines
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        RoutinesAdminView()
                    } label: {
                        Label("Rutinas", systemImage: "list.bullet.rectangle.fill")
                            .badge(routines.visibleRoutines.count)
                    }
                } footer: {
                    Text("Crea rutinas nuevas, personaliza una copia de las incluidas u oculta las que no se usan.")
                }

                Section {
                    Picker("Ritmo", selection: $settings.pace) {
                        ForEach(SettingsStore.Pace.allCases) { pace in
                            Text(pace.title).tag(pace)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Tiempo de cada paso")
                } footer: {
                    Text("Da más tiempo sugerido a cada paso. El temporizador nunca castiga: al terminar, el niño puede seguir a su ritmo.")
                }

                Section {
                    Toggle("Leer cada paso en voz alta", isOn: $settings.autoNarration)
                    Toggle("Voz más lenta", isOn: $settings.slowSpeech)
                    NavigationLink {
                        VoicePickerView()
                    } label: {
                        Label("Voz del iPad", systemImage: "person.wave.2.fill")
                    }
                } header: {
                    Text("Voz")
                } footer: {
                    Text("Si se apaga la lectura automática, el botón «Escuchar de nuevo» sigue disponible. Los pasos con voz grabada por un familiar usan esa grabación.")
                }

                RemindersSection()

                Section {
                    Toggle("Sonidos de logro", isOn: $settings.soundEffects)
                } header: {
                    Text("Sonidos")
                } footer: {
                    Text("Una campanita suave al terminar cada paso y cada rutina. Nunca hay sonidos de error ni de alarma.")
                }
            }
            .navigationTitle("Ajustes para adultos")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .font(.body.bold())
                        .frame(minWidth: Theme.minTarget, minHeight: 44)
                }
            }
        }
    }
}

/// Recordatorios locales por momento del día. Pide permiso al activarlos.
private struct RemindersSection: View {
    @Environment(SettingsStore.self) private var settings
    @State private var deniedMessage = false

    var body: some View {
        Section {
            Toggle("Recordar las rutinas", isOn: Binding(
                get: { settings.remindersEnabled },
                set: { enable in
                    guard enable else {
                        settings.remindersEnabled = false
                        return
                    }
                    Task {
                        let granted = await ReminderService.requestAuthorization()
                        settings.remindersEnabled = granted
                        deniedMessage = !granted
                    }
                }
            ))

            if settings.remindersEnabled {
                ForEach(DayMoment.allCases) { moment in
                    DatePicker(selection: time(for: moment), displayedComponents: .hourAndMinute) {
                        Label(moment.title, systemImage: moment.symbol)
                    }
                }
            }
        } header: {
            Text("Recordatorios")
        } footer: {
            Text("Una notificación amable a la hora de cada momento, solo los días en que toca alguna rutina. Se programan en el iPad; nada sale del dispositivo.")
        }
        .alert("Las notificaciones están desactivadas", isPresented: $deniedMessage) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text("Para usar recordatorios, permite las notificaciones de Me Cuido en la app Ajustes del iPad.")
        }
    }

    /// Convierte los minutos guardados a una fecha de hoy para el DatePicker, y de regreso.
    private func time(for moment: DayMoment) -> Binding<Date> {
        Binding(
            get: {
                let minutes = settings.reminderMinutes(for: moment)
                return Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60,
                                             second: 0, of: .now) ?? .now
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                settings.setReminderMinutes((parts.hour ?? 0) * 60 + (parts.minute ?? 0), for: moment)
            }
        )
    }
}

#Preview {
    SettingsView()
        .environment(SettingsStore())
        .environment(RoutineStore())
        .environment(MediaStore())
        .fontDesign(.rounded)
}
