import Foundation

/// «¿Qué sigue?»: el niño toca los pasos de su rutina en el orden en que los hará.
/// No se puede perder: un toque fuera de orden solo da una pista y, a la segunda,
/// se resalta la carta correcta para que nunca se quede trabado.
struct SequenceGame {
    enum TapResult: Equatable {
        /// Era el que seguía; se coloca en su casilla.
        case placed
        /// Va después; se da una pista.
        case hint
        /// Se colocó el último paso.
        case finished
        /// Carta ya colocada o juego terminado: no pasa nada.
        case ignored
    }

    static let minSteps = 2
    /// Pistas en la misma casilla a partir de las cuales se resalta la carta correcta.
    static let hintsBeforeHighlight = 2

    /// Pasos en el orden correcto.
    let steps: [RoutineStep]
    /// Las mismas cartas revueltas, nunca en el orden correcto.
    let cards: [RoutineStep]
    private(set) var placedCount = 0
    private(set) var hintsForCurrent = 0

    /// nil si la rutina tiene menos de `minSteps` pasos (no hay nada que ordenar).
    init?<G: RandomNumberGenerator>(steps: [RoutineStep], using generator: inout G) {
        guard steps.count >= Self.minSteps else { return nil }
        self.steps = steps
        var cards = steps.shuffled(using: &generator)
        if cards.map(\.id) == steps.map(\.id) {
            // Rotar uno basta para que quede en otro orden.
            cards = Array(cards.dropFirst()) + [cards[0]]
        }
        self.cards = cards
    }

    var isFinished: Bool { placedCount == steps.count }

    /// El paso que va en la siguiente casilla.
    var nextStep: RoutineStep? { isFinished ? nil : steps[placedCount] }

    /// Número (desde 1) de la casilla que se está llenando.
    var currentSlot: Int { min(placedCount + 1, steps.count) }

    func isPlaced(_ stepID: String) -> Bool {
        steps.prefix(placedCount).contains { $0.id == stepID }
    }

    /// Resaltar la carta correcta tras varias pistas en la misma casilla.
    func isHighlighted(_ stepID: String) -> Bool {
        hintsForCurrent >= Self.hintsBeforeHighlight && nextStep?.id == stepID
    }

    @discardableResult
    mutating func tap(_ stepID: String) -> TapResult {
        guard let next = nextStep, !isPlaced(stepID) else { return .ignored }
        guard stepID == next.id else {
            hintsForCurrent += 1
            return .hint
        }
        placedCount += 1
        hintsForCurrent = 0
        return isFinished ? .finished : .placed
    }
}
