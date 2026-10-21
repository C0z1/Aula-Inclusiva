# Plan: minijuegos, estabilidad y calidad

Versión 1 del plan · octubre 2026 · Se integra a la ruta como **Fase 4b (v0.6.x)**, antes de los perfiles (Fase 5).

Este documento dice **qué** se va a construir, **en qué orden**, **cómo se comprueba cada paso** y **qué no se
puede romper**. Cada etapa deja la app usable de principio a fin y no se une a `main` sin el CI en verde.

---

## 1. Reglas de los minijuegos (no se negocian)

Salen de los principios de `CLAUDE.md`. Si un juego no cumple alguna, no entra.

1. **El juego nunca sustituye la acción real.** Va *antes* (para preparar la mente) o *después* (como premio),
   nunca en lugar de un paso. Ningún paso se marca como hecho por jugar.
2. **Siempre opcional.** El botón principal sigue siendo «¡Empezar!» o «Volver al inicio». El juego es un botón
   secundario y un adulto puede apagar todos los juegos en Ajustes.
3. **No se puede perder.** Sin puntos, vidas, cronómetro en contra, rachas ni «incorrecto». Un toque equivocado
   recibe una pista amable («Ese va después. ¿Cuál va primero?»), nunca un sonido de error, una vibración de aviso
   ni el color rojo.
4. **Se puede salir en cualquier momento** con «Listo», sin perder nada (ni del juego ni de la rutina).
5. **Motricidad:** solo toques. Cartas y botones de al menos 120 pt (el doble del mínimo `Theme.minTarget`),
   separados entre 20 y 32 pt. Nada de arrastrar, pellizcar, deslizar ni tocar dos veces.
6. **Atención (TDA):** partidas de 30 a 90 segundos, una sola instrucción a la vez, narrada con voz y escrita.
   Nada que parpadee rápido ni elementos que distraigan.
7. **Accesibilidad:** VoiceOver, Switch Control y Voice Control pueden jugar todo (cada carta es un botón con
   etiqueta). Con «Reducir movimiento», sin volteos ni rebotes (solo transiciones suaves).
8. **Mucho ánimo:** se felicita el esfuerzo en cada acierto y al terminar, con frases neutrales en género.
   Los juegos no dan medallas (esas son de las rutinas reales), pero sí suman a una estampa del álbum.
9. **Manos ocupadas o mojadas = no tocar el iPad.** Ningún juego pide tocar la pantalla mientras el niño hace
   un paso (p. ej. al lavarse las manos).

---

## 2. Dónde van los juegos

| Momento | Juego | Para qué sirve | Cómo se llega |
| :-- | :-- | :-- | :-- |
| **Antes** de la rutina (Pantalla 2, «Mis pasos») | **¿Qué sigue?** (ordenar los pasos) | Memoria de la secuencia antes de hacerla | Botón secundario «Jugar: ¿qué sigue?» bajo «¡Empezar!» |
| **Antes**: «Ordenar mi mochila» | **¿Va en la mochila?** (clasificar) | Decidir qué se guarda y qué no | Mismo botón secundario |
| **Antes**: «Curar una herida pequeña» | **Mi botiquín** (clasificar) | Reconocer lo que sirve para curar | Mismo botón secundario |
| **Antes**: «Tender mi cama» y rutinas con 3 o más pasos | **Memorama** de los pasos | Atención y memoria con los pictogramas o fotos reales de la rutina | Mismo botón secundario |
| **Después** (celebración) | **Burbujas** | Premio relajante (sobre todo tras lavarse las manos) | Botón secundario «Jugar con burbujas» |
| **Después** (celebración) | **Juega con tu mascota** | Premio afectivo: la mascota salta, dice frases y recibe un bocadillo | Botón secundario «Jugar con {nombre}» |

Cada rutina tiene **un solo** juego «antes», para no saturar: mochila → clasificar, herida → botiquín,
cama → memorama, agujetas y manos → ¿qué sigue?. Las rutinas personalizadas usan «¿qué sigue?» con 2 a 5 pasos,
o ninguno si tienen 1 paso.

**No incluido en la versión 1:** un «rincón de juegos» libre en el inicio. Competiría con las rutinas, que son
el objetivo (decisión abierta, sección 9).

---

## 3. Catálogo de juegos

### 3.1 ¿Qué sigue? (secuencia)
- **Pantalla:** arriba, una tira de casillas numeradas (1, 2, 3…); abajo, las cartas de los pasos revueltas
  (pictograma o foto real + título).
- **Mecánica:** tocar el paso que va en la siguiente casilla. Si acierta, la carta se coloca con una palomita y
  una frase («¡Así es! Primero mojas tus manos»). Si no, la carta se queda en su lugar y se da una pista con voz;
  a la segunda pista, la carta correcta se resalta con un contorno (no se queda trabado).
- **Fin:** con todas las casillas llenas, la mascota festeja y se lee la secuencia completa.
- **Modelo:** `SequenceGame` (orden correcto, orden revuelto distinto del correcto, `tap(stepID) -> .placed | .hint | .finished`,
  pistas por casilla).

### 3.2 ¿Va en la mochila? / Mi botiquín (clasificar)
- **Pantalla:** un objeto grande a la vez (SF Symbol + nombre) y dos botones enormes: «Sí va» y «Se queda»
  (botiquín: «Sirve para curar» / «No sirve»).
- **Mecánica:** 6 objetos por partida, tomados de un catálogo. Cualquier respuesta recibe una explicación corta y
  positiva («¡Buena pregunta! La almohada se queda en casa»). Se sigue igual si la respuesta no era la esperada.
- **Fin:** resumen visual de lo que sí va, leído en voz alta.
- **Modelo:** `SortGame` genérico + `SortCatalog.backpack` y `SortCatalog.firstAid` (objetos validados con la
  maestra; ver decisiones abiertas).

### 3.3 Memorama
- **Pantalla:** 6 cartas (3 parejas) en cuadrícula de 3 × 2, de 160 pt o más. Con texto grande, 2 columnas.
- **Mecánica:** tocar dos cartas; si son pareja, se quedan descubiertas con palomita; si no, se voltean solas
  después de 1.5 s, sin sonido ni mensaje negativo. Sin contador de intentos.
- **Fin:** al encontrar las 3 parejas.
- **Modelo:** `MemoryGame` (cartas con id, `flip(cardID)`, `resolvePending()`, nunca más de 2 descubiertas sin pareja).

### 3.4 Burbujas (premio)
- **Pantalla:** burbujas grandes (130 pt o más) que suben despacio; al tocarlas, se revientan con una campanita suave.
- **Fin:** a los 45 s, o con «Listo». No cuenta cuántas reventó.
- **Reducir movimiento:** las burbujas aparecen y desaparecen en su lugar, sin moverse.
- **Modelo:** `BubbleField` (posiciones con generador inyectado; sin física compleja).

### 3.5 Juega con tu mascota (premio)
- **Pantalla:** la mascota grande y tres botones: «Saludar», «Bocadillo», «Bailar». Cada uno hace una reacción
  corta con frase de ánimo («¡{nombre} está feliz de que terminaras!»).
- **Fin:** con «Listo».
- **Modelo:** reutiliza `ProgressStore` (mascota, nombre) y `Encouragement`.

---

## 4. Arquitectura técnica

### 4.1 Archivos nuevos
```
MeCuido.swiftpm/
├── Models/Games/
│   ├── GameKind.swift        enum GameKind: String, Codable (ids estables: "secuencia", "clasificar-mochila",
│   │                         "botiquin", "memorama", "burbujas", "mascota") + juego «antes» por rutina
│   ├── SequenceGame.swift    lógica pura, generador inyectado
│   ├── SortGame.swift        lógica + SortCatalog (mochila, botiquín)
│   ├── MemoryGame.swift      lógica pura
│   ├── BubbleField.swift     posiciones y vida de las burbujas
│   └── GameLines.swift       frases de instrucciones, pistas y ánimo (neutrales)
├── Views/Games/
│   ├── GameContainer.swift   marco común: título, «Listo» siempre visible, voz, cierre festejado
│   ├── SequenceGameView.swift, SortGameView.swift, MemoryGameView.swift
│   ├── BubblesView.swift, PetPlayView.swift
Tests/MeCuidoCoreTests/GamesTests.swift
pruebas-ui/juego-*.yaml       un recorrido de Maestro por juego
```
`Models/Games/` solo importa Foundation y Observation (lo compila `MeCuidoCore` y lo prueba `swift test`).

### 4.2 Cambios a lo existente (mínimos)
| Archivo | Cambio | Riesgo y cuidado |
| :-- | :-- | :-- |
| `HomeView.swift` (`Route`) | `case game(GameKind, Routine)` | Al terminar o salir: `path.removeLast()` (vuelve a «Mis pasos»), nunca vaciar todo el `path` |
| `RoutineStepsView.swift` | Botón secundario con el juego «antes» si `settings.miniGames` | «¡Empezar!» sigue siendo el principal |
| `CelebrationView.swift` | Los juegos premio se muestran **dentro** de la misma celebración (cambio de estado), no en otra hoja encima | Evita presentaciones anidadas (la causa del cierre que se corrigió) |
| `SettingsStore.swift` | `miniGames: Bool` (clave nueva `settings.miniGames`, encendido por defecto) | Clave nueva, no se renombra ninguna |
| `SettingsView.swift` | Sección «Minijuegos» con el interruptor y explicación | — |
| `ProgressStore.swift` | `gamesPlayed` (clave nueva `gamesPlayed`, solo sube) | Clave nueva |
| `Achievement.swift` | Estampa «Mente curiosa» (5 juegos terminados) | No cambia los requisitos de las existentes |
| `SoundService.swift` | Cue `.match` (dos notas suaves) | Solo sonidos alegres |

**No cambia** el formato de `rutinas.json` ni de los respaldos: el juego de cada rutina se deduce de su id y de
su número de pasos. Elegir el juego por rutina desde Ajustes queda para después (decisión abierta).

### 4.3 Reglas de estabilidad para el código de juegos
Aprendidas de los cierres corregidos en la Fase 4:
- **Nada de presentaciones anidadas** (hoja sobre hoja o pantalla completa sobre pantalla completa).
- **Listas por id, nunca por índice** (`ForEach` sobre valores con `id`; nada de `ForEach($arreglo)`).
- **Temporizadores solo con `.task`** ligado a la vista (se cancela al salir); nada de `Timer` suelto.
- **Audio solo con `AVAudioPlayer`/`SpeechService`**; nunca `AVAudioEngine`.
- **Sin `!`, `try!`, `fatalError`, `assert` ni subíndices sin comprobar** en código de app.
- **Generador aleatorio inyectado** en todos los modelos (pruebas y recorridos repetibles).
- Salir del juego no toca el progreso de la rutina.

---

## 5. Etapas

Cada etapa = una rama, commits pequeños, CI en verde, prueba en iPad real y luego unión a `main`.

### E0 · v0.6.1 · Cerrar la estabilidad (en curso)
- [x] Celebración: salir hasta que se cierra (corrige el cierre al volver al inicio).
- [x] Campanitas con `AVAudioPlayer` (corrige el cierre posible en «¡Hecho!»).
- [x] Editor de rutinas por id (corrige el cierre posible al borrar pasos).
- [x] Fotos reducidas al leerlas (memoria).
- [x] Guardado sin `assertionFailure`; archivo dañado apartado, no sobrescrito; ids de paso únicos.
- [x] CI: abrir en el simulador de iPad y capturas.
- [ ] CI: recorrido completo con Maestro en verde (rama `pruebas-ui`).
- [ ] iPad real: 10 rutinas seguidas, ajustes, mascota, foto y voz, sin cierres (guía `docs/instalar-en-ipad.md`).
- **Listo cuando:** CI verde (4 trabajos) + checklist de iPad firmada por dos personas del equipo.

### E1 · v0.6.2 · Red de seguridad de pruebas
- Recorridos de Maestro para **cada** pantalla actual: guía con «Paso anterior», «Más tiempo», «Pausa»,
  revisión con «Ver otra vez», álbum, fondos, editor (crear, reordenar, borrar paso, borrar rutina), respaldo.
- Argumento de arranque solo en Debug (`-semilla N`) para fijar los generadores aleatorios en los recorridos.
- Recorrido con texto grande (Dynamic Type XXL) y otro con «Reducir movimiento».
- Capturas reales del simulador reemplazan las maquetas de `docs/screenshots/` (tarea de la Fase 7 adelantada).
- **Listo cuando:** cada botón de la app lo toca al menos un recorrido, en verde.

### E2 · v0.6.3 · Motor de juegos + «¿Qué sigue?»
- `GameKind`, `SequenceGame`, `GameLines` + pruebas (orden revuelto nunca igual al correcto, pista tras toque
  equivocado, fin al llenar, rutinas de 1 paso sin juego).
- `GameContainer` y `SequenceGameView`; `Route.game`; botón en «Mis pasos»; interruptor en Ajustes.
- `gamesPlayed` y estampa «Mente curiosa».
- Recorrido `pruebas-ui/juego-secuencia.yaml`.
- **Listo cuando:** se juega con las 5 rutinas incluidas y con una personalizada de 2 y de 5 pasos, con
  VoiceOver y con texto grande, y al terminar regresa a «Mis pasos» con el progreso intacto.

### E3 · v0.6.4 · Memorama y clasificar
- `MemoryGame`, `SortGame`, `SortCatalog` + pruebas (nunca 3 cartas descubiertas, parejas correctas, 6 objetos
  sin repetir, respuesta «distinta» no bloquea).
- Vistas y recorridos de Maestro.
- **Listo cuando:** cama → memorama, mochila → clasificar, herida → botiquín, cada uno de principio a fin en
  iPad real.

### E4 · v0.6.5 · Juegos de premio en la celebración
- `BubbleField` + pruebas; `BubblesView`; `PetPlayView`.
- La celebración cambia de estado (felicitación → juego → felicitación) dentro de la misma pantalla completa.
- **Listo cuando:** se terminan 5 rutinas seguidas jugando cada vez y volviendo al inicio, sin cierres
  (recorrido de Maestro con 5 vueltas).

### E5 · v0.6.6 · Pulido y validación rápida
- Auditoría con Accessibility Inspector de cada juego; Switch Control y Voice Control (`accessibilityInputLabels`).
- Rendimiento: animaciones fluidas en el iPad más antiguo disponible; memoria estable tras 20 partidas.
- Prueba corta con 2 o 3 niños del rango de edad (con consentimiento): ¿entienden cada juego sin ayuda?,
  ¿los juegos «antes» ayudan o distraen? Ajustar o quitar lo que distraiga.
- Actualizar `CLAUDE.md`, `README.md`, `docs/ruta-de-desarrollo.md` y subir a **v0.6.6**.

### Después: ruta original
Fase 5 (perfiles y bitácora; la bitácora registra también los juegos), Fase 6 (accesibilidad avanzada),
Fase 7 (validación), Fase 8 (publicación). Los juegos se revisan contra los requisitos de la categoría Niños.

---

## 6. Proceso de calidad en cada cambio

1. **Antes de programar:** releer las reglas de la sección 1 y la 4.3.
2. **Modelo primero:** la lógica nueva va en `Models/` con su prueba, que debe fallar antes de implementarla.
3. **Vista:** con `#Preview` y los stores que use, textos en español neutral, `Theme` para colores y medidas.
4. **Local:** `swift test` (Docker en Windows) y revisión de sintaxis.
5. **Rama + push:** el CI corre los 4 trabajos (sintaxis, pruebas, compilar, simulador + Maestro).
6. **Revisión de código** antes de unir (`/code-review`).
7. **iPad real** al cerrar cada etapa con la checklist de `docs/instalar-en-ipad.md`.
8. **Unir a `main`** solo con todo lo anterior en verde; subir versión al cerrar la etapa.

### Definición de «terminado» de un juego
- [ ] Cumple las 9 reglas de la sección 1.
- [ ] Modelo con pruebas (casos normales y bordes: 1 paso, 5 pasos, toques repetidos, salir a la mitad).
- [ ] Recorrido de Maestro completo en verde.
- [ ] VoiceOver: se puede jugar entero; cada carta dice qué es y en qué estado está.
- [ ] Texto grande (XXL) y «Reducir movimiento» revisados.
- [ ] Probado en iPad real en vertical y horizontal.

---

## 7. Riesgos y cómo se evitan

| Riesgo | Probabilidad | Impacto | Mitigación |
| :-- | :-- | :-- | :-- |
| El juego distrae de la rutina real | Media | Alto | Siempre opcional, uno por rutina, corto; se valida en E5 y se quita si distrae |
| Frustración al no acertar | Media | Alto | Sin forma de perder; pistas progresivas; la respuesta correcta se resalta a la segunda pista |
| Cierres por navegación anidada | Media | Alto | Juegos de premio dentro de la celebración; `Route` para los de antes; recorridos de Maestro con varias vueltas |
| Recorridos de Maestro frágiles (textos que cambian) | Alta | Medio | Buscar por etiquetas de accesibilidad estables; semilla fija; revisar recorridos en cada cambio de texto |
| Animaciones lentas en iPads viejos | Baja | Medio | Pocas vistas animadas a la vez; medir en E5 |
| Contenido inadecuado en los catálogos | Baja | Medio | La maestra valida `SortCatalog` antes de E3 |
| Más alcance del que da el tiempo | Media | Medio | Cada etapa es útil por sí sola; E4 y E5 se pueden recortar sin romper lo anterior |

---

## 8. Calendario sugerido

| Etapa | Duración estimada | Depende de |
| :-- | :-- | :-- |
| E0 | 2–3 días (falta la prueba en iPad) | — |
| E1 | 3–4 días | E0 |
| E2 | 4–5 días | E1 |
| E3 | 4–5 días | E2 |
| E4 | 3–4 días | E2 |
| E5 | 3–5 días | E3, E4 |

E3 y E4 pueden ir en paralelo (dos personas) después de E2.

---

## 9. Decisiones abiertas para el equipo

1. **¿«Rincón de juegos» libre en el inicio?** Recomendación: no en v1; si se agrega, que se abra solo después de
   terminar las rutinas del día.
2. **Burbujas «pasivas» durante «Tallar con jabón»** (se ven pero no se tocan, duran 20 s): ¿ayudan a contar
   el tiempo o distraen? Probar en E5.
3. **Elegir el juego por rutina desde Ajustes** (hoy se deduce de la rutina): ¿hace falta en v1?
4. **Objetos de «¿Va en la mochila?» y «Mi botiquín»:** lista final validada con la maestra.
5. **Ilustraciones propias** para los objetos de los juegos (hoy serían SF Symbols): ¿las hace el equipo?
