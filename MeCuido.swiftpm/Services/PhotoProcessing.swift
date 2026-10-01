import UIKit

/// Prepara las fotos de los objetos reales: tamaño razonable y JPEG comprimido.
enum PhotoProcessing {
    /// Lado mayor máximo: suficiente para el pictograma grande de la guía.
    static let maxDimension: CGFloat = 1200

    static func jpegData(from image: UIImage, quality: CGFloat = 0.8) -> Data? {
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height, 1))
        let target = CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        // Dibujar también corrige la orientación de las fotos de la cámara.
        let resized = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality)
    }

    static func jpegData(from data: Data) -> Data? {
        UIImage(data: data).flatMap { jpegData(from: $0) }
    }
}

/// Caché en memoria de las fotos ya leídas del disco (se invalida con `MediaStore.revision`).
enum PhotoCache {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(at url: URL, revision: Int) -> UIImage? {
        let key = "\(url.path)#\(revision)" as NSString
        if let cached = cache.object(forKey: key) { return cached }
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        cache.setObject(image, forKey: key)
        return image
    }
}
