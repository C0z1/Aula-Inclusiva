import SwiftUI

/// El niño elige su mascota, le pone nombre y la viste con lo que ha ganado.
struct AvatarPickerView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: Theme.spacing)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    AvatarView(progress: progress, size: 180)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Su nombre")
                            .font(.title3.weight(.semibold))
                        TextField(progress.pet.defaultName, text: $name)
                            .font(.title2.weight(.semibold))
                            .textInputAutocapitalization(.words)
                            .padding(20)
                            .frame(minHeight: Theme.minTarget)
                            .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                            .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius)
                                .stroke(Theme.secondaryButton, lineWidth: 2))
                            .onChange(of: name) { _, newName in progress.setPetName(newName) }
                    }

                    section("Elige tu mascota") {
                        ForEach(Pet.all) { pet in
                            tile(symbol: pet.symbol, title: pet.kind, isUnlocked: true,
                                 isSelected: progress.petID == pet.id, lockedText: nil) {
                                progress.choosePet(pet)
                            }
                        }
                    }

                    section("Accesorios") {
                        tile(symbol: "circle.slash", title: "Nada", isUnlocked: true,
                             isSelected: progress.equippedAccessoryID == nil, lockedText: nil) {
                            progress.equip(nil)
                        }
                        ForEach(Accessory.all) { accessory in
                            tile(symbol: accessory.symbol, title: accessory.name,
                                 isUnlocked: accessory.medalsRequired <= progress.medals,
                                 isSelected: progress.equippedAccessoryID == accessory.id,
                                 lockedText: "\(accessory.medalsRequired) medallas") {
                                progress.equip(accessory)
                            }
                        }
                    }

                    section("Fondos") {
                        ForEach(Backdrop.all) { backdrop in
                            tile(symbol: "circle.fill", title: backdrop.name,
                                 isUnlocked: backdrop.medalsRequired <= progress.medals,
                                 isSelected: progress.backdrop.id == backdrop.id,
                                 lockedText: "\(backdrop.medalsRequired) medallas",
                                 symbolColor: Color(hex: backdrop.top)) {
                                progress.chooseBackdrop(backdrop)
                            }
                        }
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
            .onAppear { name = progress.petName }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.weight(.semibold))
            LazyVGrid(columns: columns, spacing: Theme.spacing) {
                content()
            }
        }
    }

    private func tile(symbol: String, title: String, isUnlocked: Bool, isSelected: Bool, lockedText: String?,
                      symbolColor: Color = Theme.primary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: isUnlocked ? symbol : "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(isUnlocked ? symbolColor : .secondary)
                    .shadow(color: .black.opacity(symbolColor == Theme.primary ? 0 : 0.15), radius: 1)
                    .frame(height: 56)
                Text(title)
                    .font(.body.bold())
                    .multilineTextAlignment(.center)
                if !isUnlocked, let lockedText {
                    Text(lockedText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.onSuccess)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 150)
            .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(isSelected ? Theme.success : Theme.secondaryButton, lineWidth: isSelected ? 4 : 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Elegido" : (isUnlocked ? "" : "Bloqueado, \(lockedText ?? "")"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    AvatarPickerView()
        .environment(ProgressStore())
        .fontDesign(.rounded)
}
