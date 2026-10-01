import SwiftUI

/// Pantalla 2: Mis pasos siguientes. Muestra la secuencia completa para dar estructura mental.
struct RoutineStepsView: View {
    let routine: Routine
    @Environment(ProgressStore.self) private var progress
    @Environment(RoutineStore.self) private var routines

    var body: some View {
        let nextIndex = progress.nextPendingIndex(in: routine) ?? 0

        VStack(alignment: .leading, spacing: Theme.padding) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Mis pasos siguientes")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                ProgressView(value: progress.progress(of: routine))
                    .tint(Theme.success)
                    .scaleEffect(y: 3)
                    .padding(.vertical, 8)
                    .accessibilityLabel("Progreso de la rutina")
                    .accessibilityValue("\(progress.completedCount(in: routine)) de \(routine.steps.count) pasos")
            }

            if let after = routines.plan(for: routine).afterActivity {
                FirstThenStrip(routine: routine, after: after)
            }

            ScrollView(.horizontal) {
                HStack(spacing: Theme.spacing) {
                    ForEach(Array(routine.steps.enumerated()), id: \.element.id) { index, step in
                        NavigationLink(value: Route.guide(routine, startIndex: index)) {
                            StepCard(number: index + 1,
                                     step: step,
                                     isDone: progress.isCompleted(step),
                                     isNext: index == nextIndex)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)

            Spacer()

            if routine.steps.isEmpty {
                Label("Esta rutina todavía no tiene pasos. Pídele a un adulto que los agregue.",
                      systemImage: "square.dashed")
                    .font(.title3.weight(.semibold))
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Theme.retry.opacity(0.4), in: RoundedRectangle(cornerRadius: Theme.cardRadius))
            } else {
                NavigationLink(value: Route.guide(routine, startIndex: nextIndex)) {
                    Label(nextIndex == 0 ? "¡Empezar!" : "Seguir con el paso \(nextIndex + 1)",
                          systemImage: "play.circle.fill")
                }
                .buttonStyle(.primary)
            }
        }
        .padding(Theme.padding)
        .background(Theme.background)
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct StepCard: View {
    let number: Int
    let step: RoutineStep
    let isDone: Bool
    let isNext: Bool

    var body: some View {
        VStack(spacing: 16) {
            // El estado no depende solo del color: el número cambia por una palomita.
            ZStack {
                Circle()
                    .fill(isDone ? Theme.success : (isNext ? Theme.primary : Theme.secondaryButton))
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.title2.bold())
                        .foregroundStyle(Theme.onSuccess)
                } else {
                    Text("\(number)")
                        .font(.title2.bold())
                        .foregroundStyle(isNext ? .white : Theme.primary)
                }
            }
            .frame(width: 52, height: 52)

            Pictogram(symbol: step.symbol, size: 150, animated: false)
                .opacity(isDone ? 0.5 : 1)

            Text(step.title)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 190)

            Text(isDone ? "¡Listo!" : (isNext ? "Sigue este" : "Pendiente"))
                .font(.body.bold())
                .foregroundStyle(isDone ? Theme.onSuccess : .secondary)
        }
        .padding(Theme.spacing)
        .frame(width: 240)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(isNext ? Theme.primary : Theme.secondaryButton, lineWidth: isNext ? 4 : 2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Paso \(number): \(step.title)")
        .accessibilityValue(isDone ? "Completado" : "Pendiente")
        .accessibilityHint("Abre la guía de este paso")
    }
}

/// Tablero «Primero → Después»: la rutina y lo agradable que viene al terminarla.
private struct FirstThenStrip: View {
    let routine: Routine
    let after: AfterActivity

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Theme.spacing) { first; arrow; then }
            VStack(spacing: 12) { first; arrow.rotationEffect(.degrees(90)); then }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Primero: \(routine.title). Después: \(after.title).")
    }

    private var first: some View {
        panel(caption: "Primero", title: routine.title, symbol: routine.symbol, fill: Theme.secondaryButton)
    }

    private var then: some View {
        panel(caption: "Después", title: after.title, symbol: after.symbol, fill: Theme.reward.opacity(0.3))
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.title.bold())
            .foregroundStyle(Theme.primary)
    }

    private func panel(caption: String, title: String, symbol: String, fill: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 36))
                .foregroundStyle(Theme.primary)
                .frame(width: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(caption)
                    .font(.body.bold())
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.title3.weight(.semibold))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fill, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

#Preview {
    NavigationStack {
        RoutineStepsView(routine: Routine.all[0])
    }
    .environment(ProgressStore())
    .environment(SettingsStore())
    .environment(RoutineStore())
    .fontDesign(.rounded)
}
