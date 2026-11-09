import { createClient } from "npm:@supabase/supabase-js@2";

// Crea la cuenta (ya confirmada, sin enviar correo) SOLO para Isa e Iván.
const PERMITIDOS = ["avilaisabel1218@gmail.com", "ivan.maceda.2309@gmail.com"];
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Método no permitido" }, 405);

  let email = "", password = "";
  try {
    const b = await req.json();
    email = String(b.email ?? "").trim().toLowerCase();
    password = String(b.password ?? "");
  } catch {
    return json({ error: "Datos inválidos" }, 400);
  }
  if (!PERMITIDOS.includes(email)) return json({ error: "Ese correo no está autorizado" }, 403);
  if (password.length < 6) return json({ error: "La contraseña debe tener al menos 6 caracteres" }, 400);

  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { error } = await admin.auth.admin.createUser({ email, password, email_confirm: true });
  if (error) {
    if (/already|registered|exists/i.test(error.message)) return json({ error: "Esa cuenta ya existe. Usa «Entrar»." }, 409);
    return json({ error: error.message }, 400);
  }
  return json({ ok: true });
});
