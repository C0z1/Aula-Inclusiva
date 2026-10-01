import Foundation

/// Estampa del álbum de logros. Los logros son acumulativos: se ganan y nunca se pierden.
/// No hay rachas ni contadores que bajen.
struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let current: Int
    let target: Int

    var isEarned: Bool { current >= target }
    /// Fracción hacia la meta (1 si ya se ganó).
    var progress: Double { min(Double(current) / Double(max(target, 1)), 1) }
}

enum AchievementCatalog {
    static let routineMilestones = [1, 3, 5, 10, 20, 30, 50, 100]
    static let totalMilestones = [1, 5, 10, 25, 50, 100, 200]
    static let stepMilestones = [10, 30, 60, 100, 200, 500]

    /// Álbum completo: todas las estampas ganadas y, en cada serie, la siguiente por ganar.
    static func album(
        routines: [Routine],
        timesDone: (Routine) -> Int,
        totalRoutines: Int,
        totalSteps: Int
    ) -> [Achievement] {
        var album: [Achievement] = []
        album += series(id: "total", milestones: totalMilestones, current: totalRoutines, symbol: "star.fill") { goal in
            (goal == 1 ? "Tu primera rutina" : "\(goal) rutinas", "Rutinas terminadas en total")
        }
        album += series(id: "pasos", milestones: stepMilestones, current: totalSteps, symbol: "figure.walk") { goal in
            ("\(goal) pasos", "Pasos hechos en el mundo real")
        }
        for routine in routines {
            album += series(id: "rutina.\(routine.id)", milestones: routineMilestones,
                            current: timesDone(routine), symbol: routine.symbol) { goal in
                (routine.title, goal == 1 ? "¡La primera vez!" : "\(goal) veces")
            }
        }
        return album
    }

    /// Ids de las estampas ganadas, para saber cuáles son nuevas al terminar una rutina.
    static func earnedIDs(
        routines: [Routine],
        timesDone: (Routine) -> Int,
        totalRoutines: Int,
        totalSteps: Int
    ) -> Set<String> {
        Set(album(routines: routines, timesDone: timesDone, totalRoutines: totalRoutines, totalSteps: totalSteps)
            .filter(\.isEarned)
            .map(\.id))
    }

    private static func series(
        id: String,
        milestones: [Int],
        current: Int,
        symbol: String,
        text: (Int) -> (title: String, detail: String)
    ) -> [Achievement] {
        var result: [Achievement] = []
        for goal in milestones {
            let (title, detail) = text(goal)
            result.append(Achievement(id: "\(id).\(goal)", title: title, detail: detail, symbol: symbol,
                                      current: current, target: goal))
            if goal > current { break } // Solo la siguiente meta, no todas las futuras.
        }
        return result
    }
}

/// Frases de ánimo variadas, positivas y neutrales en género.
enum Encouragement {
    static let stepDone = [
        "¡Muy bien!",
        "¡Excelente!",
        "¡Así se hace!",
        "¡Lo estás logrando!",
        "¡Qué buen trabajo!",
        "¡Bien hecho!",
        "¡Sigue así!"
    ]

    static let routineDone = [
        "¡Lo lograste!",
        "¡Terminaste!",
        "¡Lo hiciste por tu cuenta!",
        "¡Qué gran trabajo!",
        "¡Misión cumplida!"
    ]

    /// Elige una frase distinta de la última que se dijo.
    static func pick<G: RandomNumberGenerator>(from options: [String], avoiding last: String?,
                                               using generator: inout G) -> String {
        let choices = options.count > 1 ? options.filter { $0 != last } : options
        return choices.randomElement(using: &generator) ?? ""
    }

    static func pick(from options: [String], avoiding last: String? = nil) -> String {
        var generator = SystemRandomNumberGenerator()
        return pick(from: options, avoiding: last, using: &generator)
    }
}
