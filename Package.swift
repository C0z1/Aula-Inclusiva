// swift-tools-version: 5.9

// Paquete solo para pruebas: compila los modelos de la app (MeCuido.swiftpm/Models)
// sin SwiftUI, para correr `swift test` en Mac o Linux. La app se sigue abriendo
// desde MeCuido.swiftpm con Xcode o Swift Playgrounds; este archivo no la afecta.

import PackageDescription

let package = Package(
    name: "MeCuidoCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: "MeCuidoCore", targets: ["MeCuidoCore"])
    ],
    targets: [
        .target(
            name: "MeCuidoCore",
            path: "MeCuido.swiftpm/Models"
        ),
        .testTarget(
            name: "MeCuidoCoreTests",
            dependencies: ["MeCuidoCore"],
            path: "Tests/MeCuidoCoreTests"
        )
    ]
)
