import Foundation

/// Accesorios del avatar que se desbloquean al terminar rutinas en el mundo real.
/// Curva amable: al principio llegan seguido, después más espaciados. Nunca se pierden.
/// Al agregar uno, no subir el `medalsRequired` de los existentes (se volverían a bloquear).
struct Accessory: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    /// Número de medallas necesarias para desbloquearlo.
    let medalsRequired: Int

    static let all: [Accessory] = [
        Accessory(id: "estrella", name: "Estrella", symbol: "star.fill", medalsRequired: 1),
        Accessory(id: "hojita", name: "Hojita", symbol: "leaf.fill", medalsRequired: 2),
        Accessory(id: "gorra", name: "Gorra", symbol: "graduationcap.fill", medalsRequired: 3),
        Accessory(id: "corazon", name: "Corazón", symbol: "heart.fill", medalsRequired: 5),
        Accessory(id: "corona", name: "Corona", symbol: "crown.fill", medalsRequired: 8),
        Accessory(id: "nota", name: "Nota musical", symbol: "music.note", medalsRequired: 10),
        // El id se conserva para no perder el accesorio que ya tenga puesto el niño.
        Accessory(id: "cohete", name: "Avión de papel", symbol: "paperplane.fill", medalsRequired: 12),
        Accessory(id: "arcoiris", name: "Arcoíris", symbol: "rainbow", medalsRequired: 15),
        Accessory(id: "regalo", name: "Regalo", symbol: "gift.fill", medalsRequired: 20),
        Accessory(id: "luna", name: "Luna y estrellas", symbol: "moon.stars.fill", medalsRequired: 25),
        Accessory(id: "rayo", name: "Rayo", symbol: "bolt.fill", medalsRequired: 30)
    ]
}

/// Mascota que acompaña al niño. Se puede elegir y ponerle nombre.
struct Pet: Identifiable, Hashable {
    let id: String
    /// Qué es («Perrito»), para elegirla.
    let kind: String
    let symbol: String
    /// Nombre si el niño no le pone otro.
    let defaultName: String

    static let all: [Pet] = [
        Pet(id: "huellita", kind: "Huellita", symbol: "pawprint.fill", defaultName: "Huellita"),
        Pet(id: "perrito", kind: "Perrito", symbol: "dog.fill", defaultName: "Canelo"),
        Pet(id: "gatito", kind: "Gatito", symbol: "cat.fill", defaultName: "Michi"),
        Pet(id: "conejito", kind: "Conejito", symbol: "hare.fill", defaultName: "Saltarín"),
        Pet(id: "tortuga", kind: "Tortuga", symbol: "tortoise.fill", defaultName: "Calma"),
        Pet(id: "pajarito", kind: "Pajarito", symbol: "bird.fill", defaultName: "Pío")
    ]

    static let nameMaxLength = 16
}

/// Fondo pastel detrás de la mascota. Colores claros para no perder contraste.
struct Backdrop: Identifiable, Hashable {
    let id: String
    let name: String
    /// Colores del degradado (de arriba a abajo), en hexadecimal RGB.
    let top: UInt32
    let bottom: UInt32
    let medalsRequired: Int

    static let all: [Backdrop] = [
        Backdrop(id: "cielo", name: "Cielo", top: 0xE3EEFB, bottom: 0xF6F9FE, medalsRequired: 0),
        Backdrop(id: "menta", name: "Menta", top: 0xD5F6EA, bottom: 0xF4FDF9, medalsRequired: 4),
        Backdrop(id: "atardecer", name: "Atardecer", top: 0xFFE3C2, bottom: 0xFFF6EA, medalsRequired: 9),
        Backdrop(id: "lavanda", name: "Lavanda", top: 0xE9E0FB, bottom: 0xF8F5FE, medalsRequired: 14),
        Backdrop(id: "sol", name: "Sol", top: 0xFFF0A8, bottom: 0xFFFBE6, medalsRequired: 18)
    ]
}
