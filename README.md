# Aula Inclusiva · Me Cuido, Me Organizo

App para iPad (SwiftUI) que ayuda a niños de 8 a 12 años con TDA y retos motrices a
realizar de forma autónoma sus rutinas de autocuidado y organización: atarse las
agujetas, ordenar la mochila, tender la cama, lavarse las manos y curar una herida pequeña.

> «Toda ayuda innecesaria incapacita»: la app muestra el *cómo*, pero la acción
> la realiza el niño en el mundo real.

El documento de diseño completo está en [`docs/documento-de-diseno.md`](docs/documento-de-diseno.md).

## Cómo abrirla

El proyecto es un paquete de app de Swift Playgrounds (`MeCuido.swiftpm`):

- **Mac:** abre la carpeta `MeCuido.swiftpm` con Xcode 15 o superior y ejecuta en un simulador de iPad.
- **iPad:** copia la carpeta `MeCuido.swiftpm` a la app Swift Playgrounds (4.4+) y toca ▶︎.

Requiere iOS / iPadOS 17.

## Avance actual (v0.1)

| Pantalla | Estado |
| :--- | :--- |
| 1 · Agenda principal y avatar | ✅ Tarjetas de rutinas, medallas y mascota con accesorios |
| 2 · Mis pasos siguientes | ✅ Barra de progreso y secuencia horizontal de pictogramas |
| 3 · Guía visual en acción | ✅ Pictograma animado, narración en voz, temporizador de anillo, botón «¡Hecho!» con háptica |
| Celebración | ✅ Medalla y desbloqueo de accesorios |

Accesibilidad incluida: botones de al menos 60 pt, etiquetas de VoiceOver, soporte para
*Reducir movimiento*, estados que no dependen solo del color y tipografía SF Rounded con Dynamic Type.

## Estructura

```
MeCuido.swiftpm/
├── Package.swift
├── App/MeCuidoApp.swift
├── Models/          Routine, Reward (accesorios), ProgressStore
├── Services/        SpeechService (texto a voz es-MX)
├── Theme/           Colores, espaciado y formas del documento de diseño
└── Views/           Home, RoutineSteps, StepGuide, Celebration, AvatarPicker + Components
```

## Siguientes pasos

- Pictogramas / animaciones ilustradas propias en lugar de SF Symbols.
- Probar con niños del rango de edad (criterio de éxito: completar una rutina de 3 pasos sin ayuda).
- Ajustes para adultos (editar rutinas y tiempos).

## Equipo

Andrea Mateo Maximino · Ana Cecilia Medina Hernández · María Fernanda Medina Ramírez ·
Félix Yael Tavera Ramírez · Evan Isaac Hernández Pérez
