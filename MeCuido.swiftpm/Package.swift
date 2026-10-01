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
            displayVersion: "0.5",
            bundleVersion: "6",
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
            ],
            capabilities: [
                .camera(purposeString: "Para tomar fotos de los objetos reales del niño (su mochila, su cama) y usarlas como pictogramas. Las fotos se quedan en este iPad."),
                .microphone(purposeString: "Para grabar la voz de un familiar o maestra leyendo cada paso. Las grabaciones se quedan en este iPad.")
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
