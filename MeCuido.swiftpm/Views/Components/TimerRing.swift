import SwiftUI

/// Temporizador visual en forma de anillo. Indica el tiempo sin generar ansiedad:
/// no hay números rojos ni sonidos de alarma, y al terminar no pasa nada malo.
struct TimerRing: View {
    let remaining: Int
    let total: Int
    let isPaused: Bool

    /// El anillo crece con Dynamic Type para que el tiempo siga cabiendo dentro.
    @ScaledMetric(relativeTo: .title2) private var diameter: CGFloat = 130

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(remaining) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.secondaryButton, lineWidth: 14)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(isPaused ? Theme.pause : Theme.primary,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: fraction)
            VStack(spacing: 2) {
                Image(systemName: isPaused ? "pause.fill" : "clock.fill")
                    .font(.title3)
                Text(Self.format(remaining))
                    .font(.title2.weight(.semibold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .foregroundStyle(Theme.primary)
        }
        .frame(width: min(diameter, 220), height: min(diameter, 220))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Temporizador")
        .accessibilityValue(isPaused ? "En pausa, \(Self.spoken(remaining))" : "Quedan \(Self.spoken(remaining))")
    }

    static func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    static func spoken(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        switch (m, s) {
        case (0, _): return "\(s) segundos"
        case (_, 0): return m == 1 ? "1 minuto" : "\(m) minutos"
        default: return "\(m) minuto\(m == 1 ? "" : "s") y \(s) segundos"
        }
    }
}
