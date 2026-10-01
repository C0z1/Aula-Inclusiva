import SwiftUI

/// Álbum de logros: estampas ganadas y la siguiente meta de cada serie.
/// Todo suma; nada se pierde ni se reinicia.
struct AchievementsView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(RoutineStore.self) private var routines
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 200), spacing: Theme.spacing)]

    /// Rutinas visibles más cualquiera que ya se haya hecho alguna vez (aunque esté oculta).
    private var albumRoutines: [Routine] {
        routines.allRoutines.filter { !routines.isHidden($0) || progress.timesDone($0) > 0 }
    }

    var body: some View {
        let album = progress.album(for: albumRoutines)
        let earned = album.filter(\.isEarned)
        let next = album.filter { !$0.isEarned }

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    Label(earned.count == 1 ? "1 estampa" : "\(earned.count) estampas",
                          systemImage: "book.closed.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.primary)

                    if earned.isEmpty {
                        Text("Termina una rutina para ganar tu primera estampa.")
                            .font(.title3)
                    } else {
                        LazyVGrid(columns: columns, spacing: Theme.spacing) {
                            ForEach(earned) { StickerCard(achievement: $0) }
                        }
                    }

                    if !next.isEmpty {
                        Text("Próximas estampas")
                            .font(.title2.weight(.semibold))
                        LazyVGrid(columns: columns, spacing: Theme.spacing) {
                            ForEach(next) { StickerCard(achievement: $0) }
                        }
                    }
                }
                .padding(Theme.padding)
            }
            .background(Theme.background)
            .navigationTitle("Mis logros")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .font(.body.bold())
                        .frame(minWidth: Theme.minTarget, minHeight: 44)
                }
            }
        }
    }
}

private struct StickerCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isEarned ? Theme.reward.opacity(0.3) : Theme.secondaryButton)
                if !achievement.isEarned {
                    Circle()
                        .trim(from: 0, to: achievement.progress)
                        .stroke(Theme.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                Image(systemName: achievement.symbol)
                    .font(.system(size: 40))
                    .foregroundStyle(achievement.isEarned ? Theme.primary : .secondary)
            }
            .frame(width: 96, height: 96)

            Text(achievement.title)
                .font(.body.bold())
                .multilineTextAlignment(.center)
            Text(achievement.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if achievement.isEarned {
                Label("¡Ganada!", systemImage: "checkmark.seal.fill")
                    .font(.callout.bold())
                    .foregroundStyle(Theme.onSuccess)
            } else {
                Text("Vas en \(achievement.current) de \(achievement.target)")
                    .font(.callout.bold())
                    .foregroundStyle(Theme.primary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 230)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(achievement.isEarned ? Theme.reward : Theme.secondaryButton, lineWidth: achievement.isEarned ? 3 : 2)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AchievementsView()
        .environment(ProgressStore())
        .environment(RoutineStore())
        .fontDesign(.rounded)
}
