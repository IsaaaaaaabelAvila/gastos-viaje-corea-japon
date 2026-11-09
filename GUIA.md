# Gastos del viaje Corea + Japón 2027 — guía

**App publicada:** https://isaaaaaaabelavila.github.io/gastos-viaje-corea-japon/
**Repositorio:** https://github.com/IsaaaaaaabelAvila/gastos-viaje-corea-japon
**Supabase:** proyecto `viaje-corea-japon` (región Tokio)

## Cómo funciona el acceso (sin correos)
- Entran con **correo + contraseña**. No se envía ningún correo.
- La primera vez, cada quien toca **«Es mi primera vez: crear mi cuenta»**, escribe su correo y la contraseña que quiera (mínimo 6 caracteres). Después solo «Entrar».
- Solo `avilaisabel1218@gmail.com` e `ivan.maceda.2309@gmail.com` pueden tener cuenta: lo bloquean la función `registro` y un trigger en la base de datos. Cualquier otro correo es rechazado.
- Aunque alguien conociera la URL y la anon key, el Row Level Security no deja leer ni escribir gastos sin sesión de uno de los dos correos.
- Si olvidan la contraseña: Supabase → Authentication → Users → el usuario → Send/Reset password, o borrar el usuario y volver a crear la cuenta desde la app.

## Instalar en el celular
Abre la URL en Chrome (Android) → menú ⋮ → **Instalar app**. Entra una vez; la sesión queda guardada.

## Convertir en APK (después)
1. https://www.pwabuilder.com → pega la URL de la app → **Package for stores → Android**.
2. Guarda el `signing.keystore` que te da. Instala el `.apk` en el teléfono (permitir orígenes desconocidos).
3. La app instalada como PWA desde Chrome (paso anterior) se comporta igual y sin barra de dirección.

## Cómo actualizar la app
Cambia los archivos en GitHub (lápiz ✏️ en el archivo) y sube el número `VERSION` de `sw.js` (`"v2"` → `"v3"`) para que los teléfonos descarguen la versión nueva. GitHub Pages tarda ~1 minuto en publicar.

## Archivos
`index.html` (app) · `config.js` (URL + anon key + correos) · `manifest.json` · `sw.js` · íconos · `supabase.sql` (esquema, ya aplicado) · `supabase/functions/registro/index.ts` (función de registro, ya desplegada).

---

## Lista de pruebas antes del viaje
- [ ] **Crear cuenta**: Isa y Iván, cada uno con su correo y contraseña; luego cerrar sesión y volver a entrar.
- [ ] **Correo ajeno**: intentar con otro correo → la app lo rechaza.
- [ ] **Vuelos precargados**: cada quien ve $22,601.04 gastado y $97,398.96 disponible.
- [ ] **Gasto sin internet**: modo avión → registrar un gasto → sale "pendiente" y el indicador dice "Sin conexión · 1 pendiente" → quitar modo avión → pasa a "Sincronizado".
- [ ] **Tiempo real**: Isa registra un gasto → a Iván le aparece solo (o con el botón ⟳).
- [ ] **Editar y borrar** un gasto en un celular → se ve el cambio en el otro.
- [ ] **Balance**: Isa paga algo 50/50 de $1,000 → Iván le debe $500. Registrar pago → "Están a mano".
- [ ] **Gasto personal**: "Solo Iván" pagado por Isa → solo baja el presupuesto de Iván y le debe el 100%.
- [ ] **Tramos**: en Ajustes definir Corea/Japón; un gasto en fecha de Japón propone yenes; el día de cambio propone Corea en la mañana y Japón desde las 2 pm.
- [ ] **Tipo de cambio**: «Actualizar en línea»; un gasto viejo no cambia su monto en MXN.
- [ ] **Tarjeta / cuenta**: uno con tarjeta y otro en efectivo (cuenta de retiro) → aparecen en «Por tarjeta / cuenta».
- [ ] **Presupuesto por categoría**: Hospedaje = $20,000 y registrar uno de $17,000 → aviso al 80%.
- [ ] **Exportar**: CSV (abrir en Excel) y respaldo JSON.
- [ ] **Instalada y sin internet**: cerrar la app, modo avión, abrirla → abre con los datos guardados.
- [ ] **Modo oscuro**.
