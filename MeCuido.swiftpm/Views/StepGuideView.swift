import SwiftUI

/// Pantalla 3: Guía visual en acción. Acompaña al niño mientras hace la actividad
/// en el mundo real; la app muestra el "cómo", pero la acción la hace él.
struct StepGuideView: View {
    let routine: Routine
    let onExit: () -> Void

    @Environment(ProgressStore.self) private var progress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var index: Int
    @State private var total: Int
    @State private var remaining: Int
    @State private var isPaused = false
    @State private var doneCount = 0
    @State private var showSuccess = false
    @State private var showCelebration = false
    @State private var newAccessory: Accessory?

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let speech = SpeechService.shared

    static let doItYourself = "¡Ahora hazlo tú y presiona el botón cuando termines!"

    init(routine: Routine, startIndex: Int, onExit: @escaping () -> Void) {
        self.routine = routine
        self.onExit = onExit
        let start = min(max(startIndex, 0), routine.steps.count - 1)
        let seconds = routine.steps[start].suggestedSeconds
        _index = State(initialValue: start)
        _total = State(initialValue: seconds)
        _remaining = State(initialValue: seconds)
    }

    private var step: RoutineStep { routine.steps[index] }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing) {
                Text("Paso \(index + 1) de \(routine.steps.count)")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Pictogram(symbol: step.symbol, size: 260)
                    .id(step.id)
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))

                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(step.instruction)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 600)

                Label(Self.doItYourself, systemImage: "figure.wave")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .multilineTextAlignment(.center)

                controls

                if remaining == 0 {
                    Label("Tómate tu tiempo. Cuando termines, presiona ¡Hecho!",
                          systemImage: "tortoise.fill")
                        .font(.body.bold())
                        .padding(20)
                        .background(Theme.pause, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                        .transition(.opacity)
                }
            }
            .padding(Theme.padding)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom) {
            Button(action: markDone) {
                Label("¡Hecho!", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.primary)
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
            .background(Theme.background)
            .accessibilityHint("Presiónalo cuando hayas terminado este paso")
        }
        .overlay {
            if showSuccess {
                SuccessBadge()
                    .transition(.opacity)
            }
        }
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: doneCount)
        .onReceive(ticker) { _ in tick() }
        .onAppear { speakStep() }
        .onDisappear { speech.stop() }
        .fullScreenCover(isPresented: $showCelebration) {
            CelebrationView(accessory: newAccessory) {
                showCelebration = false
                onExit()
            }
        }
    }

    private var controls: some View {
        HStack(alignment: .center, spacing: Theme.spacing) {
            VStack(spacing: 16) {
                Button {
                    speakStep()
                } label: {
                    Label("Escuchar de nuevo", systemImage: "speaker.wave.2.fill")
                }
                .buttonStyle(.secondary)

                if index > 0 {
                    Button {
                        go(to: index - 1)
                    } label: {
                        Label("Paso anterior", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.secondary)
                }
            }

            TimerRing(remaining: remaining, total: total, isPaused: isPaused)

            VStack(spacing: 16) {
                Button {
                    isPaused.toggle()
                } label: {
                    Label(isPaused ? "Seguir" : "Pausa",
                          systemImage: isPaused ? "play.fill" : "pause.fill")
                }
                .buttonStyle(.secondary)

                Button {
                    total += 30
                    remaining += 30
                } label: {
                    Label("Más tiempo", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.secondary)
                .accessibilityHint("Agrega 30 segundos")
            }
        }
    }

    // MARK: - Acciones

    private func tick() {
        guard !isPaused, !showCelebration, remaining > 0 else { return }
        withAnimation { remaining -= 1 }
    }

    private func speakStep(prefix: String = "") {
        speech.speak("\(prefix)\(step.title). \(step.instruction) \(Self.doItYourself)")
    }

    private func go(to newIndex: Int, prefix: String = "") {
        withAnimation(reduceMotion ? nil : .spring) {
            index = newIndex
        }
        total = step.suggestedSeconds
        remaining = total
        isPaused = false
        speakStep(prefix: prefix)
    }

    private func markDone() {
        progress.complete(step)
        doneCount += 1
        flashSuccess()

        if let next = progress.nextPendingIndex(in: routine) {
            go(to: next, prefix: "¡Muy bien! Sigue: ")
        } else {
            speech.stop()
            newAccessory = progress.finish(routine)
            showCelebration = true
        }
    }

    private func flashSuccess() {
        withAnimation { showSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation { showSuccess = false }
        }
    }
}

private struct SuccessBadge: View {
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 140))
            .foregroundStyle(.white, Theme.success)
            .padding(40)
            .background(.ultraThinMaterial, in: Circle())
            .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack {
        StepGuideView(routine: Routine.all[0], startIndex: 0) {}
    }
    .environment(ProgressStore())
    .fontDesign(.rounded)
}
