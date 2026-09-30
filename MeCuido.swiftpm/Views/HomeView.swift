import SwiftUI

enum Route: Hashable {
    case routine(Routine)
    case guide(Routine, startIndex: Int)
}

/// Pantalla 1: Agenda principal y avatar.
struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    @State private var path: [Route] = []
    @State private var showingAvatar = false
    @State private var showingSettings = false

    private let columns = [GridItem(.adaptive(minimum: 260), spacing: Theme.spacing)]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    header

                    Text("¿Qué vas a hacer ahora?")
                        .font(.title2.weight(.semibold))

                    LazyVGrid(columns: columns, spacing: Theme.spacing) {
                        ForEach(Routine.all) { routine in
                            NavigationLink(value: Route.routine(routine)) {
                                RoutineCard(routine: routine,
                                            completed: progress.completedCount(in: routine),
                                            doneToday: progress.isDoneToday(routine))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(Theme.padding)
            }
            .background(Theme.background)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .routine(let routine):
                    RoutineStepsView(routine: routine)
                case .guide(let routine, let startIndex):
                    StepGuideView(routine: routine, startIndex: startIndex) {
                        path.removeAll()
                    }
                }
            }
            .sheet(isPresented: $showingAvatar) {
                AvatarPickerView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        HStack(spacing: Theme.spacing) {
            Button {
                showingAvatar = true
            } label: {
                AvatarView(accessory: progress.equippedAccessory)
            }
            .accessibilityHint("Abre tu mascota para ponerle accesorios")

            VStack(alignment: .leading, spacing: 8) {
                Text("¡Hola!")
                    .font(.largeTitle.bold())
                Label("\(progress.medals) medalla\(progress.medals == 1 ? "" : "s")",
                      systemImage: "checkmark.seal.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                Label("Hoy: \(progress.doneTodayCount(of: Routine.all)) de \(Routine.all.count) rutinas",
                      systemImage: "calendar")
                    .font(.body.bold())
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer()
            adultSettingsButton
        }
    }

    /// Mantener presionado evita que el niño abra los ajustes por accidente.
    private var adultSettingsButton: some View {
        Image(systemName: "gearshape.fill")
            .font(.title)
            .foregroundStyle(.secondary)
            .frame(width: Theme.minTarget, height: Theme.minTarget)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 2) { showingSettings = true }
            .accessibilityElement()
            .accessibilityLabel("Ajustes para adultos")
            .accessibilityHint("Mantén presionado dos segundos para abrir")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { showingSettings = true }
    }
}

private struct RoutineCard: View {
    let routine: Routine
    let completed: Int
    let doneToday: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: routine.symbol)
                .font(.system(size: 56))
                .foregroundStyle(Theme.primary)
                .frame(height: 70)
            Text(routine.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Text(routine.category.rawValue)
                .font(.body)
                .foregroundStyle(.secondary)
            if doneToday {
                Label("¡Hecha hoy!", systemImage: "checkmark.circle.fill")
                    .font(.body.bold())
                    .foregroundStyle(Theme.onSuccess)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Theme.success.opacity(0.35), in: Capsule())
            }
            if completed > 0 {
                Label("Vas en el paso \(completed + 1) de \(routine.steps.count)",
                      systemImage: "arrow.forward.circle.fill")
                    .font(.body.bold())
                    .foregroundStyle(Theme.primary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .padding(Theme.spacing)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(doneToday ? Theme.success : Theme.secondaryButton, lineWidth: doneToday ? 4 : 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Abre los pasos de esta rutina")
    }
}

#Preview {
    HomeView()
        .environment(ProgressStore())
        .environment(SettingsStore())
        .fontDesign(.rounded)
}
