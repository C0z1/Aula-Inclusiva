import SwiftUI

/// Pictograma grande del paso. Pulsa suavemente para atraer la atención,
/// salvo que el niño tenga activado "Reducir movimiento".
struct Pictogram: View {
    let symbol: String
    var size: CGFloat = 220
    var animated = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Theme.primary)
            .padding(size * 0.2)
            .frame(width: size, height: size)
            .background(Theme.secondaryButton, in: RoundedRectangle(cornerRadius: Theme.cardRadius * 2))
            .symbolEffect(.pulse, options: .repeating, isActive: animated && !reduceMotion)
            .accessibilityHidden(true)
    }
}
