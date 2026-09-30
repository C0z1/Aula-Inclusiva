import SwiftUI

/// Permite al niño vestir a su mascota con los accesorios que ha ganado.
struct AvatarPickerView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: Theme.spacing)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.padding) {
                    AvatarView(accessory: progress.equippedAccessory, size: 180)

                    LazyVGrid(columns: columns, spacing: Theme.spacing) {
                        accessoryButton(nil)
                        ForEach(Accessory.all) { accessoryButton($0) }
                    }
                }
                .padding(Theme.padding)
            }
            .background(Theme.background)
            .navigationTitle("Mi mascota")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .font(.body.bold())
                        .frame(minWidth: Theme.minTarget, minHeight: 44)
                }
            }
        }
    }

    private func accessoryButton(_ accessory: Accessory?) -> some View {
        let unlocked = accessory.map { $0.medalsRequired <= progress.medals } ?? true
        let selected = progress.equippedAccessoryID == accessory?.id

        return Button {
            progress.equip(accessory)
        } label: {
            VStack(spacing: 12) {
                Image(systemName: unlocked ? (accessory?.symbol ?? "circle.slash") : "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(unlocked ? Theme.primary : .secondary)
                    .frame(height: 56)
                Text(accessory?.name ?? "Nada")
                    .font(.body.bold())
                if let accessory, !unlocked {
                    Text("\(accessory.medalsRequired) medallas")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(selected ? Theme.success : Theme.secondaryButton, lineWidth: selected ? 4 : 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .accessibilityLabel(accessory?.name ?? "Sin accesorio")
        .accessibilityValue(selected ? "Puesto" : (unlocked ? "" : "Bloqueado"))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
