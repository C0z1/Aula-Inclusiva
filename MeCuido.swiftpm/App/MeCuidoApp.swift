import SwiftUI

@main
struct MeCuidoApp: App {
    @State private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(progress)
                .fontDesign(.rounded) // San Francisco Rounded en toda la app
                .tint(Theme.primary)
        }
    }
}
