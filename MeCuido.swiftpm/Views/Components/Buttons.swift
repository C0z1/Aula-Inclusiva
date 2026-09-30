import SwiftUI

/// Botón principal: cápsula verde grande con ícono de verificación.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .foregroundStyle(Theme.onSuccess)
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.horizontal, Theme.spacing)
            .background(Theme.success, in: RoundedRectangle(cornerRadius: Theme.buttonRadius))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Botón secundario: neutro/azul claro para "Escuchar de nuevo" o "Volver".
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .foregroundStyle(Theme.primary)
            .frame(minWidth: Theme.minTarget, minHeight: Theme.minTarget)
            .padding(.horizontal, 20)
            .background(Theme.secondaryButton, in: RoundedRectangle(cornerRadius: Theme.buttonRadius))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
