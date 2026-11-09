# Guía: publicar la app de gastos del viaje (Corea + Japón 2027)

Archivos del proyecto (todos van en la raíz del repositorio, sin carpetas):

| Archivo | Para qué |
|---|---|
| `index.html` | Toda la app (diseño + lógica) |
| `config.js` | URL y anon key de Supabase + correos (ya viene llenado) |
| `manifest.json` | Para instalarla como app |
| `sw.js` | Funcionamiento sin internet |
| `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png` | Íconos |
| `supabase.sql` | Ya se ejecutó en tu proyecto; queda de respaldo (NO hace falta subirlo a GitHub) |

---

## 1. Supabase (ya hecho por Claude, solo faltan 2 cosas en el panel)

Ya está creado el proyecto **viaje-corea-japon** (región Tokio), con las tablas `gastos` y `config`,
Row Level Security (solo avilaisabel1218@gmail.com e ivan.maceda.2309@gmail.com), Realtime activado y los dos vuelos precargados.
`config.js` ya trae la URL y la anon key.

> Para pasar el proyecto "takto-os" a su propio correo se pausó (el plan gratis solo permite 2 proyectos activos). Se reactiva desde su panel cuando lo muevas.

### 1a. Agregar la URL de GitHub Pages (después del paso 3)
1. Entra a https://supabase.com/dashboard → proyecto **viaje-corea-japon**.
2. **Authentication → URL Configuration**.
3. **Site URL**: `https://TU-USUARIO.github.io/NOMBRE-REPO/`
4. **Redirect URLs → Add URL**: la misma `https://TU-USUARIO.github.io/NOMBRE-REPO/` (con la `/` final) → **Save**.

### 1b. Que el correo llegue a Iván (IMPORTANTE)
El correo gratuito de Supabase **solo envía a miembros del equipo de la organización** y con un límite muy bajo (≈2 por hora).
Elige UNA:
- **Fácil:** Supabase → tu organización → **Team → Invite** → invita a `ivan.maceda.2309@gmail.com` y que acepte la invitación. Así ya le llegan los enlaces.
- **Mejor para el viaje:** configurar un SMTP propio gratis (Resend o Brevo) en **Project Settings → Authentication → SMTP Settings**.

### 1c. Código de 6 dígitos (para la app instalada)
El enlace mágico se abre en el navegador, no dentro de la app instalada. Por eso la pantalla de acceso tiene un campo de **código**.
Para que el correo lo incluya: **Authentication → Emails → Magic Link** y agrega esta línea al cuerpo:

```html
<p>O escribe este código en la app: <b>{{ .Token }}</b></p>
```

(Authentication → Sign In / Providers → Email debe estar activado; ya lo viene por defecto.)

---

## 2. Subir los archivos a GitHub (sin terminal)

1. Entra a https://github.com e inicia sesión → arriba a la derecha **+ → New repository**.
2. **Repository name**: `gastos-viaje` · **Public** (necesario para Pages gratis) · **Create repository**.
3. En la página del repo toca **uploading an existing file** (o **Add file → Upload files**).
4. Arrastra estos 9 archivos juntos: `index.html`, `config.js`, `manifest.json`, `sw.js`, `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png`.
5. Abajo **Commit changes**.

> El repo es público, pero `config.js` solo tiene la anon key (pública por diseño). Sin iniciar sesión con uno de los 2 correos, nadie puede leer ni escribir datos.

## 3. Activar GitHub Pages y encontrar la URL

1. En el repo: **Settings → Pages** (menú izquierdo).
2. **Source: Deploy from a branch** → Branch **main** / carpeta **/ (root)** → **Save**.
3. Espera 1–2 minutos y recarga: arriba aparece **"Your site is live at https://TU-USUARIO.github.io/gastos-viaje/"**. Esa es tu URL.
4. Regresa al paso **1a** y pega esa URL en Supabase.

## 4. Instalar en el celular

- Abre la URL en Chrome (Android) → menú ⋮ → **Instalar app** / **Agregar a pantalla de inicio**.
- Inicia sesión una vez con tu correo (enlace o código). La sesión se queda guardada.

## 5. (Después) Convertirla en APK

1. Ve a https://www.pwabuilder.com y pega tu URL de GitHub Pages → **Start**.
2. **Package for stores → Android** → genera el paquete (te da un `.apk` y un `.aab`, más un archivo `signing.keystore` que debes guardar).
3. Copia el `.apk` al teléfono e instálalo (permite "instalar apps de orígenes desconocidos").
4. Para quitar la barra del navegador en la APK, PWABuilder te da un archivo `assetlinks.json` que se sube a `.well-known/` del dominio. Con GitHub Pages de proyecto esto no aplica bien; la app funciona igual, solo puede mostrar una barra de dirección. Instalarla como PWA desde Chrome (paso 4) da el mismo resultado sin barra.

---

## 6. Lista de pruebas antes del viaje

- [ ] **Login**: Isa y Iván entran cada uno con su correo (enlace y también con código).
- [ ] **Correo ajeno**: intentar entrar con otro correo → la app lo rechaza.
- [ ] **Vuelos precargados**: cada quien ve $22,601.04 gastado y $97,398.96 disponible.
- [ ] **Gasto sin internet**: modo avión → registrar un gasto → sale "pendiente" y el indicador dice "Sin conexión · 1 pendiente" → quitar modo avión → pasa a "Sincronizado".
- [ ] **Tiempo real**: Isa registra un gasto → a Iván le aparece solo (o con el botón ⟳).
- [ ] **Editar y borrar** un gasto desde un celular → se ve el cambio en el otro.
- [ ] **Balance**: Isa paga algo 50/50 de $1,000 → Iván le debe $500 a Isa. Registrar pago → queda en "Están a mano".
- [ ] **Gasto personal**: "Solo Iván" pagado por Isa → solo baja el presupuesto de Iván y Iván le debe el 100% a Isa.
- [ ] **Tramos**: en Ajustes definir Corea/Japón; un gasto en fecha de Japón propone yenes; en el día de cambio propone Corea en la mañana y Japón desde las 2 pm.
- [ ] **Tipo de cambio**: botón "Actualizar en línea" y verificar que un gasto viejo no cambia su monto en MXN.
- [ ] **Tarjeta / cuenta**: registrar uno con tarjeta y otro en efectivo (cuenta de retiro) y verlos en "Por tarjeta / cuenta".
- [ ] **Presupuesto por categoría**: poner Hospedaje = $20,000 y registrar uno de $17,000 → aviso al 80%.
- [ ] **Exportar**: CSV (abrir en Excel) y respaldo JSON.
- [ ] **Instalada y sin internet**: cerrar la app, modo avión, abrirla → abre con los datos guardados.
- [ ] **Modo oscuro**.

### Si actualizas la app
Edita el archivo en GitHub (lápiz ✏️) y cambia `VERSION = "v1"` en `sw.js` a `"v2"` para que los teléfonos descarguen la versión nueva.
