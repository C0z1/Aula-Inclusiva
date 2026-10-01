import Foundation

/// Momento del día en que toca una rutina.
enum DayMoment: String, CaseIterable, Identifiable, Codable, Comparable {
    case morning, afternoon, night

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "Mañana"
        case .afternoon: "Tarde"
        case .night: "Noche"
        }
    }

    var greeting: String {
        switch self {
        case .morning: "¡Buenos días!"
        case .afternoon: "¡Buenas tardes!"
        case .night: "¡Buenas noches!"
        }
    }

    var symbol: String {
        switch self {
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .night: "moon.stars.fill"
        }
    }

    /// Hora sugerida para el recordatorio (minutos desde la medianoche).
    var defaultReminderMinutes: Int {
        switch self {
        case .morning: 7 * 60 + 30
        case .afternoon: 16 * 60
        case .night: 20 * 60
        }
    }

    /// Mañana 5:00–11:59, tarde 12:00–18:59, noche 19:00–4:59.
    static func at(_ date: Date, calendar: Calendar = .current) -> DayMoment {
        switch calendar.component(.hour, from: date) {
        case 5..<12: .morning
        case 12..<19: .afternoon
        default: .night
        }
    }

    static func < (lhs: DayMoment, rhs: DayMoment) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

/// Actividad agradable que viene después de la rutina (tablero «Primero → Después»).
struct AfterActivity: Hashable, Codable {
    var title: String
    var symbol: String

    static let suggestions: [AfterActivity] = [
        AfterActivity(title: "Jugar", symbol: "gamecontroller.fill"),
        AfterActivity(title: "Ver la tele", symbol: "tv.fill"),
        AfterActivity(title: "Dibujar", symbol: "paintbrush.fill"),
        AfterActivity(title: "Leer un cuento", symbol: "book.fill"),
        AfterActivity(title: "Salir al parque", symbol: "figure.play"),
        AfterActivity(title: "Escuchar música", symbol: "music.note"),
        AfterActivity(title: "Desayunar", symbol: "fork.knife"),
        AfterActivity(title: "Ir a la escuela", symbol: "building.columns.fill"),
        AfterActivity(title: "Dormir", symbol: "moon.zzz.fill")
    ]
}

/// Cuándo toca una rutina y qué la acompaña. Lo configura un adulto.
struct RoutinePlan: Hashable, Codable {
    /// Vacío = «cuando se necesite»: aparece en la agenda pero nunca como «Ahora toca».
    var moments: Set<DayMoment>
    /// Días de la semana según `Calendar` (1 = domingo … 7 = sábado).
    var weekdays: Set<Int>
    var afterActivity: AfterActivity?
    /// Al terminar, una pantalla para revisar que no se olvidó ningún paso.
    var reviewEnabled: Bool

    static let everyDay: Set<Int> = Set(1...7)
    /// Noches antes de un día de escuela (domingo a jueves).
    static let schoolNights: Set<Int> = [1, 2, 3, 4, 5]

    static let anytime = RoutinePlan(moments: [], weekdays: everyDay, afterActivity: nil, reviewEnabled: false)

    var isAnytime: Bool { moments.isEmpty }

    func isScheduled(onWeekday weekday: Int) -> Bool {
        !moments.isEmpty && weekdays.contains(weekday)
    }

    func isScheduled(onWeekday weekday: Int, at moment: DayMoment) -> Bool {
        moments.contains(moment) && weekdays.contains(weekday)
    }

    /// Plan de fábrica de las rutinas incluidas; las personalizadas empiezan en `anytime`.
    static func defaultPlan(for routineID: String) -> RoutinePlan {
        switch routineID {
        case "agujetas", "cama":
            RoutinePlan(moments: [.morning], weekdays: everyDay, afterActivity: nil, reviewEnabled: false)
        case "mochila":
            RoutinePlan(moments: [.night], weekdays: schoolNights, afterActivity: nil, reviewEnabled: true)
        default:
            .anytime
        }
    }
}

/// Reglas de la agenda del día. Funciones puras para poder probarlas.
enum Agenda {
    /// La rutina que toca ahora: programada para este momento y día, y todavía no hecha hoy.
    /// Si alguna ya va empezada, tiene prioridad.
    static func current(
        in routines: [Routine],
        plan: (Routine) -> RoutinePlan,
        isDoneToday: (Routine) -> Bool,
        isInProgress: (Routine) -> Bool,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Routine? {
        let moment = DayMoment.at(now, calendar: calendar)
        let weekday = calendar.component(.weekday, from: now)
        let due = routines.filter {
            plan($0).isScheduled(onWeekday: weekday, at: moment) && !isDoneToday($0)
        }
        return due.first(where: isInProgress) ?? due.first
    }

    /// Rutinas programadas para hoy (en cualquier momento), en orden mañana → noche.
    static func scheduledToday(
        in routines: [Routine],
        plan: (Routine) -> RoutinePlan,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Routine] {
        let weekday = calendar.component(.weekday, from: now)
        return routines
            .filter { plan($0).isScheduled(onWeekday: weekday) }
            .sorted { (plan($0).moments.min() ?? .night) < (plan($1).moments.min() ?? .night) }
    }
}

/// Un recordatorio local: uno por momento y día de la semana, con todas las rutinas que tocan.
struct Reminder: Hashable {
    static let idPrefix = "mecuido.recordatorio."

    let weekday: Int
    let moment: DayMoment
    let hour: Int
    let minute: Int
    let title: String
    let body: String

    var id: String { "\(Self.idPrefix)\(moment.rawValue).\(weekday)" }

    /// Planea los recordatorios de la semana. Como máximo 3 × 7 = 21 (iOS permite 64 pendientes).
    static func plan(
        for routines: [Routine],
        plan: (Routine) -> RoutinePlan,
        minutes: (DayMoment) -> Int
    ) -> [Reminder] {
        var reminders: [Reminder] = []
        for weekday in 1...7 {
            for moment in DayMoment.allCases {
                let titles = routines
                    .filter { plan($0).isScheduled(onWeekday: weekday, at: moment) }
                    .map(\.title)
                guard !titles.isEmpty else { continue }
                let time = minutes(moment)
                reminders.append(Reminder(
                    weekday: weekday,
                    moment: moment,
                    hour: time / 60,
                    minute: time % 60,
                    title: "Es hora de tu rutina",
                    body: "\(moment.greeting) Toca: \(listed(titles))."
                ))
            }
        }
        return reminders
    }

    /// «A», «A y B», «A, B y C».
    static func listed(_ items: [String]) -> String {
        switch items.count {
        case 0: ""
        case 1: items[0]
        default: items.dropLast().joined(separator: ", ") + " y " + items.last!
        }
    }
}

/// Nombres de los días según `Calendar` (1 = domingo … 7 = sábado).
enum Weekday {
    /// Orden para mostrar: la semana empieza en lunes.
    static let displayOrder = [2, 3, 4, 5, 6, 7, 1]

    private static let short = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"]
    private static let full = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"]
    private static let letters = ["D", "L", "M", "M", "J", "V", "S"]

    static func shortName(_ weekday: Int) -> String { short[weekday - 1] }
    static func fullName(_ weekday: Int) -> String { full[weekday - 1] }
    static func letter(_ weekday: Int) -> String { letters[weekday - 1] }

    /// «todos los días», «lun a vie», «dom a jue», «fines de semana», «lun y mié».
    static func describe(_ weekdays: Set<Int>) -> String {
        switch weekdays {
        case []: return "ningún día"
        case RoutinePlan.everyDay: return "todos los días"
        case [1, 7]: return "fines de semana"
        default: break
        }
        if weekdays.count >= 3, let run = cyclicRun(weekdays) {
            return "\(shortName(run.first)) a \(shortName(run.last))"
        }
        return Reminder.listed(displayOrder.filter(weekdays.contains).map(shortName))
    }

    /// Si los días forman un solo tramo seguido (contando de sábado a domingo), su inicio y fin.
    private static func cyclicRun(_ weekdays: Set<Int>) -> (first: Int, last: Int)? {
        let next = { (day: Int) in day == 7 ? 1 : day + 1 }
        let previous = { (day: Int) in day == 1 ? 7 : day - 1 }
        guard let start = weekdays.first(where: { !weekdays.contains(previous($0)) }) else { return nil }
        var end = start
        var length = 1
        while weekdays.contains(next(end)) && length < weekdays.count {
            end = next(end)
            length += 1
        }
        return length == weekdays.count ? (start, end) : nil
    }
}

extension RoutinePlan {
    /// Resumen para la lista de adultos: «Mañana · todos los días», «Cuando se necesite».
    var summary: String {
        if isAnytime { return "Cuando se necesite" }
        let when = moments.sorted().map(\.title).joined(separator: " y ")
        return "\(when) · \(Weekday.describe(weekdays))"
    }
}
