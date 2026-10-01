import SwiftUI

/// Edición de un paso: título, instrucción narrada, pictograma y tiempo sugerido.
struct StepEditorView: View {
    @Binding var step: RoutineStep
    @Environment(SettingsStore.self) private var settings
    @Environment(MediaStore.self) private var media

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    StepPictogram(step: step, size: 160, animated: false)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section {
                TextField("Título corto (p. ej. «Guardar la ropa»)", text: $step.title)
                TextField("Instrucción que se lee en voz alta", text: $step.instruction, axis: .vertical)
                    .lineLimit(2...5)
                NavigationLink {
                    SymbolPickerView(selection: $step.symbol)
                } label: {
                    HStack {
                        Text("Pictograma")
                        Spacer()
                        Image(systemName: step.symbol)
                            .font(.title2)
                            .foregroundStyle(Theme.primary)
                            .accessibilityHidden(true)
                    }
                }
            } header: {
                Text("Paso")
            } footer: {
                Text("Usa frases cortas, positivas y en segunda persona: «Pon tu ropa sucia en el cesto».")
            }

            Section {
                Stepper(value: $step.suggestedSeconds, in: RoutineStore.secondsRange, step: 10) {
                    Text("Tiempo sugerido: \(TimerRing.spoken(step.suggestedSeconds))")
                }
            } footer: {
                Text("Con el ritmo «\(settings.pace.title)» serán \(TimerRing.spoken(settings.seconds(for: step))). El tiempo nunca castiga.")
            }

            StepMediaSections(step: step)

            Section {
                Button {
                    settings.narrate("\(step.title). \(step.instruction) \(StepGuideView.doItYourself)",
                                     recording: media.existingURL(for: .voice, stepID: step.id))
                } label: {
                    Label("Escuchar cómo se oye", systemImage: "speaker.wave.2.fill")
                }
            }
        }
        .navigationTitle(step.title.isEmpty ? "Paso" : step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { SpeechService.shared.stop() }
    }
}
