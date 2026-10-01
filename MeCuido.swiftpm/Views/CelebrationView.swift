import SwiftUI

/// Celebración al terminar una rutina: medalla, la mascota festejando y, si toca,
/// un accesorio nuevo y estampas nuevas del álbum.
struct CelebrationView: View {
    let accessory: Accessory?
    /// Lo agradable que sigue (tablero «Primero → Después»), si el adulto lo eligió.
    var after: AfterActivity? = nil
    /// Estampas que se acaban de ganar.
    var newStickers: [Achievement] = []
    let onDone: () -> Void

    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var title = Encouragement.pick(from: Encouragement.routineDone)
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 56

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing) {
                AvatarView(pet: progress.pet, name: progress.displayPetName,
                           accessory: accessory ?? progress.equippedAccessory,
                           backdrop: progress.backdrop, size: 160)
                    .symbolEffect(.bounce, options: .repeat(2), value: appeared && !reduceMotion)
                    .offset(y: appeared || reduceMotion ? 0 : 30)

                Text(title)
                    .font(.system(size: titleSize, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)

                Text("¡\(progress.displayPetName) está muy feliz!")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Label("Ganaste una medalla", systemImage: "checkmark.seal.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.primary)

                if let accessory {
                    Label("¡Desbloqueaste: \(accessory.name)!", systemImage: accessory.symbol)
                        .font(.title2.weight(.semibold))
                        .padding(.horizontal, Theme.spacing)
                        .padding(.vertical, 12)
                        .background(.white, in: Capsule())
                }

                if !newStickers.isEmpty {
                    VStack(spacing: 12) {
                        Label(newStickers.count == 1 ? "¡Estampa nueva!" : "¡Estampas nuevas!",
                              systemImage: "book.closed.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.primary)
                        ForEach(newStickers) { sticker in
                            Label("\(sticker.title): \(sticker.detail)", systemImage: sticker.symbol)
                                .font(.body.bold())
                        }
                    }
                    .padding(Theme.spacing)
                    .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                }

                if let after {
                    Label("Ahora sí: \(after.title)", systemImage: after.symbol)
                        .font(.title2.weight(.semibold))
                        .padding(.horizontal, Theme.spacing)
                        .padding(.vertical, 12)
                        .background(Theme.reward.opacity(0.3), in: Capsule())
                }
            }
            .padding(Theme.padding)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onDone) {
                Label("Volver al inicio", systemImage: "house.fill")
            }
            .buttonStyle(.primary)
            .frame(maxWidth: 500)
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
        }
        .background(Theme.success.opacity(0.15))
        .background(Theme.background)
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(duration: 0.6, bounce: 0.5)) { appeared = true }
            var message = "\(title) Ganaste una medalla. \(progress.displayPetName) está muy feliz."
            if let accessory { message += " Desbloqueaste: \(accessory.name)." }
            if !newStickers.isEmpty {
                message += newStickers.count == 1 ? " Tienes una estampa nueva." : " Tienes \(newStickers.count) estampas nuevas."
            }
            if let after { message += " Ahora sí: \(after.title)." }
            if settings.autoNarration {
                settings.speak(message)
            }
        }
    }
}

#Preview {
    CelebrationView(accessory: Accessory.all[1],
                    after: AfterActivity.suggestions[0],
                    newStickers: [Achievement(id: "total.1", title: "Tu primera rutina", detail: "Rutinas terminadas en total",
                                              symbol: "star.fill", current: 1, target: 1)]) {}
        .environment(SettingsStore())
        .environment(ProgressStore())
        .fontDesign(.rounded)
}
