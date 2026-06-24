import { createClient } from "npm:@supabase/supabase-js";
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);
async function run() {
  const { data: sets, error: setErr } = await supabase.from('game_sets').select('*');
  console.log("Game sets:", sets, setErr);
  
  const { data: bills, error: billErr } = await supabase.from('game_set_bills').select('*');
  console.log("Game set bills count:", bills?.length);
}
run();
