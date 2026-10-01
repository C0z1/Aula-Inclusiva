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
