import SwiftUI

/// «¿Qué sigue?»: antes de la rutina, el niño ordena sus pasos tocándolos.
/// Arriba, las casillas numeradas; abajo, las cartas revueltas. No se puede perder.
struct SequenceGameView: View {
    let routine: Routine
    let onExit: () -> Void

    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var game: SequenceGame?
    @State private var message = GameLines.sequenceIntro
    /// Sube con cada carta colocada (vibración suave de logro).
    @State private var placedCount = 0

    private let cardColumns = [GridItem(.adaptive(minimum: 200), spacing: Theme.spacing)]
    private let slotColumns = [GridItem(.adaptive(minimum: 130), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing) {
                if let game {
                    messageBox
                    slots(game)
                    if game.isFinished {
                        Button(action: onExit) {
                            Label("¡Listo! A hacer mi rutina", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(.primary)
                        .frame(maxWidth: 600)
                    } else {
                        cards(game)
                    }
                } else {
                    // No debería pasar (el botón solo aparece con 2 pasos o más), pero nunca se queda vacío.
                    Text("Esta rutina tiene un solo paso: ¡ya sabes qué sigue!")
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                    Button(action: onExit) {
                        Label("Volver a mis pasos", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.primary)
                    .frame(maxWidth: 600)
                }
            }
            .padding(Theme.padding)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .navigationTitle(GameKind.sequence.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Listo", action: onExit)
                    .font(.body.bold())
                    .frame(minWidth: Theme.minTarget, minHeight: 44)
                    .accessibilityHint("Sale del juego. Tu rutina no cambia.")
            }
        }
        .sensoryFeedback(.success, trigger: placedCount)
        .onAppear {
            guard game == nil else { return }
            var generator = SystemRandomNumberGenerator()
            game = SequenceGame(steps: routine.steps, using: &generator)
            if settings.autoNarration { settings.speak(message) }
        }
        .onDisappear { SpeechService.shared.stop() }
    }

    // MARK: - Partes

    private var messageBox: some View {
        HStack(spacing: 16) {
            AvatarView(progress: progress, size: 72)
            Text(message)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                settings.speak(message)
            } label: {
                Label("Escuchar", systemImage: "speaker.wave.2.fill")
            }
            .buttonStyle(.secondary)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius).stroke(Theme.secondaryButton, lineWidth: 2))
    }

    private func slots(_ game: SequenceGame) -> some View {
        LazyVGrid(columns: slotColumns, spacing: 16) {
            ForEach(Array(game.steps.enumerated()), id: \.element.id) { index, step in
                let placed = index < game.placedCount
                VStack(spacing: 8) {
                    if placed {
                        StepPictogram(step: step, size: 70, animated: false)
                        Label("\(index + 1)", systemImage: "checkmark.circle.fill")
                            .font(.title3.bold())
                            .foregroundStyle(Theme.onSuccess)
                    } else {
                        Text("\(index + 1)")
                            .font(.largeTitle.bold())
                            .foregroundStyle(index == game.placedCount ? Theme.primary : .secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 130)
                .background(placed ? Theme.success.opacity(0.25) : .white,
                            in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardRadius)
                        .stroke(index == game.placedCount ? Theme.primary : Theme.secondaryButton,
                                style: StrokeStyle(lineWidth: index == game.placedCount ? 4 : 2,
                                                   dash: placed ? [] : [8, 6]))
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(placed ? "Casilla \(index + 1): \(step.title)" : "Casilla \(index + 1): vacía")
            }
        }
    }

    private func cards(_ game: SequenceGame) -> some View {
        LazyVGrid(columns: cardColumns, spacing: Theme.spacing) {
            // Las cartas colocadas se quedan en su lugar (atenuadas) para que nada se mueva bajo el dedo.
            ForEach(game.cards) { step in
                let placed = game.isPlaced(step.id)
                let highlighted = game.isHighlighted(step.id)
                Button {
                    tap(step)
                } label: {
                    VStack(spacing: 12) {
                        StepPictogram(step: step, size: 110, animated: false)
                        Text(step.title)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cardRadius)
                            .stroke(highlighted ? Theme.primary : Theme.secondaryButton,
                                    lineWidth: highlighted ? 6 : 2)
                    )
                    .overlay(alignment: .topTrailing) {
                        if placed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(Theme.onSuccess)
                                .padding(10)
                        }
                    }
                    .opacity(placed ? 0.45 : 1)
                    .contentShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
                }
                .buttonStyle(.plain)
                .disabled(placed)
                .accessibilityLabel(step.title)
                .accessibilityValue(placed ? "Ya está en su casilla" : (highlighted ? "Es el que sigue" : ""))
                .accessibilityHint("Tócalo si es el paso \(game.currentSlot)")
            }
        }
    }

    // MARK: - Acciones

    private func tap(_ step: RoutineStep) {
        guard var current = game else { return }
        let slot = current.currentSlot
        let result = current.tap(step.id)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) { game = current }

        switch result {
        case .placed:
            placedCount += 1
            settings.play(.stepDone)
            say(GameLines.sequencePlaced(slot: slot, title: step.title))
        case .hint:
            if let next = current.nextStep, current.isHighlighted(next.id) {
                say(GameLines.sequenceReveal(title: next.title))
            } else {
                say(GameLines.sequenceHint(slot: slot))
            }
        case .finished:
            placedCount += 1
            settings.play(.routineDone)
            progress.finishGame()
            say(GameLines.sequenceFinished(titles: current.steps.map(\.title)))
        case .ignored:
            break
        }
    }

    private func say(_ text: String) {
        message = text
        if settings.autoNarration { settings.speak(text) }
    }
}

#Preview {
    NavigationStack {
        SequenceGameView(routine: Routine.all[3]) {}
    }
    .environment(ProgressStore())
    .environment(SettingsStore())
    .environment(MediaStore())
    .fontDesign(.rounded)
}
