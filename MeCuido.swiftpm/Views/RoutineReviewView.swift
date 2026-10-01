import SwiftUI

/// Revisión final: el niño repasa sus pasos y, si olvidó alguno, vuelve a él.
/// No se marca nada como «mal»: solo se invita a revisar.
struct RoutineReviewView: View {
    let routine: Routine
    let onConfirm: () -> Void
    let onRevisit: (Int) -> Void

    static let spokenPrompt = "¡Ya casi! Revisa tus pasos. Si se te olvidó uno, tócalo para verlo otra vez. Si hiciste todo, presiona el botón verde."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("¿Hiciste todo?", systemImage: "checklist")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.primary)
                    Text("Revisa tus pasos. Si se te olvidó uno, tócalo para verlo otra vez.")
                        .font(.title3)
                }

                ForEach(Array(routine.steps.enumerated()), id: \.element.id) { index, step in
                    Button {
                        onRevisit(index)
                    } label: {
                        HStack(spacing: Theme.spacing) {
                            Text("\(index + 1)")
                                .font(.title2.bold())
                                .foregroundStyle(Theme.primary)
                                .frame(width: 52, height: 52)
                                .background(Theme.secondaryButton, in: Circle())
                            StepPictogram(step: step, size: 90, animated: false)
                            Text(step.title)
                                .font(.title2.weight(.semibold))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                            Label("Ver otra vez", systemImage: "arrow.uturn.backward")
                                .font(.body.bold())
                                .foregroundStyle(Theme.primary)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, minHeight: Theme.minTarget)
                        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                        .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius)
                            .stroke(Theme.secondaryButton, lineWidth: 2))
                        .contentShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Paso \(index + 1): \(step.title)")
                    .accessibilityHint("Vuelve a este paso para repasarlo")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .padding(Theme.padding)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom) {
            Button(action: onConfirm) {
                Label("¡Sí, hice todo!", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
            .background(Theme.background)
        }
    }
}

#Preview {
    NavigationStack {
        RoutineReviewView(routine: Routine.all[1], onConfirm: {}, onRevisit: { _ in })
    }
    .environment(MediaStore())
    .fontDesign(.rounded)
}
