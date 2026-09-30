# CLAUDE.md — Me Cuido, Me Organizo

App SwiftUI para iPad (iOS 17+), paquete Swift Playgrounds en `MeCuido.swiftpm/`.
La fuente de verdad del producto es `docs/documento-de-diseno.md`.

## Principios que no se negocian

- La app guía, **no sustituye** la actividad: cada paso termina con el niño presionando «¡Hecho!» tras hacerlo en el mundo real.
- Sin penalizaciones: el temporizador no castiga, no hay pérdida de medallas, nunca se usa rojo. Error/reintento = azul suave; pausa = amarillo pastel.
- Área táctil mínima 60×60 pt; botón principal ≥ 80 pt de alto; espaciado de 20–32 pt.
- Todo texto de instrucción se narra con `SpeechService` (es-MX). Mensaje clave tras cada instrucción: «¡Ahora hazlo tú y presiona el botón cuando termines!».
- Respetar `accessibilityReduceMotion`; el estado nunca depende solo del color; etiquetas de VoiceOver en todo control.

## Convenciones

- Colores, espaciado y radios salen de `Theme` (`Theme/Theme.swift`); no hardcodear valores.
- Tipografía: estilos de texto del sistema con `.fontDesign(.rounded)` (aplicado en la raíz).
- Estado global: `ProgressStore` (`@Observable`) inyectado con `.environment`.
- Rutinas nuevas: agregarlas en `Routine.all` (`Models/Routine.swift`), 3 pasos, pictograma SF Symbol.
- Textos de la interfaz en español, lenguaje positivo y neutral.
