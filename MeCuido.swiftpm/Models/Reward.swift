import Foundation

/// Accesorios del avatar que se desbloquean al terminar rutinas en el mundo real.
struct Accessory: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    /// Número de medallas necesarias para desbloquearlo.
    let medalsRequired: Int

    static let all: [Accessory] = [
        Accessory(id: "estrella", name: "Estrella", symbol: "star.fill", medalsRequired: 1),
        Accessory(id: "gorra", name: "Gorra", symbol: "graduationcap.fill", medalsRequired: 3),
        Accessory(id: "corazon", name: "Corazón", symbol: "heart.fill", medalsRequired: 5),
        Accessory(id: "corona", name: "Corona", symbol: "crown.fill", medalsRequired: 8),
        Accessory(id: "cohete", name: "Cohete", symbol: "paperplane.fill", medalsRequired: 12)
    ]
}
