import SwiftUI

/// Reglas visuales del documento de diseño (sección 7).
enum Theme {
    // Colores
    static let primary = Color(hex: 0x2A75D3)      // Azul azulado cálido: calma y confianza
    static let success = Color(hex: 0x06D6A0)      // Verde esperanza: éxito y llamadas a la acción
    static let pause = Color(hex: 0xFFE8A3)        // Amarillo pastel suave: alerta / pausa
    static let retry = Color(hex: 0xA9CBF2)        // Azul suave: reintento (nunca rojo)
    static let secondaryButton = Color(hex: 0xE3EEFB)
    static let background = Color(hex: 0xF6F9FE)
    static let onSuccess = Color(hex: 0x053B2C)    // Texto sobre verde (contraste ≥ 4.5:1; el blanco no alcanza)
    static let reward = Color(hex: 0xFFB800)       // Destellos y accesorios de recompensa

    // Espaciado amplio para evitar toques accidentales
    static let spacing: CGFloat = 24
    static let padding: CGFloat = 32

    // Formas
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 20

    // Área táctil mínima (documento: 60x60pt)
    static let minTarget: CGFloat = 60
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
