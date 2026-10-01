import SwiftUI

enum Route: Hashable {
    case routine(Routine)
    case guide(Routine, startIndex: Int)
}

/// Pantalla 1: Agenda principal y avatar.
struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(RoutineStore.self) private var routines
    @Environment(\.scenePhase) private var scenePhase
    @State private var path: [Route] = []
    @State private var showingAvatar = false
    @State private var showingAchievements = false
    @State private var showingSettings = false
    /// Hora con la que se arma la agenda; se actualiza cada minuto y al volver a la app.
    @State private var now = Date.now

    private let columns = [GridItem(.adaptive(minimum: 260), spacing: Theme.spacing)]

    private var current: Routine? {
        Agenda.current(in: routines.visibleRoutines,
                       plan: routines.plan(for:),
                       isDoneToday: { progress.isDoneToday($0, now: now) },
                       isInProgress: { progress.completedCount(in: $0) > 0 },
                       now: now)
    }

    private var scheduledToday: [Routine] {
        Agenda.scheduledToday(in: routines.visibleRoutines, plan: routines.plan(for:), now: now)
    }

    private var doneScheduledToday: Int {
        scheduledToday.filter { progress.isDoneToday($0, now: now) }.count
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    header

                    if let current {
                        NavigationLink(value: Route.routine(current)) {
                            NowCard(routine: current,
                                    moment: DayMoment.at(now),
                                    completed: progress.completedCount(in: current),
                                    after: routines.plan(for: current).afterActivity)
                        }
                        .buttonStyle(.plain)
                    } else if !scheduledToday.isEmpty, doneScheduledToday == scheduledToday.count {
                        Label("¡Terminaste todas tus rutinas de hoy!", systemImage: "star.circle.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.onSuccess)
                            .padding(Theme.spacing)
                            .frame(maxWidth: .infinity)
                            .background(Theme.success.opacity(0.35), in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                    }

                    Text(current == nil ? "¿Qué vas a hacer ahora?" : "Todas mis rutinas")
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
                                            doneToday: progress.isDoneToday(routine, now: now),
                                            plan: routines.plan(for: routine))
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
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                now = .now
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { now = .now }
        }
    }

    private var header: some View {
        HStack(spacing: Theme.spacing) {
            Button {
                showingAvatar = true
            } label: {
                AvatarView(progress: progress)
            }
            .accessibilityHint("Abre tu mascota para elegirla, ponerle nombre y accesorios")

            VStack(alignment: .leading, spacing: 8) {
                Text(DayMoment.at(now).greeting)
                    .font(.largeTitle.bold())
                Label("\(progress.medals) medalla\(progress.medals == 1 ? "" : "s")",
                      systemImage: "checkmark.seal.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                if !scheduledToday.isEmpty {
                    Label("Hoy: \(doneScheduledToday) de \(scheduledToday.count) rutinas",
                          systemImage: "calendar")
                        .font(.body.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            Spacer()
            Button {
                showingAchievements = true
            } label: {
                Label("Mis logros", systemImage: "book.closed.fill")
            }
            .buttonStyle(.secondary)
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
    let plan: RoutinePlan

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
            if let moment = plan.moments.min() {
                Label(plan.moments.sorted().map(\.title).joined(separator: " y "), systemImage: moment.symbol)
                    .font(.body.bold())
                    .foregroundStyle(Theme.primary)
            }
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

/// Tarjeta grande de la rutina que toca ahora, con su «Primero → Después».
private struct NowCard: View {
    let routine: Routine
    let moment: DayMoment
    let completed: Int
    let after: AfterActivity?

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 80

    var body: some View {
        HStack(alignment: .center, spacing: Theme.padding) {
            Image(systemName: routine.symbol)
                .font(.system(size: iconSize))
                .foregroundStyle(.white)
                .frame(width: iconSize * 1.5, height: iconSize * 1.5)
                .background(Theme.primary, in: RoundedRectangle(cornerRadius: Theme.cardRadius * 1.5))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 10) {
                Label("Ahora toca", systemImage: moment.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                Text(routine.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.leading)
                if completed > 0 {
                    Label("Vas en el paso \(completed + 1) de \(routine.steps.count)",
                          systemImage: "arrow.forward.circle.fill")
                        .font(.body.bold())
                        .foregroundStyle(Theme.primary)
                }
                if let after {
                    Label("Después: \(after.title)", systemImage: after.symbol)
                        .font(.body.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Theme.reward.opacity(0.3), in: Capsule())
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.forward.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.success)
                .accessibilityHidden(true)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius * 1.5))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius * 1.5)
                .stroke(Theme.primary, lineWidth: 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: Theme.cardRadius * 1.5))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Abre los pasos de la rutina que toca ahora")
    }
}

#Preview {
    HomeView()
        .environment(ProgressStore())
        .environment(SettingsStore())
        .environment(RoutineStore())
        .environment(MediaStore())
        .fontDesign(.rounded)
}
