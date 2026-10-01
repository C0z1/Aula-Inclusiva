import PhotosUI
import SwiftUI

/// Secciones de formulario para la foto real y la voz grabada de un paso.
/// Sirven para pasos de rutinas personalizadas y de las incluidas.
struct StepMediaSections: View {
    let step: RoutineStep

    @Environment(MediaStore.self) private var media

    @State private var pickedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var recorder = VoiceRecorder()
    @State private var message: String?

    private var hasPhoto: Bool { media.has(.photo, stepID: step.id) }
    private var voiceURL: URL? { media.existingURL(for: .voice, stepID: step.id) }

    var body: some View {
        Section {
            PhotosPicker(selection: $pickedItem, matching: .images, photoLibrary: .shared()) {
                Label(hasPhoto ? "Cambiar foto" : "Elegir una foto", systemImage: "photo.on.rectangle")
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    showingCamera = true
                } label: {
                    Label("Tomar foto", systemImage: "camera.fill")
                }
            }
            if hasPhoto {
                Button {
                    media.delete(.photo, stepID: step.id)
                } label: {
                    Label("Usar el pictograma en lugar de la foto", systemImage: "arrow.uturn.backward")
                }
            }
        } header: {
            Text("Foto real")
        } footer: {
            Text("Una foto del objeto real del niño (su mochila, su cama, su lavabo) le ayuda a reconocer el paso. Toma solo el objeto, sin personas. Se guarda solo en este iPad.")
        }
        .onChange(of: pickedItem) { _, item in
            guard let item else { return }
            Task { await importPhoto(item) }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker { image in
                if let image { savePhoto(PhotoProcessing.jpegData(from: image)) }
            }
            .ignoresSafeArea()
        }

        Section {
            if recorder.isRecording {
                Button {
                    recorder.stop()
                } label: {
                    Label("Detener · \(Int(recorder.elapsed)) de \(Int(VoiceRecorder.maxSeconds)) s",
                          systemImage: "stop.circle.fill")
                        .font(.body.bold())
                }
                ProgressView(value: recorder.elapsed, total: VoiceRecorder.maxSeconds)
                    .tint(Theme.primary)
                    .accessibilityHidden(true)
            } else {
                Button {
                    Task { await startRecording() }
                } label: {
                    Label(voiceURL == nil ? "Grabar la instrucción" : "Grabar de nuevo", systemImage: "mic.fill")
                }
                if let voiceURL {
                    Button {
                        SpeechService.shared.narrate("", recording: voiceURL)
                    } label: {
                        Label("Escuchar la grabación", systemImage: "play.circle.fill")
                    }
                    Button {
                        SpeechService.shared.stop()
                        media.delete(.voice, stepID: step.id)
                    } label: {
                        Label("Usar la voz del iPad en lugar de la grabación", systemImage: "arrow.uturn.backward")
                    }
                }
            }
        } header: {
            Text("Voz grabada")
        } footer: {
            Text("Lee el paso con calma y termina con «¡Ahora hazlo tú y presiona el botón cuando termines!». Máximo \(Int(VoiceRecorder.maxSeconds)) segundos. Una voz conocida ayuda a poner atención. Se guarda solo en este iPad.")
        }
        .onChange(of: recorder.finishedCount) { _, _ in
            do {
                try media.adopt(fileAt: recorder.recordingURL, as: .voice, stepID: step.id)
            } catch {
                message = "No se pudo guardar la grabación."
            }
        }
        .onDisappear {
            if recorder.isRecording { recorder.cancel() }
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("Aceptar", role: .cancel) {}
        }
    }

    private func importPhoto(_ item: PhotosPickerItem) async {
        let data = try? await item.loadTransferable(type: Data.self)
        savePhoto(data.flatMap { PhotoProcessing.jpegData(from: $0) })
        pickedItem = nil
    }

    private func savePhoto(_ data: Data?) {
        guard let data else {
            message = "No se pudo usar esa foto. Intenta con otra."
            return
        }
        do {
            try media.save(data, as: .photo, stepID: step.id)
        } catch {
            message = "No se pudo guardar la foto."
        }
    }

    private func startRecording() async {
        SpeechService.shared.stop()
        guard await VoiceRecorder.requestPermission() else {
            message = "Para grabar, permite el uso del micrófono para Me Cuido en la app Ajustes del iPad."
            return
        }
        if !recorder.start() {
            message = "No se pudo empezar a grabar."
        }
    }
}

/// Cámara del iPad para tomar la foto de un objeto.
struct CameraPicker: UIViewControllerRepresentable {
    let onFinish: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.onFinish(info[.originalImage] as? UIImage)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onFinish(nil)
            parent.dismiss()
        }
    }
}
