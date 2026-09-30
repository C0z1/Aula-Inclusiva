import SwiftUI

/// Pantalla 2: Mis pasos siguientes. Muestra la secuencia completa para dar estructura mental.
struct RoutineStepsView: View {
    let routine: Routine
    @Environment(ProgressStore.self) private var progress

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

            NavigationLink(value: Route.guide(routine, startIndex: nextIndex)) {
                Label(nextIndex == 0 ? "¡Empezar!" : "Seguir con el paso \(nextIndex + 1)",
                      systemImage: "play.circle.fill")
            }
            .buttonStyle(.primary)
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

#Preview {
    NavigationStack {
        RoutineStepsView(routine: Routine.all[0])
    }
    .environment(ProgressStore())
    .environment(SettingsStore())
    .fontDesign(.rounded)
}
