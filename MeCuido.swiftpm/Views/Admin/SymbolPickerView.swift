import SwiftUI

/// Galería curada de SF Symbols para usar como pictogramas, con nombre en español para VoiceOver.
struct SymbolPickerView: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacing) {
                ForEach(SymbolCatalog.groups) { group in
                    Text(group.title)
                        .font(.title3.weight(.semibold))
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(group.symbols) { symbol in
                            symbolButton(symbol)
                        }
                    }
                }
            }
            .padding(Theme.padding)
        }
        .background(Theme.background)
        .navigationTitle("Elige un pictograma")
    }

    private func symbolButton(_ symbol: SymbolCatalog.Symbol) -> some View {
        let isSelected = symbol.name == selection
        return Button {
            selection = symbol.name
            dismiss()
        } label: {
            Image(systemName: symbol.name)
                .font(.system(size: 36))
                .foregroundStyle(Theme.primary)
                .frame(width: 88, height: 88)
                .background(.white, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardRadius)
                        .stroke(isSelected ? Theme.success : Theme.secondaryButton, lineWidth: isSelected ? 4 : 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symbol.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

enum SymbolCatalog {
    struct Symbol: Identifiable {
        let name: String
        let label: String
        var id: String { name }
    }

    struct SymbolGroup: Identifiable {
        let title: String
        let symbols: [Symbol]
        var id: String { title }
    }

    static let groups: [SymbolGroup] = [
        SymbolGroup(title: "Cuidarme", symbols: [
            Symbol(name: "hands.sparkles.fill", label: "Manos limpias"),
            Symbol(name: "drop.fill", label: "Agua"),
            Symbol(name: "bubbles.and.sparkles.fill", label: "Jabón"),
            Symbol(name: "shower.fill", label: "Regadera"),
            Symbol(name: "bathtub.fill", label: "Tina"),
            Symbol(name: "toilet.fill", label: "Baño"),
            Symbol(name: "mouth.fill", label: "Boca"),
            Symbol(name: "wind", label: "Secar"),
            Symbol(name: "bandage.fill", label: "Curita"),
            Symbol(name: "cross.case.fill", label: "Botiquín"),
            Symbol(name: "face.smiling", label: "Cara")
        ]),
        SymbolGroup(title: "Vestirme", symbols: [
            Symbol(name: "tshirt.fill", label: "Playera"),
            Symbol(name: "shoe.fill", label: "Zapato"),
            Symbol(name: "eyeglasses", label: "Lentes"),
            Symbol(name: "graduationcap.fill", label: "Gorra")
        ]),
        SymbolGroup(title: "Mi casa", symbols: [
            Symbol(name: "bed.double.fill", label: "Cama"),
            Symbol(name: "sofa.fill", label: "Sillón"),
            Symbol(name: "lamp.desk.fill", label: "Lámpara"),
            Symbol(name: "house.fill", label: "Casa"),
            Symbol(name: "door.left.hand.closed", label: "Puerta"),
            Symbol(name: "key.fill", label: "Llave"),
            Symbol(name: "trash.fill", label: "Basura"),
            Symbol(name: "washer.fill", label: "Lavadora"),
            Symbol(name: "refrigerator.fill", label: "Refrigerador"),
            Symbol(name: "fork.knife", label: "Comer"),
            Symbol(name: "cup.and.saucer.fill", label: "Taza"),
            Symbol(name: "square.stack.fill", label: "Doblar"),
            Symbol(name: "archivebox.fill", label: "Caja"),
            Symbol(name: "shippingbox.fill", label: "Juguetes")
        ]),
        SymbolGroup(title: "Escuela", symbols: [
            Symbol(name: "backpack.fill", label: "Mochila"),
            Symbol(name: "books.vertical.fill", label: "Libros"),
            Symbol(name: "book.fill", label: "Cuaderno"),
            Symbol(name: "pencil", label: "Lápiz"),
            Symbol(name: "pencil.and.ruler.fill", label: "Estuche"),
            Symbol(name: "paintpalette.fill", label: "Colores"),
            Symbol(name: "scissors", label: "Tijeras"),
            Symbol(name: "folder.fill", label: "Carpeta"),
            Symbol(name: "tray.and.arrow.up.fill", label: "Sacar"),
            Symbol(name: "tray.and.arrow.down.fill", label: "Guardar")
        ]),
        SymbolGroup(title: "Acciones", symbols: [
            Symbol(name: "hand.raised.fill", label: "Mano"),
            Symbol(name: "hand.thumbsup.fill", label: "Bien hecho"),
            Symbol(name: "hand.wave.fill", label: "Saludar"),
            Symbol(name: "person.fill", label: "Yo"),
            Symbol(name: "person.2.fill", label: "Pedir ayuda"),
            Symbol(name: "figure.walk", label: "Caminar"),
            Symbol(name: "figure.wave", label: "Hazlo tú"),
            Symbol(name: "ear.fill", label: "Escuchar"),
            Symbol(name: "eye.fill", label: "Mirar"),
            Symbol(name: "arrow.up.and.down", label: "Estirar"),
            Symbol(name: "arrow.clockwise", label: "Repetir"),
            Symbol(name: "checkmark", label: "Revisar"),
            Symbol(name: "xmark", label: "Cruzar")
        ]),
        SymbolGroup(title: "Otros", symbols: [
            Symbol(name: "star.fill", label: "Estrella"),
            Symbol(name: "heart.fill", label: "Corazón"),
            Symbol(name: "sparkles", label: "Brillos"),
            Symbol(name: "hare.fill", label: "Conejo"),
            Symbol(name: "tortoise.fill", label: "Tortuga"),
            Symbol(name: "pawprint.fill", label: "Mascota"),
            Symbol(name: "leaf.fill", label: "Planta"),
            Symbol(name: "sun.max.fill", label: "Día"),
            Symbol(name: "moon.fill", label: "Noche"),
            Symbol(name: "alarm.fill", label: "Despertador"),
            Symbol(name: "calendar", label: "Calendario")
        ])
    ]
}
