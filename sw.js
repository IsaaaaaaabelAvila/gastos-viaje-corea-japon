// Service worker: deja la app disponible sin internet.
// Si cambias index.html o config.js, sube el número de VERSION para forzar la actualización.
const VERSION = "v3";
const CACHE = "gastos-viaje-" + VERSION;
const SUPABASE_JS = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.min.js";
const SHELL = [
  "./",
  "index.html",
  "config.js",
  "manifest.json",
  "icon-192.png",
  "icon-512.png",
  "icon-maskable-512.png",
  "apple-touch-icon.png",
];

self.addEventListener("install", (e) => {
  e.waitUntil(
    caches.open(CACHE).then(async (c) => {
      await c.addAll(SHELL);
      try { await c.add(SUPABASE_JS); } catch (_) { /* se reintenta en la primera visita en línea */ }
    }).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // Nunca interceptar Supabase (API, auth, realtime) ni la API de tipo de cambio
  if (url.hostname.endsWith("supabase.co") || url.hostname.endsWith("supabase.in") ||
      url.hostname.includes("er-api.com") || url.hostname.includes("frankfurter")) return;

  // Librería del CDN: caché primero
  if (url.hostname === "cdn.jsdelivr.net" || url.hostname === "cdnjs.cloudflare.com") {
    e.respondWith(
      caches.match(req).then((hit) => hit || fetch(req).then((res) => {
        if (res.ok) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put(req, copy)); }
        return res;
      }))
    );
    return;
  }

  // Archivos propios: muestra lo guardado al instante y actualiza en segundo plano
  if (url.origin === location.origin) {
    e.respondWith(
      caches.open(CACHE).then(async (c) => {
        const hit = await c.match(req, { ignoreSearch: true });
        const net = fetch(req).then((res) => {
          if (res.ok) c.put(req, res.clone());
          return res;
        }).catch(() => null);
        if (hit) { net.catch(() => {}); return hit; }
        const res = await net;
        if (res) return res;
        if (req.mode === "navigate") return (await c.match("index.html")) || (await c.match("./"));
        return Response.error();
      })
    );
  }
});
