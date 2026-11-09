// =====================================================================
//  CONFIGURACIÓN — el único archivo que tienes que editar a mano
// =====================================================================
// Supabase > Project Settings > API: copia "Project URL" y la clave "anon public".
// (La anon key es pública por diseño; la seguridad la da el Row Level Security del SQL.)
window.CONFIG = {
  SUPABASE_URL: "https://gpeikjhkaeuzpbujxmsm.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwZWlramhrYWV1enBidWp4bXNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyNTA2NTQsImV4cCI6MjEwOTgyNjY1NH0.VnOOmIPECApBq-NLKXbHTwCokEJZEF30B5ALoWHYES8",

  // Los mismos correos que pusiste en el SQL (función es_viajero)
  CORREO_ISA: "avilaisabel1218@gmail.com",
  CORREO_IVAN: "ivan.maceda.2309@gmail.com",
};
