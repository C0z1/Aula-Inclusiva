import SwiftUI

/// Ajustes para adultos (maestra, papá o mamá). Se abre manteniendo presionado
/// el engrane del inicio, para que el niño no los cambie por accidente.
struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            Form {
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
        .fontDesign(.rounded)
}
