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
- **Pruebas de modelos:** `Package.swift` de la raíz (`MeCuidoCore`) compila `MeCuido.swiftpm/Models`
  y corre `Tests/MeCuidoCoreTests` (XCTest). En Mac: `swift test`. En Windows, con Docker Desktop
  encendido, desde Git Bash:
  `MSYS_NO_PATHCONV=1 docker run --rm -v "$PWD:/src" swift:5.10-jammy bash -c "cp -r /src /tmp/w && cd /tmp/w && rm -rf .build && swift test"`.
  GitHub Actions las corre en cada PR y push a `main`.
- Por eso `Models/` **solo puede importar Foundation y Observation** (nada de SwiftUI, UIKit ni
  AVFoundation); lo que dependa de iOS va en `Services/` o `Views/` (p. ej. `SettingsStore.play`
  vive en `SoundService.swift`). Toda lógica nueva de modelo lleva su prueba.
- **Este equipo corre Windows:** las vistas (SwiftUI) no se pueden compilar aquí. El CI
  (`.github/workflows/pruebas.yml`) revisa la sintaxis de toda la app, corre `swift test` y compila
  la app con `xcodebuild` en macOS en cada push: revisar que pase antes de unir a `main`.
- Las capturas de `docs/screenshots/` son **maquetas**, no capturas reales del simulador.

## Arquitectura actual

```
MeCuido.swiftpm/
├── App/MeCuidoApp.swift        Raíz: crea los stores, .fontDesign(.rounded), fuerza modo claro
├── Models/
│   ├── Routine.swift           Routine / RoutineStep (structs Codable) + rutinas incluidas Routine.all
│   ├── RoutineStore.swift      @Observable: rutinas personalizadas, ocultas y planes (JSON), respaldo
│   ├── RoutinePlan.swift       DayMoment, RoutinePlan (agenda, Primero → Después, revisión),
│   │                           Agenda («Ahora toca»), Reminder (planeación), Weekday
│   ├── AdultGate.swift         Pregunta de multiplicación para entrar a Ajustes
│   ├── MediaStore.swift        @Observable: foto y voz grabada por id de paso (archivos locales)
│   ├── Reward.swift            Accessory, Pet y Backdrop (catálogos; desbloqueo por medallas)
│   ├── Achievement.swift       Achievement + AchievementCatalog (álbum) + Encouragement (frases)
│   ├── ProgressStore.swift     @Observable: medallas, pasos hechos, lastFinished, accesorio, mascota,
│   │                           nombre, fondo, veces por rutina y pasos totales (solo suben)
│   ├── SettingsStore.swift     @Observable: ritmo, voz (autoNarration, slowSpeech, voiceIdentifier),
│   │                           soundEffects, recordatorios
│   └── StepTimer.swift         @Observable: lógica del temporizador de un paso (sin UI)
├── Services/
│   ├── SpeechService.swift     Voz del sistema o grabación (narrate); con VoiceOver activo, anuncio.
│   │                           Usar `settings.speak(_:)` / `settings.narrate(_:recording:)`
│   ├── VoiceRecorder.swift     Grabación de instrucciones (AVAudioRecorder, máx. 20 s)
│   ├── PhotoProcessing.swift   Redimensiona/comprime fotos; PhotoCache en memoria
│   ├── SoundService.swift      Campanitas de logro generadas con AVAudioEngine (sin archivos)
│   ├── AudioSession.swift      Sesión de audio: reproducción hablada; grabación mientras se graba
│   └── ReminderService.swift   Notificaciones locales + modificador .syncReminders() (en la raíz)
├── Theme/Theme.swift           Colores, espaciado, radios, minTarget, Color(hex:)
└── Views/
    ├── HomeView.swift          Pantalla 1: saludo, «Ahora toca» (NowCard), rutinas; define `Route`
    ├── RoutineStepsView.swift  Pantalla 2: «Mis pasos siguientes» + FirstThenStrip
    ├── StepGuideView.swift     Pantalla 3: guía (StepGuideContent) o EmptyRoutineView si no hay pasos
    ├── RoutineReviewView.swift Revisión final «¿Hiciste todo?» (dentro de la guía, si el plan la pide)
    ├── CelebrationView.swift   fullScreenCover al terminar: frase, mascota, accesorio, estampas nuevas
    ├── AvatarPickerView.swift  Sheet «Mi mascota»: nombre, mascota, accesorios, fondos
    ├── AchievementsView.swift  Sheet «Mis logros» (álbum de estampas)
    ├── AdultGateView.swift     Pregunta + teclado grande antes de los ajustes
    ├── SettingsView.swift      Sheet de adultos (long press 2 s → AdultGateView → SettingsForm)
    ├── Admin/                  RoutinesAdminView, RoutineEditorView, StepEditorView,
    │                           RoutinePlanView (PlanSections, BuiltInRoutineView, BuiltInStepView,
    │                           WeekdayPicker), StepMediaSections (+ CameraPicker), VoicePickerView,
    │                           SymbolPickerView (SymbolCatalog), RoutinesBackupDocument
    └── Components/             AvatarView (`AvatarView(progress:)`), Buttons (.primary/.secondary),
                                Pictogram + StepPictogram, TimerRing
```

**Flujo:** `HomeView` (NavigationStack con `path: [Route]`) → `.routine` → `RoutineStepsView` →
`.guide(routine, startIndex)` → `StepGuideView` → `markDone()` avanza al siguiente pendiente; al
terminar, si `plan.reviewEnabled` muestra `RoutineReviewView`, y luego `finishRoutine()` llama
`progress.finish(routine)` (+1 medalla, reinicia los pasos, guarda fecha) → `CelebrationView`
(con la actividad de después) → `onExit` vacía el `path`.

**Persistencia:** `UserDefaults` con claves `medals`, `equippedAccessory`, `completedSteps`
(array de ids de paso), `lastFinished` (`[routineId: timeIntervalSince1970]`), `settings.pace`,
`settings.autoNarration`, `settings.slowSpeech`, `settings.soundEffects`, `settings.reminders`,
`settings.reminderMinutes`, `settings.voice`, `routineCounts`, `stepsDone`, `pet.id`, `pet.name`,
`backdrop`. **No renombrar claves ni ids de rutina/paso/accesorio/mascota/fondo**
(`"agujetas"`, `"agujetas.1"`…) sin migración: rompería el progreso guardado de los niños.
Rutinas personalizadas, ocultas y planes: `Application Support/rutinas.json` (`RoutineStore.Snapshot`
v2 con `plans`; lee también v1. Subir `version` si cambia el formato y mantener la lectura de la
anterior). Solo se guardan los planes distintos del de fábrica (`RoutinePlan.defaultPlan(for:)`).
Fotos y voces: `Application Support/media/<idPaso>.jpg|.m4a` (`MediaStore`); no van en el respaldo. Ids
personalizados: `custom-<uuid>` y pasos `<idRutina>.<8 hex>`.

## Convenciones de código

- Colores, espaciado y radios **solo** desde `Theme`; no hardcodear hex ni números mágicos de layout.
- Texto sobre `Theme.success` usa `Theme.onSuccess` (el blanco no alcanza contraste AA).
- Tipografía: estilos del sistema (`.title2`, `.body.bold()`…) para respetar Dynamic Type. Si hace
  falta un tamaño fijo (pictogramas, íconos grandes), usar `@ScaledMetric`.
- Estado global: `ProgressStore`, `SettingsStore` y `RoutineStore` (`@Observable`, `final class`), inyectados con
  `.environment(...)` y leídos con `@Environment(Tipo.self)`. Para bindings: `@Bindable var x = x`.
- Los stores reciben su almacenamiento por inicializador (`defaults: .standard`, `fileURL:`) para
  probarlos aislados. Mantener ese patrón en stores nuevos.
- Las rutinas del niño salen de `routines.visibleRoutines` (nunca de `Routine.all` directo en vistas
  del niño). Cambios a rutinas solo por `RoutineStore` (`save`, `duplicate`, `delete`, `setHidden`,
  `setPlan`). Plan de una rutina: `routines.plan(for:)`; agenda: `Agenda.current` / `scheduledToday`.
- Fechas en la lógica de agenda: pasar `now` y `calendar` como parámetros (para probar horarios).
- Recordatorios: nunca insistentes ni con urgencia; apagados por defecto; solo locales.
- Tiempo de un paso: `settings.seconds(for:)`, nunca `step.suggestedSeconds` directo.
  Narración automática solo si `settings.autoNarration`. Hablar siempre con `settings.speak(_:)` o,
  para un paso, `settings.narrate(_:recording: media.existingURL(for: .voice, stepID:))` (respetan
  voz elegida, voz lenta y grabaciones).
- Pictograma de un paso: siempre `StepPictogram(step:)` (usa la foto real si existe).
  Al borrar o duplicar pasos/rutinas, llamar `media.deleteAll` / `media.copyMedia`.
- Fotos: solo objetos, sin personas; nunca salen del iPad.
- Motivación: los contadores y logros solo suben; nada de rachas, vidas ni comparaciones. Al
  agregar accesorios o fondos, no subir el `medalsRequired` de los existentes. Frases de ánimo
  nuevas van en `Encouragement` (positivas, neutrales en género).
- Sonidos: `settings.play(.stepDone)` / `settings.play(.routineDone)` (respeta el ajuste). Solo
  sonidos de logro; nunca de error, alarma o tiempo agotado.
- Lógica con estado (temporizadores, reglas de progreso) va en modelos sin SwiftUI, no en la vista.
- Navegación por valor con `Route`; nuevas pantallas del flujo del niño se agregan como casos de
  `Route`. Ajustes y mascota son `sheet`; la celebración es `fullScreenCover`.
- Rutinas incluidas: en `Routine.all`, **3 pasos**, ids `"<rutina>.<n>"`, pictograma SF Symbol,
  `instruction` de una o dos frases cortas para narrar. Personalizadas: 1 a `RoutineStore.maxSteps` (5).
- Pictogramas elegibles por adultos: agregarlos a `SymbolCatalog` con su nombre en español.
- Cada vista nueva lleva `#Preview` con los stores que use (`.environment(ProgressStore())`,
  `SettingsStore()`, `RoutineStore()`, `MediaStore()`) y `.fontDesign(.rounded)`.
- Permisos nuevos (cámara, micrófono, etc.) se declaran en `capabilities` de `MeCuido.swiftpm/Package.swift`.
- Comentarios y textos en español; nombres de tipos/funciones en inglés (como el código existente).
- Mensajes de commit: `feat:`, `fix:`, `docs:`, `refactor:` en español (como el historial).

## Deuda y problemas conocidos

- App solo para iPad (`.pad` en `MeCuido.swiftpm/Package.swift`); iPhone se reevalúa en la Fase 6.
- Las vistas no se han probado en un iPad real; el CI solo las compila (job «compilar app»).
- Al borrar una rutina personalizada quedan ids de pasos huérfanos en `completedSteps` (inofensivo).

## Ruta de desarrollo (resumen)

Detalle, tareas y criterios de aceptación en `docs/ruta-de-desarrollo.md`. Trabajar en orden;
cada fase debe dejar la app usable de principio a fin.

| Fase | Versión | Objetivo |
| :-- | :-- | :-- |
| 0 | 0.2.1 | Estabilizar: deuda de arriba, Dynamic Type, VoiceOver + TTS, `StepTimer` testeable |
| 1 | 0.3 | Rutinas editables por adultos (JSON local), gate de adultos robusto |
| 2 | 0.4 | Agenda real: momentos del día, «Ahora toca», tablero *Primero → Después* |
| 3 | 0.5 | Contenido propio: pictogramas ilustrados, fotos de los objetos reales, voz grabada, sonidos |
| 4 | 0.6 | Mascota y motivación sin castigo: nombre, reacciones, álbum de logros acumulativo |
| 5 | 0.7 | Perfiles de niños (iPad compartido en aula) y bitácora para adultos con exportación PDF |
| 6 | 0.8 | Accesibilidad avanzada: Switch/Voice Control, alto contraste, modo oscuro, auditoría |
| 7 | 0.9 | Validación con niños del rango de edad y ajustes por hallazgos |
| 8 | 1.0 | Publicación: TestFlight / App Store (categoría Niños), privacidad, ícono, capturas reales |
| — | 1.x | Siri/App Intents, widget, sincronización opcional casa ↔ escuela |

**Fase en curso:** 5 (Fases 0–4 esperan la verificación en iPad; en la 3 faltan las
ilustraciones propias, que hace el equipo). Al terminar una tarea, marcarla en `docs/ruta-de-desarrollo.md`, actualizar el
checklist de «Avance actual» del `README.md` y subir `displayVersion`/`bundleVersion` al cerrar fase.
