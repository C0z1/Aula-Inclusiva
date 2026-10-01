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
                } header: {
                    Text("Voz")
                } footer: {
                    Text("Si se apaga la lectura automática, el botón «Escuchar de nuevo» sigue disponible.")
                }

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

#Preview {
    SettingsView()
        .environment(SettingsStore())
        .environment(RoutineStore())
        .fontDesign(.rounded)
}
