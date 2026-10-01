# CLAUDE.md — Me Cuido, Me Organizo

App SwiftUI para iPad (iPadOS 17+) que guía a niños y niñas de 8 a 12 años con TDA y retos
motrices en rutinas diarias (organizarse y cuidarse) con pictogramas, voz, temporizador sin
castigo y recompensas para su mascota. Proyecto de la materia **Aula Inclusiva**.

- Producto (fuente de verdad del *qué* y el *por qué*): `docs/documento-de-diseno.md`
- Ruta de desarrollo detallada (fases, criterios de aceptación): `docs/ruta-de-desarrollo.md`
- Versión actual: **0.2** (`displayVersion` / `bundleVersion` en `MeCuido.swiftpm/Package.swift`)

## Principios que no se negocian

1. **«Toda ayuda innecesaria incapacita».** La app muestra el *cómo*; la acción ocurre en el mundo
   real. Cada paso termina solo cuando el niño presiona «¡Hecho!». Nunca automatizar el avance.
2. **Sin penalizaciones.** El temporizador no castiga, no hay alarmas, no se pierden medallas ni
   accesorios, no hay rachas que se rompan. **Nunca usar rojo.** Reintento = `Theme.retry`
   (azul suave); pausa/aviso = `Theme.pause` (amarillo pastel).
3. **Motricidad:** área táctil mínima 60×60 pt (`Theme.minTarget`), botón principal ≥ 80 pt de alto,
   separación de 20–32 pt. Nada de gestos finos (pinch, doble toque, swipes cortos) como única vía.
4. **Voz:** toda instrucción se narra con `SpeechService` (es-MX). Tras cada instrucción:
   «¡Ahora hazlo tú y presiona el botón cuando termines!» (`StepGuideView.doItYourself`).
5. **Accesibilidad:** respetar `accessibilityReduceMotion`; el estado nunca depende solo del color
   (número → palomita, texto «Pendiente/¡Listo!»); etiqueta, valor y pista de VoiceOver en todo control.
6. **Lenguaje:** español de México, positivo, en segunda persona, neutral en género y capacidades.
7. **Privacidad:** todo se queda en el dispositivo. Sin cuentas, analítica, anuncios ni red
   (es una app para menores). Cualquier excepción requiere decisión explícita del equipo.

## Entorno y cómo verificar

- Paquete de app de Swift Playgrounds: `MeCuido.swiftpm/` (formato `AppleProductTypes`,
  `swift-tools-version: 5.9`). Se abre con **Xcode 15+** (simulador de iPad) o **Swift Playgrounds
  4.4+** en iPad. No hay `.xcodeproj`; no crear uno sin acordarlo.
- `Package.swift` es generado por Playgrounds: editar solo campos conocidos (versión, orientaciones,
  `resources`, capacidades) y conservar el formato.
- **Este equipo corre Windows: no se puede compilar ni ejecutar aquí.** Al cambiar Swift, revisar
  con cuidado tipos, `import`s y APIs de iOS 17, y avisar qué debe probarse en Mac/iPad.
- No hay tests automatizados todavía (Playgrounds no ejecuta `testTarget`). Ver Fase 0 de la ruta.
- Las capturas de `docs/screenshots/` son **maquetas**, no capturas reales del simulador.

## Arquitectura actual

```
MeCuido.swiftpm/
├── App/MeCuidoApp.swift        Raíz: crea los stores, .fontDesign(.rounded), fuerza modo claro
├── Models/
│   ├── Routine.swift           Routine / RoutineStep (structs) + catálogo fijo Routine.all
│   ├── Reward.swift            Accessory + catálogo Accessory.all (desbloqueo por medallas)
│   ├── ProgressStore.swift     @Observable: medallas, pasos hechos, lastFinished, accesorio puesto
│   ├── SettingsStore.swift     @Observable: ritmo (Pace), autoNarration, slowSpeech, soundEffects
│   └── StepTimer.swift         @Observable: lógica del temporizador de un paso (sin UI)
├── Services/
│   ├── SpeechService.swift     AVSpeechSynthesizer (es-MX → es-ES); con VoiceOver activo, anuncio
│   ├── SoundService.swift      Campanitas de logro generadas con AVAudioEngine (sin archivos)
│   └── AudioSession.swift      Configura una sola vez la AVAudioSession compartida
├── Theme/Theme.swift           Colores, espaciado, radios, minTarget, Color(hex:)
└── Views/
    ├── HomeView.swift          Pantalla 1: agenda + mascota + engrane de adultos; define `Route`
    ├── RoutineStepsView.swift  Pantalla 2: «Mis pasos siguientes»
    ├── StepGuideView.swift     Pantalla 3: guía (StepGuideContent) o EmptyRoutineView si no hay pasos
    ├── CelebrationView.swift   fullScreenCover al terminar la rutina
    ├── AvatarPickerView.swift  Sheet para equipar accesorios
    ├── SettingsView.swift      Sheet de ajustes para adultos (long press 2 s en el engrane)
    └── Components/             AvatarView, Buttons (.primary/.secondary), Pictogram, TimerRing
```

**Flujo:** `HomeView` (NavigationStack con `path: [Route]`) → `.routine` → `RoutineStepsView` →
`.guide(routine, startIndex)` → `StepGuideView` → `markDone()` avanza al siguiente pendiente o llama
`progress.finish(routine)` (+1 medalla, reinicia los pasos, guarda fecha) → `CelebrationView` →
`onExit` vacía el `path`.

**Persistencia:** `UserDefaults` con claves `medals`, `equippedAccessory`, `completedSteps`
(array de ids de paso), `lastFinished` (`[routineId: timeIntervalSince1970]`), `settings.pace`,
`settings.autoNarration`, `settings.slowSpeech`, `settings.soundEffects`. **No renombrar claves ni ids de rutina/paso**
(`"agujetas"`, `"agujetas.1"`…) sin migración: rompería el progreso guardado de los niños.

## Convenciones de código

- Colores, espaciado y radios **solo** desde `Theme`; no hardcodear hex ni números mágicos de layout.
- Texto sobre `Theme.success` usa `Theme.onSuccess` (el blanco no alcanza contraste AA).
- Tipografía: estilos del sistema (`.title2`, `.body.bold()`…) para respetar Dynamic Type. Si hace
  falta un tamaño fijo (pictogramas, íconos grandes), usar `@ScaledMetric`.
- Estado global: `ProgressStore` y `SettingsStore` (`@Observable`, `final class`), inyectados con
  `.environment(...)` y leídos con `@Environment(Tipo.self)`. Para bindings: `@Bindable var x = x`.
- Los stores reciben `UserDefaults` por inicializador (`defaults: .standard`) para poder probarlos
  con un suite aislado. Mantener ese patrón en stores nuevos.
- Tiempo de un paso: `settings.seconds(for:)`, nunca `step.suggestedSeconds` directo.
  Narración automática solo si `settings.autoNarration`; voz lenta con `slow: settings.slowSpeech`.
- Sonidos: `settings.play(.stepDone)` / `settings.play(.routineDone)` (respeta el ajuste). Solo
  sonidos de logro; nunca de error, alarma o tiempo agotado.
- Lógica con estado (temporizadores, reglas de progreso) va en modelos sin SwiftUI, no en la vista.
- Navegación por valor con `Route`; nuevas pantallas del flujo del niño se agregan como casos de
  `Route`. Ajustes y mascota son `sheet`; la celebración es `fullScreenCover`.
- Rutinas incluidas: en `Routine.all`, **3 pasos**, ids `"<rutina>.<n>"`, pictograma SF Symbol,
  `instruction` de una o dos frases cortas para narrar.
- Cada vista nueva lleva `#Preview` con `.environment(ProgressStore())`, `.environment(SettingsStore())`
  y `.fontDesign(.rounded)`.
- Comentarios y textos en español; nombres de tipos/funciones en inglés (como el código existente).
- Mensajes de commit: `feat:`, `fix:`, `docs:`, `refactor:` en español (como el historial).

## Deuda y problemas conocidos

- `Package.swift` declara `.phone`, pero el diseño es para iPad (decisión pendiente, Fase 0).
  La guía ya apila sus controles con `ViewThatFits`, pero el resto no se ha revisado en iPhone.
- Sin pruebas automatizadas (decisión pendiente, Fase 0: paquete `MeCuidoCore` vs. proyecto Xcode).
- El gate de adultos (long press 2 s) no basta para la categoría Niños de App Store (pide una
  verificación que un niño no pueda pasar, p. ej. una operación aritmética escrita). Fase 1.
- Los cambios de la Fase 0 no se han compilado todavía: probar en Xcode/iPad (ver la ruta).

## Ruta de desarrollo (resumen)

Detalle, tareas y criterios de aceptación en `docs/ruta-de-desarrollo.md`. Trabajar en orden;
cada fase debe dejar la app usable de principio a fin.

| Fase | Versión | Objetivo |
| :-- | :-- | :-- |
| 0 | 0.2.1 | Estabilizar: deuda de arriba, Dynamic Type, VoiceOver + TTS, `StepTimer` testeable |
| 1 | 0.3 | Rutinas editables por adultos (SwiftData), gate de adultos robusto |
| 2 | 0.4 | Agenda real: momentos del día, «Ahora toca», tablero *Primero → Después* |
| 3 | 0.5 | Contenido propio: pictogramas ilustrados, fotos de los objetos reales, voz grabada, sonidos |
| 4 | 0.6 | Mascota y motivación sin castigo: nombre, reacciones, álbum de logros acumulativo |
| 5 | 0.7 | Perfiles de niños (iPad compartido en aula) y bitácora para adultos con exportación PDF |
| 6 | 0.8 | Accesibilidad avanzada: Switch/Voice Control, alto contraste, modo oscuro, auditoría |
| 7 | 0.9 | Validación con niños del rango de edad y ajustes por hallazgos |
| 8 | 1.0 | Publicación: TestFlight / App Store (categoría Niños), privacidad, ícono, capturas reales |
| — | 1.x | Siri/App Intents, widget, sincronización opcional casa ↔ escuela |

**Fase en curso:** 0. Al terminar una tarea, marcarla en `docs/ruta-de-desarrollo.md`, actualizar el
checklist de «Avance actual» del `README.md` y subir `displayVersion`/`bundleVersion` al cerrar fase.
