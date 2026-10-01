import AVFoundation
import SwiftUI

/// Elegir la voz del iPad que lee los pasos (cuando no hay voz grabada).
struct VoicePickerView: View {
    @Environment(SettingsStore.self) private var settings

    private static let sample = "Hola. Así se oye esta voz. ¡Ahora hazlo tú y presiona el botón cuando termines!"
    private let voices = SpeechService.spanishVoices

    var body: some View {
        List {
            Section {
                row(title: "Automática", detail: "Español de México si está instalada", identifier: nil)
            }

            Section {
                ForEach(voices, id: \.identifier) { voice in
                    row(title: voice.name, detail: Self.detail(for: voice), identifier: voice.identifier)
                }
            } header: {
                Text("Voces en español de este iPad")
            } footer: {
                Text("Para descargar voces de mejor calidad: Ajustes del iPad → Accesibilidad → Contenido leído → Voces → Español.")
            }
        }
        .navigationTitle("Voz del iPad")
        .onDisappear { SpeechService.shared.stop() }
    }

    private func row(title: String, detail: String, identifier: String?) -> some View {
        let isSelected = settings.voiceIdentifier == identifier
        return Button {
            settings.voiceIdentifier = identifier
            settings.speak(Self.sample)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                        .foregroundStyle(Theme.primary)
                }
            }
            .frame(minHeight: 44)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Elige esta voz y escucha un ejemplo")
    }

    private static func detail(for voice: AVSpeechSynthesisVoice) -> String {
        let language = Locale(identifier: "es_MX").localizedString(forIdentifier: voice.language) ?? voice.language
        let quality: String
        switch voice.quality {
        case .premium: quality = "calidad premium"
        case .enhanced: quality = "calidad mejorada"
        default: quality = "calidad básica"
        }
        return "\(language) · \(quality)"
    }
}
