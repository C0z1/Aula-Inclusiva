# Ruta de desarrollo — Me Cuido, Me Organizo

Plan de trabajo desde la versión 0.2 hasta la 1.0 y más allá. Cada fase deja la app usable de
principio a fin y respeta los principios de `CLAUDE.md` (sin penalizaciones, la acción ocurre en
el mundo real, accesibilidad primero, todo local).

**Criterio de éxito general (documento de diseño):** que un niño de 8 a 12 años complete una rutina
de 3 pasos guiándose solo con la app, de principio a fin.

Leyenda: `[ ]` pendiente · `[x]` hecho · **(Decisión)** requiere acuerdo del equipo antes de programar.

---

## Punto de partida — v0.2 (hecho)

- [x] Agenda con mascota, medallas y «¡Hecha hoy!»
- [x] Secuencia de 3 pasos con progreso y estado no dependiente del color
- [x] Guía con narración es-MX, temporizador de anillo sin castigo, pausa, «Más tiempo», hápticos
- [x] Celebración con medalla y 5 accesorios desbloqueables
- [x] Progreso persistente (`UserDefaults`)
- [x] Ajustes para adultos: ritmo y voz, detrás de long press de 2 s

---

## Fase 0 — v0.2.1 · Estabilizar la base

Objetivo: corregir lo que se romperá al crecer y hacer testeable la lógica central.

- [ ] Proteger `StepGuideView` contra rutinas sin pasos (no navegar a la guía; mostrar mensaje amable).
- [ ] Extraer el temporizador a un modelo `StepTimer` (`@Observable`): `total`, `remaining`,
      `isPaused`, `tick()`, `reset(seconds:)`, `addTime(_:)`. La vista solo lo dibuja.
- [ ] Reemplazar `DispatchQueue.main.asyncAfter` de `flashSuccess()` por una `Task` cancelable.
- [ ] Dynamic Type: `@ScaledMetric` en `Pictogram`, `TimerRing`, íconos de tarjetas y el título de
      celebración; la fila de controles de la guía pasa a `ViewThatFits` (horizontal → vertical).
      Probar con *Tamaños de accesibilidad* al máximo.
- [ ] VoiceOver + voz: si `UIAccessibility.isVoiceOverRunning`, no usar `AVSpeechSynthesizer`;
      enviar la instrucción como anuncio de accesibilidad.
- [ ] Efecto de sonido suave al completar un paso y al terminar la rutina (archivo propio en
      `Resources/`, respetando el interruptor de silencio; opción para apagarlo en Ajustes).
- [ ] **(Decisión)** iPhone: quitar `.phone` de `Package.swift` o adaptar el layout. Recomendado:
      quitarlo hasta la Fase 6; la experiencia está diseñada para la pantalla del iPad.
- [ ] Renombrar o cambiar el accesorio «Cohete» (`paperplane.fill` no es un cohete).
- [ ] **(Decisión)** Pruebas: Playgrounds no ejecuta `testTarget`. Opciones:
      (a) paquete hermano `MeCuidoCore` con modelos puros y `swift test` en Mac;
      (b) migrar a proyecto Xcode en la Fase 8. Recomendado: (a), mover ahí `Routine`, `Accessory`,
      `StepTimer` y la lógica de `ProgressStore`/`SettingsStore`.
- [ ] Pruebas mínimas: `seconds(for:)` por ritmo, `finish()` otorga medalla y desbloquea el accesorio
      correcto, `isDoneToday` en el cambio de día, `StepTimer` no baja de 0 y respeta la pausa.

**Aceptación:** la app no truena con datos vacíos, se usa completa con texto al máximo y con
VoiceOver sin voces encimadas.

---

## Fase 1 — v0.3 · Rutinas editables por adultos

Objetivo: que cada familia o maestra adapte las rutinas a la casa o al aula del niño.

- [ ] Migrar el modelo a **SwiftData** (`@Model RoutineEntity`, `StepEntity` con `order`).
      Sembrar desde `Routine.all` en el primer arranque **conservando los ids** actuales.
- [ ] Migrar `completedSteps` y `lastFinished` de `UserDefaults` sin perder progreso; borrar las
      claves viejas solo después de migrar con éxito.
- [ ] Editor en Ajustes: crear, duplicar, archivar rutinas; agregar, reordenar (botones ↑/↓ además
      de arrastrar) y borrar pasos; elegir pictograma de una galería curada de SF Symbols; editar
      título, instrucción y tiempo sugerido; vista previa «Escuchar» de la instrucción.
- [ ] Rutinas incluidas: se pueden ocultar y restaurar, no borrar.
- [ ] **(Decisión)** Número de pasos: incluidas = 3; personalizadas = 2 a 5 (memoria de trabajo).
- [ ] Gate de adultos robusto: tras el long press, una operación escrita («¿Cuánto es 7 × 8?») con
      teclado numérico. Cumple la guía de *parental gate* de App Store para apps de niños.
- [ ] Respaldo: exportar/importar rutinas como archivo (`ShareLink` + `fileImporter`), sin red.

**Aceptación:** un adulto crea «Prepararme para dormir» de 4 pasos en menos de 3 minutos y el niño
la completa sin ayuda.

---

## Fase 2 — v0.4 · Agenda real del día

Objetivo: que la app ayude a **iniciar** la rutina correcta, no solo a seguirla.

- [ ] Cada rutina tiene momentos (`mañana`, `tarde`, `noche`) y días de la semana.
- [ ] Inicio muestra primero una tarjeta grande **«Ahora toca»** según la hora; el resto debajo.
      «¡Hecha hoy!» ya existe y se mantiene.
- [ ] Tablero **Primero → Después** (estrategia común para TDA): el adulto elige qué actividad
      agradable sigue a la rutina («Primero: tender mi cama → Después: jugar»).
- [ ] Recordatorios locales opcionales (`UserNotifications`), mensaje positivo y sin insistencia;
      se configuran solo desde Ajustes.
- [ ] Revisión final opcional por rutina («¿Revisaste…?») para que el niño corrija solo un paso
      olvidado (objetivo «DESPUÉS» del documento de diseño).

**Aceptación:** al abrir la app por la mañana, el niño identifica e inicia su rutina sin preguntar.

---

## Fase 3 — v0.5 · Contenido propio y multimodal

Objetivo: pictogramas más claros y conectados con los objetos reales del niño.

- [ ] Carpeta `Resources/` declarada en `Package.swift` con ilustraciones propias por paso
      (estilo consistente, fondo claro, sin texto dentro de la imagen).
- [ ] Animaciones de paso con `PhaseAnimator`/`KeyframeAnimator` (p. ej. orejitas de conejo),
      con alternativa estática cuando *Reducir movimiento* está activo.
- [ ] **Foto real del objeto**: el adulto toma una foto (cámara o `PhotosPicker`) de la mochila,
      la cama o el lavabo del niño y se usa como pictograma del paso. Ayuda a generalizar al
      mundo real. Guardar en el dispositivo, comprimida.
- [ ] **Voz grabada** por un familiar o la maestra por paso (`AVAudioRecorder`), con la voz
      sintética como respaldo.
- [ ] Selector de voz es-MX disponible en el dispositivo y velocidad ajustable.

**Aceptación:** con foto y voz familiar, el niño reconoce el paso más rápido que con el símbolo genérico
(medirlo en la Fase 7).

---

## Fase 4 — v0.6 · Mascota y motivación sin castigo

- [ ] Nombrar a la mascota; elegir entre 3–4 mascotas; saludo con su nombre.
- [ ] Reacciones de la mascota en la guía y la celebración (respetando *Reducir movimiento*).
- [ ] Más accesorios y fondos con una curva de desbloqueo amable (primero frecuente, luego espaciada).
- [ ] **Álbum de logros acumulativo** («Has tendido tu cama 10 veces»). Nunca rachas que se pierden
      ni contadores que bajan.
- [ ] Mensajes de ánimo variados (banco de frases positivas, sin repetir la misma seguida).

---

## Fase 5 — v0.7 · Perfiles y bitácora para adultos

- [ ] Varios perfiles de niño en un mismo iPad (uso en aula): selector con avatar y nombre;
      progreso, ajustes y rutinas por perfil.
- [ ] Bitácora local por sesión: inicio/fin, tiempo por paso, «Más tiempo», «Escuchar de nuevo»,
      «Paso anterior». Sirve para ver dónde necesita más apoyo, **no** para calificar.
- [ ] Panel para adultos con resumen semanal (Swift Charts) y exportación a PDF (`ImageRenderer`)
      para compartir con la maestra o terapeuta.
- [ ] Borrado de datos por perfil y explicación clara de qué se guarda.

---

## Fase 6 — v0.8 · Accesibilidad avanzada

- [ ] Auditoría con Accessibility Inspector de Xcode en todas las pantallas.
- [ ] Switch Control y Voice Control: `accessibilityInputLabels` («Hecho», «Listo», «Escuchar»).
- [ ] Variante de alto contraste (`colorSchemeContrast`) y paleta de modo oscuro en `Theme`
      (hoy se fuerza modo claro).
- [ ] Botón «¡Hecho!» también con área amplia en la mitad inferior para quien no apunta bien.
- [ ] Recomendación y guía para adultos de **Acceso guiado** (Guided Access) durante la rutina.
- [ ] Revisar layouts en iPad mini, iPad 11" y 13", ambas orientaciones y Split View.

---

## Fase 7 — v0.9 · Validación con niños

- [ ] Protocolo de prueba (con consentimiento de madres/padres y la escuela): tarea, observación
      sin intervenir, registro con la tabla de la sección 9 del documento de diseño.
- [ ] Métricas: % de rutinas completadas sin ayuda, pasos con más «Escuchar de nuevo»,
      tiempo vs. sugerido, comentarios del niño y del adulto.
- [ ] Iterar sobre hallazgos y actualizar `docs/documento-de-diseno.md` (versión 2).
- [ ] Sustituir las maquetas de `docs/screenshots/` por capturas reales del simulador.

---

## Fase 8 — v1.0 · Publicación

- [ ] `teamIdentifier`, ícono propio (no `.placeholder`), nombre y textos de App Store.
- [ ] Manifiesto de privacidad (`PrivacyInfo.xcprivacy`) y etiqueta de privacidad «Sin datos
      recopilados».
- [ ] Revisar requisitos de la **categoría Niños** (sin enlaces externos ni compras sin gate de
      adultos, sin analítica de terceros).
- [ ] TestFlight con familias y maestras de la Fase 7.
- [ ] Localización base (`Localizable.xcstrings`) para preparar otras variantes del español.

---

## Después de 1.0 (ideas)

- App Intents / Siri: «Oye Siri, empezar Lavarme las manos».
- Widget de «Ahora toca» en la pantalla de inicio del iPad.
- Sincronización opcional casa ↔ escuela con CloudKit (solo con decisión explícita del equipo
  sobre privacidad).
- Modo «yo guío»: el niño arma su propia rutina con pictogramas (más autonomía).
