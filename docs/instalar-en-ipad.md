# Instalar Me Cuido en un iPad real

Hay dos caminos. El **A** no necesita Mac.

## A · Swift Playgrounds en el iPad (sin Mac)

1. Instala **Swift Playgrounds** (gratis, App Store) en el iPad.
2. Pasa la carpeta `MeCuido.swiftpm` al iPad (AirDrop, iCloud Drive o la app Archivos).
3. Ábrela en Swift Playgrounds y presiona ▶︎ (Ejecutar).
4. Opcional: en el menú del proyecto, **Instalar en la pantalla de inicio** para tenerla como app.

## B · Xcode en una Mac (firma con cuenta gratuita)

### 1. Cuenta en Xcode
1. **Xcode → Settings… (⌘,) → Accounts**.
2. **+ → Apple ID → Continue** e inicia sesión. Sirve cualquier cuenta de iCloud personal (no hace falta pagar).

### 2. Abrir el proyecto y firmar
1. En Xcode: **File → Open…** y elige la carpeta **`MeCuido.swiftpm`**. No hay `.xcodeproj`, y no hace falta crear uno.
2. En el panel izquierdo, toca el ícono raíz **MeCuido** y luego la app **Me Cuido** → **Signing & Capabilities**.
3. En **Team**, elige la cuenta que agregaste (p. ej. «Juan Pérez (Personal Team)»). Xcode genera el certificado
   y escribe ese equipo en `teamIdentifier` de `MeCuido.swiftpm/Package.swift`.
4. **Bundle Identifier:** `mx.aulainclusiva.mecuido`. Si Xcode dice que ya está en uso, cámbialo por uno propio
   (p. ej. `com.tecmilenio.mecuido.<tu-nombre>`) **solo en tu Mac**; no subas ese cambio ni tu `teamIdentifier` al repositorio.

### 3. Preparar el iPad
1. Conecta el iPad a la Mac con cable. Si pregunta **¿Confiar en esta computadora?**, toca **Confiar** y escribe el código.
2. **Activa el Modo de desarrollador** (iPadOS 16 o posterior; sin esto la app no abre):
   **Configuración → Privacidad y seguridad → Modo de desarrollador → activar**. El iPad se reinicia; al volver,
   confirma **Activar**.

### 4. Instalar
1. En la barra superior de Xcode, en la lista de destinos, elige tu **iPad físico** (arriba del todo).
2. Presiona **⌘R** (Run).

### 5. Confiar en el desarrollador (solo la primera vez)
1. En el iPad: **Configuración → General → VPN y administración de dispositivos**.
2. En **App del desarrollador**, toca tu correo → **Confiar en «tu correo»**.
3. Abre **Me Cuido** desde la pantalla de inicio.

### Límites de la cuenta gratuita
- La app **deja de abrir a los 7 días**: conecta el iPad y vuelve a presionar ⌘R para renovarla. El progreso del
  niño se conserva si no borras la app.
- Máximo 3 apps firmadas a la vez por iPad.
- Para que dure más o para TestFlight hace falta el Apple Developer Program (Fase 8).

### Qué probar en el iPad
- Terminar una rutina completa hasta la celebración y **volver al inicio**, varias veces seguidas.
- Abrir los ajustes (mantener presionado el ⚙️ 2 s y responder la multiplicación).
- Elegir mascota, tomar una foto y grabar una voz para un paso.
- Si la app se cierra: **Configuración → Privacidad y seguridad → Análisis y mejoras → Datos de análisis**,
  busca `Me Cuido` (o `AppModule`) y comparte ese archivo con el equipo.
