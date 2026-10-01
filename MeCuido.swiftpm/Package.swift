// swift-tools-version: 5.9

// WARNING:
// This is generated file content in the Swift Playgrounds app format.
// Abre esta carpeta (MeCuido.swiftpm) con Xcode 15+ o Swift Playgrounds 4.4+ en iPad.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "MeCuido",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "Me Cuido",
            targets: ["AppModule"],
            bundleIdentifier: "mx.aulainclusiva.mecuido",
            teamIdentifier: "",
            displayVersion: "0.3",
            bundleVersion: "4",
            appIcon: .placeholder(icon: .heart),
            accentColor: .presetColor(.blue),
            // Solo iPad: el diseño (pictogramas grandes, áreas táctiles amplias) está pensado para su pantalla.
            supportedDeviceFamilies: [
                .pad
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
