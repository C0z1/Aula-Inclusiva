import Foundation

/// Verificación para entrar a los ajustes de adultos: una multiplicación de dos cifras por una.
/// Evita que el niño cambie ajustes por accidente (y cumple el «parental gate» de App Store).
struct AdultGate: Equatable {
    let left: Int
    let right: Int

    var answer: Int { left * right }
    var question: String { "¿Cuánto es \(left) × \(right)?" }
    var spokenQuestion: String { "¿Cuánto es \(left) por \(right)?" }

    /// Máximo de cifras que acepta la respuesta.
    static let maxDigits = 3

    init(left: Int, right: Int) {
        self.left = left
        self.right = right
    }

    /// Pregunta nueva: 12…29 × 3…9 (resultado de dos o tres cifras).
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> AdultGate {
        AdultGate(left: Int.random(in: 12...29, using: &generator),
                  right: Int.random(in: 3...9, using: &generator))
    }

    static func random() -> AdultGate {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }

    func isCorrect(_ input: String) -> Bool {
        Int(input.trimmingCharacters(in: .whitespaces)) == answer
    }
}
