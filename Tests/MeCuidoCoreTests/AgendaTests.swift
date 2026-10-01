import XCTest
@testable import MeCuidoCore

final class AgendaTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Mexico_City")!
        return calendar
    }()

    /// 1 de octubre de 2026 es jueves (weekday 5).
    private func date(day: Int = 1, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))!
    }

    private func routine(_ id: String) -> Routine {
        Routine.all.first { $0.id == id }!
    }

    // MARK: - Momentos

    func testDayMomentBoundaries() {
        XCTAssertEqual(DayMoment.at(date(hour: 4, minute: 59), calendar: calendar), .night)
        XCTAssertEqual(DayMoment.at(date(hour: 5), calendar: calendar), .morning)
        XCTAssertEqual(DayMoment.at(date(hour: 11, minute: 59), calendar: calendar), .morning)
        XCTAssertEqual(DayMoment.at(date(hour: 12), calendar: calendar), .afternoon)
        XCTAssertEqual(DayMoment.at(date(hour: 18, minute: 59), calendar: calendar), .afternoon)
        XCTAssertEqual(DayMoment.at(date(hour: 19), calendar: calendar), .night)
    }

    func testMomentsAreOrdered() {
        XCTAssertEqual(DayMoment.allCases.sorted(), [.morning, .afternoon, .night])
    }

    // MARK: - Planes de fábrica

    func testDefaultPlans() {
        XCTAssertEqual(RoutinePlan.defaultPlan(for: "cama").moments, [.morning])
        XCTAssertEqual(RoutinePlan.defaultPlan(for: "mochila").moments, [.night])
        XCTAssertFalse(RoutinePlan.defaultPlan(for: "mochila").weekdays.contains(6),
                       "El viernes en la noche no hay que preparar la mochila")
        XCTAssertTrue(RoutinePlan.defaultPlan(for: "mochila").reviewEnabled)
        XCTAssertTrue(RoutinePlan.defaultPlan(for: "herida").isAnytime,
                      "Curar una herida es cuando se necesita, nunca «Ahora toca»")
        XCTAssertEqual(RoutinePlan.defaultPlan(for: "custom-x"), .anytime)
    }

    // MARK: - Ahora toca

    private func current(at now: Date, done: Set<String> = [], inProgress: Set<String> = []) -> Routine? {
        Agenda.current(in: Routine.all,
                       plan: { RoutinePlan.defaultPlan(for: $0.id) },
                       isDoneToday: { done.contains($0.id) },
                       isInProgress: { inProgress.contains($0.id) },
                       now: now, calendar: calendar)
    }

    func testMorningPicksFirstMorningRoutine() {
        XCTAssertEqual(current(at: date(hour: 7))?.id, "agujetas")
    }

    func testSkipsRoutinesDoneToday() {
        XCTAssertEqual(current(at: date(hour: 7), done: ["agujetas"])?.id, "cama")
        XCTAssertNil(current(at: date(hour: 7), done: ["agujetas", "cama"]))
    }

    func testRoutineInProgressHasPriority() {
        XCTAssertEqual(current(at: date(hour: 7), inProgress: ["cama"])?.id, "cama")
    }

    func testNightOnSchoolNightOnly() {
        XCTAssertEqual(current(at: date(day: 1, hour: 20))?.id, "mochila") // jueves
        XCTAssertNil(current(at: date(day: 2, hour: 20)))                   // viernes
    }

    func testNothingDueInTheAfternoonByDefault() {
        XCTAssertNil(current(at: date(hour: 15)))
    }

    func testScheduledTodayIsSortedByMoment() {
        let today = Agenda.scheduledToday(in: Routine.all.reversed(),
                                          plan: { RoutinePlan.defaultPlan(for: $0.id) },
                                          now: date(hour: 10), calendar: calendar)
        XCTAssertEqual(today.map(\.id), ["cama", "agujetas", "mochila"])
    }

    // MARK: - Recordatorios

    func testRemindersGroupRoutinesPerMomentAndDay() {
        let reminders = Reminder.plan(for: Routine.all,
                                      plan: { RoutinePlan.defaultPlan(for: $0.id) },
                                      minutes: { $0.defaultReminderMinutes })
        // 7 mañanas + 5 noches de escuela.
        XCTAssertEqual(reminders.count, 12)
        XCTAssertEqual(Set(reminders.map(\.id)).count, reminders.count)

        let thursdayMorning = reminders.first { $0.weekday == 5 && $0.moment == .morning }
        XCTAssertEqual(thursdayMorning?.hour, 7)
        XCTAssertEqual(thursdayMorning?.minute, 30)
        XCTAssertEqual(thursdayMorning?.body, "¡Buenos días! Toca: Atarme las agujetas y Tender mi cama.")
        XCTAssertTrue(reminders.allSatisfy { $0.id.hasPrefix(Reminder.idPrefix) })
    }

    func testRemindersNeverExceedIOSLimit() {
        let everything = RoutinePlan(moments: Set(DayMoment.allCases), weekdays: RoutinePlan.everyDay,
                                     afterActivity: nil, reviewEnabled: false)
        let reminders = Reminder.plan(for: Routine.all, plan: { _ in everything }, minutes: { _ in 60 })
        XCTAssertEqual(reminders.count, 21)
        XCTAssertLessThanOrEqual(reminders.count, 64)
    }

    func testListedJoinsInSpanish() {
        XCTAssertEqual(Reminder.listed(["A"]), "A")
        XCTAssertEqual(Reminder.listed(["A", "B"]), "A y B")
        XCTAssertEqual(Reminder.listed(["A", "B", "C"]), "A, B y C")
    }

    // MARK: - Ajustes de recordatorios

    func testReminderSettingsPersist() {
        let defaults = makeTestDefaults()
        let settings = SettingsStore(defaults: defaults)
        XCTAssertFalse(settings.remindersEnabled, "Los recordatorios se activan solo si un adulto lo pide")
        XCTAssertEqual(settings.reminderMinutes(for: .night), 20 * 60)

        settings.remindersEnabled = true
        settings.setReminderMinutes(19 * 60 + 15, for: .night)
        settings.setReminderMinutes(99_999, for: .morning)

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertTrue(reloaded.remindersEnabled)
        XCTAssertEqual(reloaded.reminderMinutes(for: .night), 19 * 60 + 15)
        XCTAssertEqual(reloaded.reminderMinutes(for: .morning), 24 * 60 - 1)
        XCTAssertEqual(reloaded.reminderMinutes(for: .afternoon), 16 * 60)
    }
}

final class RoutinePlanStoreTests: XCTestCase {
    private var directory: URL!

    override func setUp() {
        super.setUp()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("mecuido-plan-\(UUID().uuidString)")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    private func makeStore(_ name: String = "rutinas.json") -> RoutineStore {
        RoutineStore(fileURL: directory.appendingPathComponent(name))
    }

    func testBuiltInsStartWithDefaultPlan() {
        let store = makeStore()
        XCTAssertEqual(store.plan(for: Routine.all[1]), RoutinePlan.defaultPlan(for: "mochila"))
        XCTAssertTrue(store.plans.isEmpty)
    }

    func testChangingPlanPersistsAndResettingRemovesOverride() {
        let store = makeStore()
        let cama = Routine.all[2]
        var plan = store.plan(for: cama)
        plan.afterActivity = AfterActivity(title: "  Desayunar ", symbol: "fork.knife")
        store.setPlan(plan, for: cama)

        let reloaded = makeStore()
        XCTAssertEqual(reloaded.plan(for: cama).afterActivity?.title, "Desayunar")

        reloaded.setPlan(RoutinePlan.defaultPlan(for: cama.id), for: cama)
        XCTAssertTrue(reloaded.plans.isEmpty, "Volver al plan de fábrica no deja datos de más")
    }

    func testBlankAfterActivityIsRemoved() {
        let store = makeStore()
        var plan = RoutinePlan.anytime
        plan.afterActivity = AfterActivity(title: "   ", symbol: "star.fill")
        let routine = store.createRoutine()
        store.setPlan(plan, for: routine)
        XCTAssertNil(store.plan(for: routine).afterActivity)
    }

    func testPlanForUnknownRoutineIsIgnored() {
        let store = makeStore()
        let ghost = Routine(id: "no-existe", title: "", symbol: "", category: .cuidarme, steps: [])
        store.setPlan(RoutinePlan.defaultPlan(for: "cama"), for: ghost)
        XCTAssertTrue(store.plans.isEmpty)
    }

    func testDuplicateCopiesPlanAndDeleteRemovesIt() {
        let store = makeStore()
        let copy = store.duplicate(Routine.all[1])
        XCTAssertEqual(store.plan(for: copy), RoutinePlan.defaultPlan(for: "mochila"))
        store.delete(copy)
        XCTAssertNil(store.plans[copy.id])
    }

    func testReadsVersionOneFiles() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let v1 = #"{"version":1,"customRoutines":[],"hiddenIDs":["cama"]}"#
        try Data(v1.utf8).write(to: directory.appendingPathComponent("rutinas.json"))
        let store = makeStore()
        XCTAssertTrue(store.isHidden(Routine.all[2]))
        XCTAssertTrue(store.plans.isEmpty)
    }

    func testBackupCarriesPlans() throws {
        let source = makeStore()
        var plan = RoutinePlan.anytime
        plan.moments = [.afternoon]
        source.setPlan(plan, for: Routine.all[3])

        let target = makeStore("otro.json")
        try target.importData(source.exportData())
        XCTAssertEqual(target.plan(for: Routine.all[3]).moments, [.afternoon])
    }
}

final class PlanSummaryTests: XCTestCase {
    func testWeekdayDescriptions() {
        XCTAssertEqual(Weekday.describe(RoutinePlan.everyDay), "todos los días")
        XCTAssertEqual(Weekday.describe([2, 3, 4, 5, 6]), "lun a vie")
        XCTAssertEqual(Weekday.describe(RoutinePlan.schoolNights), "dom a jue")
        XCTAssertEqual(Weekday.describe([1, 7]), "fines de semana")
        XCTAssertEqual(Weekday.describe([6, 7, 1]), "vie a dom")
        XCTAssertEqual(Weekday.describe([2, 4]), "lun y mié")
        XCTAssertEqual(Weekday.describe([2, 4, 6]), "lun, mié y vie")
        XCTAssertEqual(Weekday.describe([]), "ningún día")
    }

    func testPlanSummaries() {
        XCTAssertEqual(RoutinePlan.defaultPlan(for: "cama").summary, "Mañana · todos los días")
        XCTAssertEqual(RoutinePlan.defaultPlan(for: "mochila").summary, "Noche · dom a jue")
        XCTAssertEqual(RoutinePlan.anytime.summary, "Cuando se necesite")
        let twice = RoutinePlan(moments: [.night, .morning], weekdays: [1, 7], afterActivity: nil, reviewEnabled: false)
        XCTAssertEqual(twice.summary, "Mañana y Noche · fines de semana")
    }
}
