import SwiftUI

/// Celebración al terminar una rutina: medalla y, si toca, un accesorio nuevo.
struct CelebrationView: View {
    let accessory: Accessory?
    /// Lo agradable que sigue (tablero «Primero → Después»), si el adulto lo eligió.
    var after: AfterActivity? = nil
    let onDone: () -> Void

    @Environment(SettingsStore.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 56

    var body: some View {
        VStack(spacing: Theme.padding) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 90))
                .foregroundStyle(Theme.reward)
                .symbolEffect(.bounce, value: appeared)
                .accessibilityHidden(true)

            Text("¡Lo lograste!")
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)

            Label("Ganaste una medalla", systemImage: "checkmark.seal.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.primary)

            if let accessory {
                VStack(spacing: 16) {
                    AvatarView(accessory: accessory, size: 140)
                    Text("¡Desbloqueaste: \(accessory.name)!")
                        .font(.title2.weight(.semibold))
                }
                .padding(Theme.padding)
                .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
            }

            if let after {
                Label("Ahora sí: \(after.title)", systemImage: after.symbol)
                    .font(.title2.weight(.semibold))
                    .padding(.horizontal, Theme.spacing)
                    .padding(.vertical, 12)
                    .background(Theme.reward.opacity(0.3), in: Capsule())
            }

            Spacer()

            Button(action: onDone) {
                Label("Volver al inicio", systemImage: "house.fill")
            }
            .buttonStyle(.primary)
            .frame(maxWidth: 500)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.success.opacity(0.15))
        .background(Theme.background)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.9)
        .onAppear {
            withAnimation(.spring) { appeared = true }
            var message = "¡Lo lograste! Ganaste una medalla."
            if let accessory { message += " Desbloqueaste: \(accessory.name)." }
            if let after { message += " Ahora sí: \(after.title)." }
            if settings.autoNarration {
                settings.speak(message)
            }
        }
    }
}

#Preview {
    CelebrationView(accessory: Accessory.all[1]) {}
        .environment(SettingsStore())
        .fontDesign(.rounded)
}
