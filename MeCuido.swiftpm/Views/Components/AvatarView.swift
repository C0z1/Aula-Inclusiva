import SwiftUI

/// Mascota del niño sobre su fondo, con el accesorio que haya elegido.
struct AvatarView: View {
    let pet: Pet
    var name: String? = nil
    let accessory: Accessory?
    var backdrop: Backdrop = Backdrop.all[0]
    var size: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: backdrop.top), Color(hex: backdrop.bottom)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(Circle().stroke(Theme.primary, lineWidth: max(size * 0.03, 2)))
                .overlay(
                    Image(systemName: pet.symbol)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Theme.primary)
                        .padding(size * 0.22)
                )
                .frame(width: size, height: size)
            if let accessory {
                Image(systemName: accessory.symbol)
                    .font(.system(size: size * 0.24))
                    .foregroundStyle(Theme.reward)
                    .padding(size * 0.06)
                    .background(.white, in: Circle())
                    .overlay(Circle().stroke(Theme.secondaryButton, lineWidth: 2))
                    .offset(x: size * 0.08, y: -size * 0.08)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var text = "Tu mascota"
        if let name { text += " \(name)" }
        if let accessory { text += " con \(accessory.name)" }
        return text
    }
}

extension AvatarView {
    /// La mascota tal como la tiene el niño ahora.
    init(progress: ProgressStore, size: CGFloat = 120) {
        self.init(pet: progress.pet, name: progress.displayPetName, accessory: progress.equippedAccessory,
                  backdrop: progress.backdrop, size: size)
    }
}
