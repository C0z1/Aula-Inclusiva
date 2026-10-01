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

- [x] Proteger `StepGuideView` contra rutinas sin pasos (no navegar a la guía; mostrar mensaje amable).
- [x] Extraer el temporizador a un modelo `StepTimer` (`@Observable`): `total`, `remaining`,
      `isPaused`, `tick()`, `reset(seconds:)`, `addTime(_:)`. La vista solo lo dibuja.
- [x] Reemplazar `DispatchQueue.main.asyncAfter` de `flashSuccess()` por una `Task` cancelable.
- [x] Dynamic Type: `@ScaledMetric` en `Pictogram`, `TimerRing`, íconos de tarjetas y el título de
      celebración; la fila de controles de la guía pasa a `ViewThatFits` (horizontal → vertical).
      Pendiente: probar con *Tamaños de accesibilidad* al máximo.
- [x] VoiceOver + voz: si `UIAccessibility.isVoiceOverRunning`, no usar `AVSpeechSynthesizer`;
      enviar la instrucción como anuncio de accesibilidad.
- [x] Efecto de sonido suave al completar un paso y al terminar la rutina, con opción para
      apagarlo en Ajustes. Se generó con `AVAudioEngine` (`SoundService`) en lugar de un archivo
      en `Resources/`; se puede cambiar por audio propio en la Fase 3.
- [x] **(Decidido)** iPhone: se quitó `.phone` de `Package.swift`; la app es solo para iPad
      hasta revisarlo en la Fase 6.
- [x] Renombrar o cambiar el accesorio «Cohete» (`paperplane.fill` no es un cohete). Ahora «Avión de papel»; id `cohete` intacto.
- [x] **(Decidido)** Pruebas: `Package.swift` en la raíz (`MeCuidoCore`) compila las mismas fuentes
      de `MeCuido.swiftpm/Models` sin copiarlas; pruebas en `Tests/MeCuidoCoreTests`. Corre en Mac,
      Linux, Docker y GitHub Actions (`.github/workflows/pruebas.yml`).
- [x] Pruebas mínimas: `seconds(for:)` por ritmo, `finish()` otorga medalla y desbloquea el accesorio
      correcto, `isDoneToday` en el cambio de día, `StepTimer` no baja de 0 y respeta la pausa.

- [ ] **Verificar en Xcode/iPad** (los cambios se escribieron sin poder compilar): guía completa
      de una rutina, «Más tiempo», pausa, paso anterior, campanitas, VoiceOver encendido, texto
      al máximo en vertical y horizontal.

**Aceptación:** la app no truena con datos vacíos, se usa completa con texto al máximo y con
VoiceOver sin voces encimadas.

---

## Fase 1 — v0.3 · Rutinas editables por adultos

Objetivo: que cada familia o maestra adapte las rutinas a la casa o al aula del niño.

- [x] **(Decidido)** Persistencia en **JSON local** (`RoutineStore`, `rutinas.json` en Application
      Support) en lugar de SwiftData: se prueba con `swift test` en Linux/CI, el mismo formato sirve
      de respaldo y **no hace falta migrar el progreso** (sigue en `UserDefaults`, ligado a los mismos
      ids de paso). Las incluidas viven en el código; en el archivo solo van las personalizadas y las ocultas.
- [x] Editor en Ajustes → Rutinas: crear, duplicar, ocultar y borrar rutinas; agregar, reordenar
      (Editar + arrastrar) y borrar pasos; galería curada de SF Symbols con nombres en español para
      VoiceOver; título, instrucción, tiempo sugerido y «Escuchar cómo se oye». Guardado automático.
- [x] Rutinas incluidas: se pueden ocultar y duplicar, no editar ni borrar.
- [x] **(Decidido)** Número de pasos: incluidas = 3; personalizadas = 1 a 5, recomendado 3. Una
      rutina sin pasos no aparece en la agenda del niño.
- [x] Gate de adultos: tras el long press, una multiplicación (12–29 × 3–9) con teclado propio de
      teclas de 96×72 pt. Si falla, pregunta nueva, sin rojo.
- [x] Respaldo: exportar (`fileExporter`) e importar (`fileImporter`) un JSON, sin red. Importar
      reemplaza por id, nunca toca las incluidas y rechaza respaldos de versiones más nuevas.
- [ ] Reordenar pasos con botones ↑/↓ además de arrastrar (pendiente; hoy solo Editar + arrastrar).
- [ ] **Verificar en iPad**: crear «Prepararme para dormir» de 4 pasos, reordenar, ocultar una
      incluida, exportar e importar en otro iPad, gate con VoiceOver.

**Aceptación:** un adulto crea «Prepararme para dormir» de 4 pasos en menos de 3 minutos y el niño
la completa sin ayuda.

---

## Fase 2 — v0.4 · Agenda real del día

Objetivo: que la app ayude a **iniciar** la rutina correcta, no solo a seguirla.

- [x] Cada rutina tiene un `RoutinePlan`: momentos (mañana 5–12 h, tarde 12–19 h, noche 19–5 h)
      y días. Sin momento = «cuando se necesite» (nunca «Ahora toca»). Planes de fábrica: agujetas y
      cama en la mañana; mochila las noches de escuela (dom a jue) con revisión; manos y herida,
      cuando se necesite. Las incluidas también se pueden reprogramar.
- [x] Inicio: saludo según la hora y tarjeta grande **«Ahora toca»** (prioriza la rutina ya empezada);
      «¡Terminaste todas tus rutinas de hoy!» al completar lo programado; «Hoy: x de N» cuenta solo
      lo programado para hoy. Cada tarjeta muestra su momento.
- [x] Tablero **Primero → Después**: el adulto elige una actividad sugerida o escribe otra; se ve
      en la tarjeta «Ahora toca», en «Mis pasos» y en la celebración («Ahora sí: jugar»).
- [x] Recordatorios locales opcionales: uno por momento y día con todas las rutinas que tocan
      (máx. 21; iOS permite 64), hora ajustable por momento, apagados por defecto.
- [x] Revisión final opcional: «¿Hiciste todo?» con los pasos; tocar uno vuelve a él y al
      presionar «¡Hecho!» regresa a la revisión. Nada se marca como error.
- [ ] **Verificar en iPad**: «Ahora toca» en la mañana y en la noche de un jueves, recordatorio a
      la hora elegida, revisión de la mochila, Primero → Después con VoiceOver.

**Aceptación:** al abrir la app por la mañana, el niño identifica e inicia su rutina sin preguntar.

---

## Fase 3 — v0.5 · Contenido propio y multimodal

Objetivo: pictogramas más claros y conectados con los objetos reales del niño.

- [x] **Foto real del objeto** por paso (también en rutinas incluidas): fototeca (`PhotosPicker`)
      o cámara; se reduce a 1200 px y JPEG 0.8 (`PhotoProcessing`) y se guarda en
      `Application Support/media/<idPaso>.jpg` (`MediaStore`). `StepPictogram` la muestra en la
      guía, «Mis pasos», la revisión y los editores; sin foto, el SF Symbol de siempre.
- [x] **Voz grabada** por paso (`VoiceRecorder`, AAC, máx. 20 s, `<idPaso>.m4a`). La guía la
      reproduce en lugar de la voz sintética (sin prefijo «¡Muy bien! Sigue:»); con VoiceOver
      activo se sigue enviando el texto como anuncio.
- [x] Elegir la voz del iPad (voces en español instaladas, primero es-MX y mejor calidad), con
      ejemplo al tocarla. La velocidad sigue siendo «Voz más lenta» (Fase 0).
- [x] Al borrar pasos o rutinas se borran sus archivos; al duplicar se copian. Las fotos y voces
      no van en el respaldo JSON (se avisa en Ajustes → Rutinas).
- [x] Permisos de cámara y micrófono declarados en `Package.swift` (`capabilities`).
- [ ] **Necesita al equipo:** ilustraciones propias por paso (estilo consistente, fondo claro, sin
      texto dentro) en `Resources/` declarada en `Package.swift`. Cuando existan, `StepPictogram`
      puede usarlas antes que el SF Symbol.
- [ ] **Depende de las ilustraciones:** animaciones de paso con `PhaseAnimator`/`KeyframeAnimator`
      (p. ej. orejitas de conejo) y alternativa estática con *Reducir movimiento*.
- [ ] Incluir fotos y voces en el respaldo (archivo .zip o carpeta) si en la Fase 7 se necesita
      pasarlas entre iPads.
- [ ] **Verificar en iPad**: foto con cámara y fototeca, grabar y escuchar, guía con voz grabada,
      VoiceOver con voz grabada, permiso de micrófono negado.

**Aceptación:** con foto y voz familiar, el niño reconoce el paso más rápido que con el símbolo genérico
(medirlo en la Fase 7).

---

## Fase 4 — v0.6 · Mascota y motivación sin castigo

- [x] Elegir entre 6 mascotas (huellita, perrito, gatito, conejito, tortuga, pajarito) y ponerle
      nombre (máx. 16 letras; vacío = nombre de fábrica). La celebración dice «¡Canelo está muy feliz!».
- [x] Reacciones: en la guía la mascota salta y muestra la frase de ánimo al terminar cada paso; en
      la celebración salta y aparece. Sin movimiento con *Reducir movimiento*.
- [x] 11 accesorios (1, 2, 3, 5, 8, 10, 12, 15, 20, 25 y 30 medallas) y 5 fondos pastel (0, 4, 9,
      14 y 18 medallas). Los umbrales de los accesorios anteriores no subieron (hay prueba).
- [x] **Álbum «Mis logros»**: series de rutinas en total (1…200), pasos hechos (10…500) y veces por
      rutina (1…100). Muestra lo ganado y solo la siguiente meta de cada serie, con su avance.
      Los contadores solo suben; repasar un paso no cuenta doble. Las estampas nuevas salen en la
      celebración.
- [x] Frases de ánimo variadas al terminar un paso y en el título de la celebración, sin repetir la
      misma seguida.
- [ ] **Verificar en iPad**: elegir mascota y nombre, salto en la guía con y sin *Reducir
      movimiento*, estampa nueva en la celebración, álbum con texto grande.

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
