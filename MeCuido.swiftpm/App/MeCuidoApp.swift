import SwiftUI

@main
struct MeCuidoApp: App {
    @State private var progress = ProgressStore()
    @State private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(progress)
                .environment(settings)
                .fontDesign(.rounded) // San Francisco Rounded en toda la app
                .tint(Theme.primary)
                // La paleta está pensada sobre fondos claros; en modo oscuro el texto quedaría ilegible.
                .preferredColorScheme(.light)
        }
    }
}
