import SwiftUI

/// Mascota del niño con el accesorio que haya elegido.
struct AvatarView: View {
    let accessory: Accessory?
    var size: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, Theme.primary)
                .frame(width: size, height: size)
            if let accessory {
                Image(systemName: accessory.symbol)
                    .font(.system(size: size * 0.28))
                    .foregroundStyle(Theme.reward)
                    .padding(size * 0.06)
                    .background(.white, in: Circle())
                    .offset(x: size * 0.08, y: -size * 0.08)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessory.map { "Tu mascota con \($0.name)" } ?? "Tu mascota")
    }
}
