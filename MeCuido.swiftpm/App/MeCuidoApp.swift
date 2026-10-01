import SwiftUI

@main
struct MeCuidoApp: App {
    @State private var progress = ProgressStore()
    @State private var settings = SettingsStore()
    @State private var routines = RoutineStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .syncReminders()
                .environment(progress)
                .environment(settings)
                .environment(routines)
                .fontDesign(.rounded) // San Francisco Rounded en toda la app
                .tint(Theme.primary)
                // La paleta está pensada sobre fondos claros; en modo oscuro el texto quedaría ilegible.
                .preferredColorScheme(.light)
        }
    }
}
