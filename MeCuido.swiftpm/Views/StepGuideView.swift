import SwiftUI

/// Pantalla 3: Guía visual en acción. Acompaña al niño mientras hace la actividad
/// en el mundo real; la app muestra el "cómo", pero la acción la hace él.
struct StepGuideView: View {
    let routine: Routine
    let onExit: () -> Void
    private let startIndex: Int

    static let doItYourself = "¡Ahora hazlo tú y presiona el botón cuando termines!"

    init(routine: Routine, startIndex: Int, onExit: @escaping () -> Void) {
        self.routine = routine
        self.onExit = onExit
        self.startIndex = min(max(startIndex, 0), max(routine.steps.count - 1, 0))
    }

    var body: some View {
        // Una rutina sin pasos (posible con rutinas editables) no debe tronar la guía.
        if routine.steps.isEmpty {
            EmptyRoutineView(onExit: onExit)
                .navigationTitle(routine.title)
                .navigationBarTitleDisplayMode(.inline)
        } else {
            StepGuideContent(routine: routine, startIndex: startIndex, onExit: onExit)
        }
    }
}

/// Guía de una rutina con al menos un paso.
private struct StepGuideContent: View {
    let routine: Routine
    let onExit: () -> Void

    @Environment(ProgressStore.self) private var progress
    @Environment(SettingsStore.self) private var settings
    @Environment(RoutineStore.self) private var routines
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    @State private var index: Int
    /// Revisión final antes de celebrar (si el adulto la activó en el plan).
    @State private var showReview = false
    @State private var timer = StepTimer()
    @State private var started = false
    @State private var doneCount = 0
    @State private var showSuccess = false
    @State private var successTask: Task<Void, Never>?
    @State private var showCelebration = false
    @State private var newAccessory: Accessory?

    private let speech = SpeechService.shared

    init(routine: Routine, startIndex: Int, onExit: @escaping () -> Void) {
        self.routine = routine
        self.onExit = onExit
        _index = State(initialValue: startIndex)
    }

    private var step: RoutineStep { routine.steps[index] }

    private var guide: some View {
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

                Label(StepGuideView.doItYourself, systemImage: "figure.wave")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .multilineTextAlignment(.center)

                controls

                if timer.isFinished {
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
    }

    var body: some View {
        Group {
            if showReview {
                RoutineReviewView(routine: routine, onConfirm: finishRoutine, onRevisit: revisit)
                    .transition(.opacity)
            } else {
                guide
            }
        }
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: doneCount)
        .task { await runTimer() }
        .onAppear {
            // El tiempo depende del ritmo elegido en Ajustes, que solo está disponible aquí.
            guard !started else { return }
            started = true
            timer.reset(seconds: settings.seconds(for: step))
            if settings.autoNarration { speakStep() }
        }
        .onDisappear {
            speech.stop()
            successTask?.cancel()
        }
        .onChange(of: scenePhase) { _, phase in
            // Si la app pasa a segundo plano, el temporizador se detiene (ver tick) y la voz calla.
            if phase != .active { speech.stop() }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            CelebrationView(accessory: newAccessory,
                            after: routines.plan(for: routine).afterActivity) {
                showCelebration = false
                onExit()
            }
        }
    }

    // MARK: - Controles

    /// En horizontal si cabe; con texto grande o pantalla angosta, se apilan.
    private var controls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: Theme.spacing) {
                VStack(spacing: 16) { listenButton; previousButton }
                timerRing
                VStack(spacing: 16) { pauseButton; moreTimeButton }
            }

            VStack(spacing: Theme.spacing) {
                timerRing
                VStack(spacing: 16) {
                    listenButton
                    pauseButton
                    moreTimeButton
                    previousButton
                }
                .frame(maxWidth: 500)
            }
        }
    }

    private var timerRing: some View {
        TimerRing(remaining: timer.remaining, total: timer.total, isPaused: timer.isPaused)
    }

    private var listenButton: some View {
        Button {
            speakStep()
        } label: {
            Label("Escuchar de nuevo", systemImage: "speaker.wave.2.fill")
        }
        .buttonStyle(.secondary)
    }

    @ViewBuilder
    private var previousButton: some View {
        if index > 0 {
            Button {
                go(to: index - 1)
            } label: {
                Label("Paso anterior", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(.secondary)
        }
    }

    private var pauseButton: some View {
        Button {
            timer.isPaused.toggle()
        } label: {
            Label(timer.isPaused ? "Seguir" : "Pausa",
                  systemImage: timer.isPaused ? "play.fill" : "pause.fill")
        }
        .buttonStyle(.secondary)
    }

    private var moreTimeButton: some View {
        Button {
            timer.addTime()
        } label: {
            Label("Más tiempo", systemImage: "plus.circle.fill")
        }
        .buttonStyle(.secondary)
        .accessibilityHint("Agrega \(StepTimer.extraTime) segundos")
    }

    // MARK: - Acciones

    @MainActor
    private func runTimer() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            guard !showCelebration, !showReview, scenePhase == .active else { continue }
            withAnimation { timer.tick() }
        }
    }

    private func speakStep(prefix: String = "") {
        speech.speak("\(prefix)\(step.title). \(step.instruction) \(StepGuideView.doItYourself)",
                     slow: settings.slowSpeech)
    }

    private func go(to newIndex: Int, prefix: String = "") {
        withAnimation(reduceMotion ? nil : .spring) {
            index = newIndex
        }
        timer.reset(seconds: settings.seconds(for: step))
        if settings.autoNarration {
            speakStep(prefix: prefix)
        }
    }

    private func markDone() {
        progress.complete(step)
        doneCount += 1

        if let next = progress.nextPendingIndex(in: routine) {
            settings.play(.stepDone)
            flashSuccess()
            go(to: next, prefix: "¡Muy bien! Sigue: ")
        } else if routines.plan(for: routine).reviewEnabled {
            settings.play(.stepDone)
            withAnimation(reduceMotion ? nil : .default) { showReview = true }
            if settings.autoNarration {
                speech.speak(RoutineReviewView.spokenPrompt, slow: settings.slowSpeech)
            } else {
                speech.stop()
            }
        } else {
            finishRoutine()
        }
    }

    private func finishRoutine() {
        speech.stop()
        settings.play(.routineDone)
        newAccessory = progress.finish(routine)
        showCelebration = true
    }

    /// Desde la revisión, vuelve a un paso para repasarlo. Al presionar «¡Hecho!» se regresa a la revisión.
    private func revisit(_ stepIndex: Int) {
        withAnimation(reduceMotion ? nil : .default) { showReview = false }
        go(to: stepIndex, prefix: "Vamos a repasar: ")
    }

    private func flashSuccess() {
        successTask?.cancel()
        withAnimation { showSuccess = true }
        successTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            withAnimation { showSuccess = false }
        }
    }
}

/// Se muestra si una rutina no tiene pasos todavía.
private struct EmptyRoutineView: View {
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: Theme.padding) {
            Spacer()
            Image(systemName: "square.dashed")
                .font(.system(size: 80))
                .foregroundStyle(Theme.retry)
                .accessibilityHidden(true)
            Text("Esta rutina todavía no tiene pasos")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Pídele a un adulto que los agregue en los ajustes.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: onExit) {
                Label("Volver al inicio", systemImage: "house.fill")
            }
            .buttonStyle(.primary)
            .frame(maxWidth: 500)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
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
    .environment(SettingsStore())
    .environment(RoutineStore())
    .fontDesign(.rounded)
}
