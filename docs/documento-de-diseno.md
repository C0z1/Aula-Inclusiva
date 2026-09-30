# DOCUMENTO DE DISEÑO DE APLICACIÓN
**Swift · SwiftUI · Apple HIG · Design Thinking**

*Plantilla de trabajo. Completa cada sección con decisiones concretas del equipo. El documento debe evolucionar junto con el diseño y desarrollo de la aplicación.*

---

## Información General

* **Nombre de la aplicación:** Me Cuido, Me Organizo
* **Equipo / Integrantes:**
  * Andrea Mateo Maximino – AL07147722
  * Ana Cecilia Medina Hernández – AL03081462
  * María Fernanda Medina Ramírez – AL0786501
  * Félix Yael Tavera Ramírez – AL07003384
  * Evan Isaac Hernández Pérez – AL07196742
* **Materia / Grupo:** Aula Inclusiva Miércoles
* **Fecha:** 13 – Septiembre – 2026
* **Versión del documento:** 1

---

## 1. SELECCIÓN DE IMPACTO
> **Design Thinking: EMPATIZAR**  
> Define a quién ayudará la aplicación, qué habilidad busca potenciar y qué cambio esperamos generar en la vida cotidiana.

* **Nombre provisional de la App:** Me Cuido, Me Organizo
* **Impacto seleccionado:** Organizarme; Cuidarme; Ser más Independiente.
* **Perfil de usuario al que va dirigida:** Niños de 8 a 12 años con TDA (Trastorno por Deficiencia de Atención), dificultades en motricidad fina/aguda y retos en la autonomía de organización personal y autocuidado cotidiano.
* **Necesidad educativa / necesidad de apoyo identificada:** Dificultad para recordar, secuenciar y ejecutar independientemente rutinas básicas diarias (higiene, curación simple de heridas, atado de agujetas, orden de útiles escolares y tendido de cama) debido a problemas de concentración, memoria de trabajo reducida y retos motrices al interactuar con interfaces complejas.
* **Habilidad que queremos aprender, mejorar o potenciar:** La autorregulación, la secuenciación de tareas en el tiempo y el desarrollo de habilidades motrices y de autonomía personal.
* **Actividad de vida diaria o actividad motriz relacionada:** Organización de objetos personales (juguetes / útiles escolares / cama), atado de agujetas, hábitos de higiene diaria e identificación de pasos básicos de primeros auxilios / autocuidado.

### Prueba de autonomía
*La aplicación debe acompañar y potenciar la actividad, no sustituirla. Considera la premisa: «Toda ayuda innecesaria incapacita».*

* **ANTES — La persona necesita apoyo para:**  
  Recordar qué paso sigue en su rutina diaria, mantener la atención sin distraerse, y coordinar movimientos finos o estructurar mentalmente los pasos para actividades como atarse los zapatos o guardar sus útiles.
* **LA APP — Le ayudará mediante:**  
  Una secuencia de pictogramas animados claros, guías por audio, temporizadores visuales simples e interacciones físicas adaptadas (botones grandes y gestos amplios de arrastrar/soltar en iPad) complementadas con un sistema de avatares y mascotas como incentivo positivo.
* **DESPUÉS — Esperamos que pueda:**  
  Identificar e iniciar sus rutinas del día de manera autónoma, completar la secuencia física en el mundo real siguiendo el temporizador visual y corregir de forma independiente el olvido de algún paso.
* **FUERA DE LA APP — Actividad que deberá realizar en el mundo real:**  
  Atarse los cordones de los zapatos, recoger y ordenar sus juguetes/útiles escolares, tender su cama e implementar hábitos de higiene e instrucciones básicas frente a una pequeña herida.

---

## 2. DEFINICIÓN DEL RETO
> **Design Thinking: DEFINIR**  
> Formula un reto específico.  
> *Usa la estructura: ¿Cómo podríamos ayudar a [persona] a desarrollar [habilidad] mediante [experiencia] para conseguir [impacto/autonomía]?*

### Nuestro reto de diseño:
> ¿Cómo podríamos ayudar a niños de 8 a 12 años con TDA y dificultades motrices a desarrollar autonomía en su autocuidado y organización diaria mediante una experiencia interactiva en iPad con guías visuales, auditivas y recompensas motivacionales para conseguir mayor independencia en su vida cotidiana sin depender de la supervisión constante de un adulto?

### Objetivos de la aplicación
* **Objetivo 1:** Facilitar la ejecución autónoma de rutinas diarias a través de la estructuración visual por pasos (pictogramas y animaciones) adaptados a la capacidad de atención del niño.
* **Objetivo 2:** Reducir la frustración motriz en el uso del dispositivo diseñando interfaces accesibles en iPad (target táctil grande, gestos tolerantes a la imprecisión y asistencia por audio).
* **Objetivo 3:** Fomentar el hábito de la autogestión y perseverancia en el mundo real utilizando un sistema inclusivo de recompensas digitales (avatares, accesorios y mascotas).

---

## 3. PRINCIPIOS HIG EN NUESTRA APP
> **Design Thinking: IDEAR**  
> Selecciona los principios que aportan valor real a tu usuario. Indica cómo se aplicarán y en qué parte de la experiencia estarán presentes.

| Principio HIG | ¿Se incorpora? | ¿Cómo se relaciona con la App? | ¿Dónde estará presente? |
| :--- | :---: | :--- | :--- |
| **Accesibilidad** | ☑ Sí | Permite que niños con retos visuales, motores o auditivos interactúen sin barreras mediante elementos de gran tamaño y audiodescripción | En todas las pantallas de navegación, tarjetas de actividades y botones de acción |
| **Claridad** | ☑ Sí | Minimiza las distracciones visuales (en especial para TDA), priorizando el contenido principal con tipografías legibles y pictogramas directos | En la visualización de los pasos ("Mis pasos siguientes") y el temporizador visual |
| **Retroalimentación** | ☑ Sí | Confirma al niño que ha completado un paso exitosamente mediante sonidos amigables, vibraciones (hápticos) y animaciones de festejo | Al pulsar el botón "¡Hecho!" y al desbloquear medallas o accesorios de avatar |
| **Adaptabilidad** | ☑ Sí | Se ajusta tanto a la orientación del dispositivo como al ritmo individual de trabajo del niño sin presiones punitivas | En la velocidad del temporizador visual y en las opciones de soporte de audio/texto |
| **Control del usuario** | ☑ Sí | El niño decide cuándo avanzar de paso y puede pausar o revisar instrucciones previas si se siente desorientado | En el reproductor de pasos de las rutinas y la navegación libre del avatar, así como el aumento o reducción de tiempos (Adaptable) |
| **Consistencia** | ☑ Sí | Utiliza los mismos colores, íconos y ubicación de botones en todas las actividades para evitar la sobrecarga cognitiva | En la estructura general de la interfaz y botones de retroceso/confirmación |
| **Comunicación inclusiva** | ☑ Sí | Lenguaje positivo, alentador, apto para la infancia y neutral respecto a capacidades o género | En las instrucciones habladas, mensajes de felicitación y nombres de logros |

---

## 4. HIG + HERRAMIENTAS DEL ECOSISTEMA APPLE
> **Design Thinking: IDEAR**  
> Relaciona la necesidad del usuario con el principio HIG y con una herramienta o capacidad de Apple que permita implementarlo.

| Necesidad del usuario | Principio HIG | Herramienta Apple | ¿Cómo la utilizaremos? |
| :--- | :--- | :--- | :--- |
| **Dificultad para leer textos largos o concentrarse** | Claridad / Accesibilidad | VoiceOver / Synthesized Speech | Para narrar en voz alta las instrucciones de cada paso y el nombre de los pictogramas |
| **Problemas de motricidad fina (pulsación imprecisa)** | Accesibilidad | Accessibility Targets / Large Interactive Areas | Creando botones con un área táctil mínima de 60x60pt y gestos amplios de arrastrar y soltar en la pantalla amplia del iPad |
| **Pérdida de noción del tiempo o distracción constante** | Adaptabilidad | SF Symbols & Custom Animations | Implementando temporizadores con barras o círculos de progreso visuales animados para indicar el tiempo sin generar ansiedad |
| **Confirmación de acciones realizadas físicamente** | Retroalimentación | Core Haptics (Feedback Háptico) | Emitiendo vibraciones rítmicas gratificantes al marcar una tarea o paso como terminado |
| **Dificultades de percepción visual o sobreestimulación** | Claridad | Alto Contraste / Reduce Motion | Asegurando una paleta cromática de alto contraste y soportando la reducción de movimiento para niños sensibles |

---

## 5. USER FLOW — FLUJO DE LA APLICACIÓN
> **Design Thinking: PROTOTIPAR**  
> Representa el recorrido principal del usuario desde que entra a la aplicación hasta que completa la actividad. Incluye decisiones, retroalimentación, errores y regreso.

### Descripción del flujo principal:
1. **Inicio:** El niño ingresa a la **Pantalla 1 (Agenda/Inicio)** donde ve a su mascota/avatar y selecciona su tarea del momento (ej. *"Atarme los zapatos"* o *"Acomodar mis útiles"*).
2. **Secuencia de Pasos:** Pasa a la **Pantalla 2 (Mis pasos siguientes)** donde visualiza el mapa de progreso completo de la rutina.
3. **Ejecución Interactiva:** Selecciona el paso activo e ingresa a la **Pantalla 3 (Guía visual en acción)**, donde una animación/pictograma gigante, una voz explicativa y un temporizador lo acompañan a hacer la actividad real fuera del iPad.
4. **Confirmación y Recompensa:** Al presionar el botón grande *"¡Hecho!"*, recibe retroalimentación sonora/háptica, avanza al siguiente paso o regresa a la Pantalla 1 para obtener sus medallas y recompensas (ropa/accesorios para su avatar).

---

## 6. DEFINICIÓN DE PANTALLAS
> **Design Thinking: PROTOTIPAR**

### Pantalla 1: Agenda Principal y Avatar (Inicio)

* **Objetivo de la pantalla:** Permitir al usuario reconocer las tareas del día, acceder a la agenda visual y ver el estado de su avatar/mascota.
* **Acción principal del usuario:** Tocar la tarjeta de la rutina diaria que le toca realizar.
* **Información que debe mostrar:** Avatar personalizable, medallas obtenidas, lista visual de rutinas (iconos grandes de higiene, orden y autocuidado).
* **Componentes SwiftUI sugeridos:** `VStack`, `LazyVGrid`, `Image`, `Text`, `Button`.
* **Principios HIG presentes:** Claridad, Consistencia, Accesibilidad.
* **Consideraciones de accesibilidad:** Tarjetas grandes con etiquetas VoiceOver legibles y orden de lectura claro.
* **Siguiente pantalla / acción:** Navega a la *Pantalla 2: Mis Pasos Siguientes*.

---

### Pantalla 2: Mis Pasos Siguientes (Plan de la Rutina)

* **Objetivo de la pantalla:** Dar estructura mental mostrando la secuencia completa de pasos que componen la rutina seleccionada.
* **Acción principal del usuario:** Seleccionar el primer paso pendiente para iniciar la guía.
* **Información que debe mostrar:** Barra de progreso general, lista horizontal o vertical de pictogramas por paso (ej. *1. Cruzar las agujetas*, *2. Hacer las orejitas de conejo*, *3. Apretar el nudo*).
* **Componentes SwiftUI sugeridos:** `ScrollView(.horizontal)`, `HStack`, `ProgressView`, `ZStack`.
* **Principios HIG presentes:** Adaptabilidad, Control del usuario, Retroalimentación.
* **Consideraciones de accesibilidad:** Indicación de estado (completado/pendiente) visual y por voz, compatible con *Differentiate Without Color*.
* **Siguiente pantalla / acción:** Navega a la *Pantalla 3: Guía Visual Interactiva*.

---

### Pantalla 3: Guía Visual en Acción (Ejecución real)

* **Objetivo de la pantalla:** Guiar al niño en tiempo real para hacer la actividad física fuera del dispositivo.
* **Acción principal del usuario:** Observar la guía visual, escuchar el audio, realizar la acción en el mundo real y presionar el botón gigante de *"¡Listo / Hecho!"*.
* **Información que debe mostrar:** Animación/pictograma grande enfocado, botón de reproducción de audio instruccional, temporizador visual en forma de anillo, botón gigante de avance.
* **Componentes SwiftUI sugeridos:** `Image`, `Button` customizado con `.frame(minWidth: 120, minHeight: 80)`, `AudioPlayerService`, `Gauge` / `ProgressView`.
* **Principios HIG presentes:** Retroalimentación, Claridad, Comunicación inclusiva.
* **Consideraciones de accesibilidad:** Botón táctil sobredimensionado con feedback háptico (`.sensoryFeedback`), narración de texto a voz automática.
* **Siguiente pantalla / acción:** Siguiente paso de la rutina o Pantalla de Celebración / Avatar (Pantalla 1) si terminó todos los pasos.

---

## 7. USER INTERFACE — UI
> **Design Thinking: PROTOTIPAR**  
> Define las reglas visuales que mantendrán una interfaz consistente. Las decisiones estéticas no deben comprometer la accesibilidad.

| Elemento | Definición del equipo |
| :--- | :--- |
| **Color principal** | Azul Azulado Cálido (`#2A75D3`) — Transmite calma, seguridad y confianza |
| **Color secundario** | Verde Esperanza (`#06D6A0`) — Para destacar botones de éxito, recompensas y llamadas a la acción |
| **Tipografía** | San Francisco Rounded (Tipografía del sistema Apple en su versión redondeada, altamente legible y accesible para niños) |
| **Jerarquía y tamaños de texto** | • Títulos principales: `.largeTitle.bold()` (34pt)<br>• Subtítulos y pasos: `.title2.weight(.semibold)` (22pt)<br>• Botones: `.body.bold()` (17pt+) |
| **Botón principal** | Botón grande de bordes muy redondeados (cápsula/corner radius 20), color verde vibrante con ícono SF Symbol de verificación (`checkmark.circle.fill`) |
| **Botón secundario** | Botón redondeado de color neutro/azul claro para "Escuchar de nuevo" o "Volver atrás" |
| **Iconografía / SF Symbols** | Símbolos nativos de Apple: `sparkles` (recompensas), `clock.fill` (temporizador), `speaker.wave.2.fill` (audio), `checkmark.seal.fill` (logro) |
| **Espaciado** | Espaciamiento amplio (padding de 20 a 32pt) entre elementos para evitar toques accidentales debido a dificultades motrices |
| **Formas / bordes** | Tarjetas de contenido con esquinas suavizadas (`RoundedRectangle(cornerRadius: 16)`), evitando ángulos rectos agresivos |
| **Estados visuales** | • **Éxito:** Verde con destellos y sonido alegre.<br>• **Alerta/Pausa:** Amarillo pastel suave.<br>• **Error/Reintento:** Azul suave animado con mensaje alentador (sin color rojo castigador). |

---

## 8. USER EXPERIENCE — UX
> **Design Thinking: PROTOTIPAR**  
> Evalúa la experiencia completa desde la perspectiva del usuario.

| Pregunta | Evaluación | Observaciones / ajustes |
| :--- | :---: | :--- |
| **¿El usuario entiende qué debe hacer?** | Sí | Uso prioritario de pictogramas ilustrativos y soporte de voz para cada paso |
| **¿Sabe qué sucedió después de realizar una acción?** | Sí | Cada pulsación activa una respuesta auditiva, háptica (vibración) y visual clara |
| **¿Puede equivocarse y recuperarse?** | Sí | No hay penalizaciones de tiempo ni pérdida de puntos; el niño puede repetir un paso o pausar en cualquier momento |
| **¿La aplicación ayuda sin realizar la actividad por la persona?** | Sí | Cumple con la premisa: la app le muestra el "cómo" en pantalla, pero la acción física la realiza el niño en el mundo real |
| **¿La experiencia invita a realizar una actividad fuera del dispositivo?** | Sí | Las imágenes y audios le indican explícitamente ejecutar la acción (ej. doblar la ropa, atarse la agujeta) antes de avanzar |
| **¿Después de utilizarla puede realizar mejor la actividad en el mundo real?** | Sí | Fomenta la memoria muscular y la asimilación del orden de los pasos por medio de la repetición constante |

---

## 9. VALIDACIÓN DEL PROTOTIPO
> **Design Thinking: VALIDAR**  
> Entrega el prototipo a otro equipo o usuario de prueba sin explicar cómo utilizarlo. Observa su recorrido y registra los hallazgos.

| Criterio | Resultado | Observaciones |
| :--- | :---: | :--- |
| **Entendió qué hacer** | ☑ Sí \| ☐ Parcial \| ☐ No | El pictograma grande facilitó la comprensión inmediata de la tarea activa |
| **Navegó sin explicación** | ☑ Sí \| ☐ Parcial \| ☐ No | El botón principal de avance captó la atención del usuario sin requerir ayuda previa |
| **Los controles fueron claros** | ☑ Sí \| ☐ Parcial \| ☐ No | Los tamaños de botón evitaban toques erróneos |
| **Recibió retroalimentación** | ☑ Sí \| ☐ Parcial \| ☐ No | La respuesta de audio y vibración confirmó con éxito el fin de cada paso |
| **Encontró cómo regresar** | ☑ Sí \| ☐ Parcial \| ☐ No | El botón de retorno superior siempre estuvo disponible |
| **La experiencia fue consistente** | ☑ Sí \| ☐ Parcial \| ☐ No | Se mantuvo la misma estructura visual en las 3 pantallas principales |
| **Identificó la actividad fuera de la App** | ☑ Sí \| ☐ Parcial \| ☐ No | Comprendió que el objetivo era manipular los objetos reales de su entorno |
| **La App promueve autonomía** | ☑ Sí \| ☐ Parcial \| ☐ No | La secuencia guiada redujo la dependencia de indicaciones verbales del adulto |

### Retroalimentación cualitativa:
* **Lo que entendió el usuario:** Entendió que la app es un organizador interactivo que le va mostrando "dibujos y sonidos" sobre cómo vestirse, ordenarse o curarse una herida paso a paso.
* **Lo que generó confusión:** Al inicio intenta tocar las animaciones creyendo que era un videojuego directo, en lugar de realizar la acción física primero.
* **Cambios que realizaremos:** Haremos más enfático el temporizador visual e incluiremos una locución de voz clara que diga: *"¡Ahora hazlo tú y presiona el botón cuando termines!"*.

---

## 10. CIERRE Y SIGUIENTE ITERACIÓN
> **Design Thinking: VALIDAR**  
> Resume las decisiones que pasarán a la siguiente versión del diseño y posteriormente al desarrollo en SwiftUI.

* **La propuesta de valor de nuestra App es:**  
  Un asistente interactivo en iPad adaptado a niños con TDA y retos motrices, que transforma el aprendizaje del autocuidado y la organización en una experiencia visual, guiada y motivadora.
* **El impacto que queremos generar es:**  
  Aumentar la autonomía en niños de 8 a 12 años en sus rutinas cotidianas, fortaleciendo su autoestima y capacidad de autocuidado.
* **Las 3 decisiones de diseño más importantes son:**  
  1. Diseñar interfaces con target táctil amplio (área del botón aumentada) y gestos simplificados para compensar la imprecisión motriz.
  2. Sustituir textos largos por secuencias de pictogramas claros animados apoyados por narración en voz alta (VoiceOver / Speech).
  3. Vincular la conclusión exitosa de rutinas en el mundo real con recompensas visuales dentro de la app (desbloqueo de vestimenta/accesorios para su avatar).
* **Lo primero que construiremos en SwiftUI será:**  
  La pantalla de la guía de pasos (**Pantalla 3: Guía Visual en Acción**), implementando el botón grande accesible, la animación central y la estructura básica de audio-instrucción.
* **Criterio para considerar exitosa nuestra primera versión:**  
  Que un niño del rango de edad objetivo sea capaz de completar una rutina de 3 pasos (ej. atarse las agujetas u ordenar la mochila) guiándose únicamente por las indicaciones visuales y sonoras de la app de principio a fin.

---

### Ruta del proyecto
`IMPACTO` → `PERSONA` → `NECESIDAD` → `HIG` → `ACCESIBILIDAD` → `UX` → `UI` → `SWIFTUI` → `VALIDACIÓN` → `IMPACTO REAL`