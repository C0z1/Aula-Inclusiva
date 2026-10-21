import Foundation

/// Lo que dicen los juegos: una instrucción a la vez, positiva y neutral en género.
/// Nunca «mal», «incorrecto» ni «perdiste».
enum GameLines {
    static let sequenceIntro = "Toca los pasos en el orden en que los vas a hacer. ¿Cuál va primero?"

    static func sequencePlaced(slot: Int, title: String) -> String {
        "¡Así es! \(slot). \(title)."
    }

    /// Primera pista: invita a pensar sin decir la respuesta.
    static func sequenceHint(slot: Int) -> String {
        slot == 1 ? "Ese va después. Piensa: ¿qué haces primero?" : "Ese va después. ¿Qué haces ahora?"
    }

    /// A partir de la segunda pista se dice cuál es (y se resalta).
    static func sequenceReveal(title: String) -> String {
        "Es este: \(title). ¡Tócalo!"
    }

    static func sequenceFinished(titles: [String]) -> String {
        "¡Lo ordenaste todo! \(summary(titles))"
    }

    /// «Primero A, luego B y al final C.»
    static func summary(_ titles: [String]) -> String {
        switch titles.count {
        case 0: return ""
        case 1: return "Primero, \(titles[0])."
        case 2: return "Primero, \(titles[0]), y después, \(titles[1])."
        default:
            let middle = titles.dropFirst().dropLast().map { "luego, \($0)" }.joined(separator: "; ")
            return "Primero, \(titles[0]); \(middle); y al final, \(titles[titles.count - 1])."
        }
    }
}
