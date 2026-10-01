import SwiftUI

enum Route: Hashable {
    case routine(Routine)
    case guide(Routine, startIndex: Int)
}

/// Pantalla 1: Agenda principal y avatar.
struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(RoutineStore.self) private var routines
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

                    if routines.visibleRoutines.isEmpty {
                        Label("Todavía no hay rutinas. Pídele a un adulto que agregue una.",
                              systemImage: "square.dashed")
                            .font(.title3.weight(.semibold))
                            .padding(Theme.spacing)
                            .frame(maxWidth: .infinity)
                            .background(Theme.retry.opacity(0.4), in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                    }

                    LazyVGrid(columns: columns, spacing: Theme.spacing) {
                        ForEach(routines.visibleRoutines) { routine in
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
                Label("Hoy: \(progress.doneTodayCount(of: routines.visibleRoutines)) de \(routines.visibleRoutines.count) rutinas",
                      systemImage: "calendar")
                    .font(.body.bold())
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer()
            adultSettingsButton
        }
    }

    /// Mantener presionado (y luego resolver la pregunta de `AdultGateView`) evita que el niño
    /// abra los ajustes por accidente.
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

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 56

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: routine.symbol)
                .font(.system(size: iconSize))
                .foregroundStyle(Theme.primary)
                .frame(height: iconSize * 1.25)
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
        .environment(RoutineStore())
        .fontDesign(.rounded)
}
