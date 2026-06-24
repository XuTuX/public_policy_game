import { createClient } from "npm:@supabase/supabase-js";
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);
async function run() {
  const { data, error } = await supabase.rpc("publish_latest_game_set");
  console.log("Publish RPC:", data, error);

  // Let's also check how many valid bills there are
  const { data: bills, error: err2 } = await supabase.from('assembly_bills')
    .select('id, official_yes_count, member_votes(count)');
  console.log("Total bills:", bills?.length, err2);
  let validCount = 0;
  if (bills) {
    for (const b of bills) {
       // Since we can't easily do the full complex join here, just a rough check
       // But wait, the criteria is strict.
       if (b.member_votes && b.member_votes[0].count > 0) validCount++;
    }
  }
  console.log("Bills with votes:", validCount);
}
run();
