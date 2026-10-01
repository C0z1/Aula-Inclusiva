import SwiftUI

/// Pregunta para adultos antes de abrir los ajustes. Con teclado propio de botones grandes.
/// Si la respuesta no es correcta, no hay rojo ni castigo: solo una pregunta nueva.
struct AdultGateView: View {
    let onPass: () -> Void
    let onCancel: () -> Void

    @State private var gate = AdultGate.random()
    @State private var input = ""
    @State private var showRetry = false
    @State private var attempts = 0

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "borrar", "0", "listo"]
    private let columns = Array(repeating: GridItem(.fixed(96), spacing: 16), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.primary)
                        .accessibilityHidden(true)

                    Text("Solo para adultos")
                        .font(.title2.weight(.semibold))

                    Text(gate.question)
                        .font(.largeTitle.bold())
                        .accessibilityLabel(gate.spokenQuestion)

                    Text(input.isEmpty ? " " : input)
                        .font(.largeTitle.bold().monospacedDigit())
                        .frame(minWidth: 180, minHeight: 64)
                        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                        .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius)
                            .stroke(Theme.secondaryButton, lineWidth: 2))
                        .accessibilityLabel("Respuesta")
                        .accessibilityValue(input.isEmpty ? "vacía" : input)

                    if showRetry {
                        Label("Esa no es. Prueba con esta otra pregunta.", systemImage: "arrow.clockwise")
                            .font(.body.bold())
                            .foregroundStyle(Theme.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Theme.retry.opacity(0.5), in: Capsule())
                            .transition(.opacity)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(keys, id: \.self) { key in
                            keyButton(key)
                        }
                    }
                }
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.background)
            .navigationTitle("Ajustes para adultos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: onCancel)
                        .frame(minWidth: Theme.minTarget, minHeight: 44)
                }
            }
            .sensoryFeedback(.selection, trigger: input)
            .sensoryFeedback(.warning, trigger: attempts)
        }
    }

    @ViewBuilder
    private func keyButton(_ key: String) -> some View {
        switch key {
        case "borrar":
            Button {
                if !input.isEmpty { input.removeLast() }
            } label: {
                keyFace(Image(systemName: "delete.left.fill").font(.title2), fill: Theme.secondaryButton,
                        foreground: Theme.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Borrar")
        case "listo":
            Button(action: submit) {
                keyFace(Image(systemName: "checkmark").font(.title2.bold()), fill: Theme.success,
                        foreground: Theme.onSuccess)
            }
            .buttonStyle(.plain)
            .disabled(input.isEmpty)
            .opacity(input.isEmpty ? 0.5 : 1)
            .accessibilityLabel("Comprobar")
        default:
            Button {
                showRetry = false
                if input.count < AdultGate.maxDigits { input.append(key) }
            } label: {
                keyFace(Text(key).font(.title.bold()), fill: .white, foreground: Theme.primary)
            }
            .buttonStyle(.plain)
        }
    }

    /// Tecla de tamaño fijo (mayor que el mínimo de 60 pt) para que el teclado quede parejo.
    private func keyFace(_ content: some View, fill: Color, foreground: Color) -> some View {
        content
            .foregroundStyle(foreground)
            .frame(width: 96, height: 72)
            .background(fill, in: RoundedRectangle(cornerRadius: Theme.buttonRadius))
            .overlay(RoundedRectangle(cornerRadius: Theme.buttonRadius)
                .stroke(Theme.secondaryButton, lineWidth: 2))
            .contentShape(RoundedRectangle(cornerRadius: Theme.buttonRadius))
    }

    private func submit() {
        if gate.isCorrect(input) {
            onPass()
        } else {
            attempts += 1
            input = ""
            withAnimation {
                gate = AdultGate.random()
                showRetry = true
            }
        }
    }
}

#Preview {
    AdultGateView(onPass: {}, onCancel: {})
        .fontDesign(.rounded)
}
