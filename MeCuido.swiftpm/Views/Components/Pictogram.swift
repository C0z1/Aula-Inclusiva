import SwiftUI

/// Pictograma grande del paso. Pulsa suavemente para atraer la atención,
/// salvo que el niño tenga activado "Reducir movimiento".
struct Pictogram: View {
    let symbol: String
    var size: CGFloat = 220
    var animated = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Crece con Dynamic Type, con tope para no ocupar toda la pantalla.
    @ScaledMetric(relativeTo: .largeTitle) private var scale: CGFloat = 1

    private var scaledSize: CGFloat { size * min(scale, 1.4) }

    var body: some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Theme.primary)
            .padding(scaledSize * 0.2)
            .frame(width: scaledSize, height: scaledSize)
            .background(Theme.secondaryButton, in: RoundedRectangle(cornerRadius: Theme.cardRadius * 2))
            .symbolEffect(.pulse, options: .repeating, isActive: animated && !reduceMotion)
            .accessibilityHidden(true)
    }
}

/// Pictograma de un paso: la foto real que tomó un adulto (si hay) o el SF Symbol.
/// La foto ayuda a reconocer los objetos propios del niño (su mochila, su cama).
struct StepPictogram: View {
    let step: RoutineStep
    var size: CGFloat = 220
    var animated = true

    @Environment(MediaStore.self) private var media
    @ScaledMetric(relativeTo: .largeTitle) private var scale: CGFloat = 1

    private var scaledSize: CGFloat { size * min(scale, 1.4) }

    var body: some View {
        if let url = media.existingURL(for: .photo, stepID: step.id),
           let image = PhotoCache.image(at: url, revision: media.revision) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: scaledSize, height: scaledSize)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius * 2))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardRadius * 2)
                        .stroke(Theme.secondaryButton, lineWidth: 4)
                )
                .accessibilityHidden(true)
        } else {
            Pictogram(symbol: step.symbol, size: size, animated: animated)
        }
    }
}
