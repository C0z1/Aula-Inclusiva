import SwiftUI
import UserNotifications

/// Recordatorios locales («Es hora de tu rutina»). Nada sale del dispositivo.
enum ReminderService {
    private static var center: UNUserNotificationCenter { .current() }

    /// Pide permiso para mostrar notificaciones. Devuelve si quedó autorizado.
    static func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    /// Deja programados exactamente estos recordatorios (borra los nuestros que sobren).
    static func sync(_ reminders: [Reminder]) async {
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(Reminder.idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ours)

        guard !reminders.isEmpty, await isAuthorized() else { return }
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default

            var date = DateComponents()
            date.weekday = reminder.weekday
            date.hour = reminder.hour
            date.minute = reminder.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            try? await center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }
}

/// Mantiene los recordatorios al día con las rutinas visibles, sus planes y los ajustes.
private struct ReminderSync: ViewModifier {
    @Environment(RoutineStore.self) private var routines
    @Environment(SettingsStore.self) private var settings

    private var reminders: [Reminder] {
        guard settings.remindersEnabled else { return [] }
        return Reminder.plan(for: routines.visibleRoutines,
                             plan: routines.plan(for:),
                             minutes: settings.reminderMinutes(for:))
    }

    func body(content: Content) -> some View {
        content.task(id: reminders) {
            await ReminderService.sync(reminders)
        }
    }
}

extension View {
    func syncReminders() -> some View {
        modifier(ReminderSync())
    }
}
