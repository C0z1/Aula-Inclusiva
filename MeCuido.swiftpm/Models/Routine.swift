import Foundation

/// Un paso de una rutina. La app muestra el "cómo"; el niño lo hace en el mundo real.
/// El `id` nunca cambia: el progreso guardado depende de él.
struct RoutineStep: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    /// Instrucción corta que se narra en voz alta.
    var instruction: String
    /// SF Symbol que funciona como pictograma.
    var symbol: String
    /// Tiempo sugerido en segundos (ajustable por el niño, sin penalización).
    var suggestedSeconds: Int
}

struct Routine: Identifiable, Hashable, Codable {
    enum Category: String, CaseIterable, Identifiable, Codable {
        case organizarme = "Organizarme"
        case cuidarme = "Cuidarme"

        var id: String { rawValue }
    }

    let id: String
    var title: String
    var symbol: String
    var category: Category
    var steps: [RoutineStep]
}

extension Routine {
    /// Rutinas iniciales definidas en el documento de diseño.
    static let all: [Routine] = [
        Routine(
            id: "agujetas",
            title: "Atarme las agujetas",
            symbol: "shoe.fill",
            category: .organizarme,
            steps: [
                RoutineStep(id: "agujetas.1", title: "Cruzar las agujetas",
                            instruction: "Toma una agujeta en cada mano y crúzalas formando una equis.",
                            symbol: "xmark", suggestedSeconds: 30),
                RoutineStep(id: "agujetas.2", title: "Hacer las orejitas de conejo",
                            instruction: "Haz una orejita con cada agujeta, como las orejas de un conejo.",
                            symbol: "hare.fill", suggestedSeconds: 45),
                RoutineStep(id: "agujetas.3", title: "Apretar el nudo",
                            instruction: "Cruza las orejitas, pasa una por debajo y jala las dos con fuerza.",
                            symbol: "hand.raised.fill", suggestedSeconds: 30)
            ]
        ),
        Routine(
            id: "mochila",
            title: "Ordenar mi mochila",
            symbol: "backpack.fill",
            category: .organizarme,
            steps: [
                RoutineStep(id: "mochila.1", title: "Sacar todo",
                            instruction: "Saca todas las cosas de tu mochila y ponlas sobre la mesa.",
                            symbol: "tray.and.arrow.up.fill", suggestedSeconds: 60),
                RoutineStep(id: "mochila.2", title: "Guardar cuadernos y libros",
                            instruction: "Mete primero los cuadernos y libros que usarás mañana.",
                            symbol: "books.vertical.fill", suggestedSeconds: 90),
                RoutineStep(id: "mochila.3", title: "Guardar el estuche",
                            instruction: "Revisa que tu estuche tenga lápiz, goma y colores, y guárdalo.",
                            symbol: "pencil.and.ruler.fill", suggestedSeconds: 60)
            ]
        ),
        Routine(
            id: "cama",
            title: "Tender mi cama",
            symbol: "bed.double.fill",
            category: .organizarme,
            steps: [
                RoutineStep(id: "cama.1", title: "Estirar la sábana",
                            instruction: "Jala la sábana hacia arriba hasta la almohada y estírala.",
                            symbol: "arrow.up.and.down", suggestedSeconds: 60),
                RoutineStep(id: "cama.2", title: "Acomodar la cobija",
                            instruction: "Pon la cobija encima y estírala para que no tenga arrugas.",
                            symbol: "square.stack.fill", suggestedSeconds: 60),
                RoutineStep(id: "cama.3", title: "Poner la almohada",
                            instruction: "Sacude tu almohada y colócala en la cabecera.",
                            symbol: "rectangle.fill", suggestedSeconds: 30)
            ]
        ),
        Routine(
            id: "manos",
            title: "Lavarme las manos",
            symbol: "hands.sparkles.fill",
            category: .cuidarme,
            steps: [
                RoutineStep(id: "manos.1", title: "Mojar las manos",
                            instruction: "Abre la llave y moja tus manos con agua.",
                            symbol: "drop.fill", suggestedSeconds: 15),
                RoutineStep(id: "manos.2", title: "Tallar con jabón",
                            instruction: "Pon jabón y talla tus palmas, dedos y uñas mientras cuentas hasta veinte.",
                            symbol: "bubbles.and.sparkles.fill", suggestedSeconds: 20),
                RoutineStep(id: "manos.3", title: "Enjuagar y secar",
                            instruction: "Enjuaga el jabón, cierra la llave y seca tus manos con la toalla.",
                            symbol: "wind", suggestedSeconds: 30)
            ]
        ),
        Routine(
            id: "herida",
            title: "Curar una herida pequeña",
            symbol: "bandage.fill",
            category: .cuidarme,
            steps: [
                RoutineStep(id: "herida.1", title: "Avisar a un adulto",
                            instruction: "Cuéntale a un adulto que te lastimaste. Pedir ayuda está muy bien.",
                            symbol: "person.2.fill", suggestedSeconds: 30),
                RoutineStep(id: "herida.2", title: "Lavar con agua y jabón",
                            instruction: "Lava la herida con cuidado usando agua y un poco de jabón.",
                            symbol: "drop.fill", suggestedSeconds: 45),
                RoutineStep(id: "herida.3", title: "Poner una curita",
                            instruction: "Seca con suavidad y pon una curita sobre la herida.",
                            symbol: "bandage.fill", suggestedSeconds: 30)
            ]
        )
    ]
}
