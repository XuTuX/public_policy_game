import { createClient } from "npm:@supabase/supabase-js";
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);
async function run() {
  const { data: summaries, error } = await supabase.from('bill_summaries')
    .select('background_dialogue')
    .limit(5);
  
  if (error) {
    console.error("Error fetching summaries:", error);
    return;
  }
  
  console.log("Sample Background Dialogues:");
  summaries.forEach((s, idx) => {
    console.log(`\n--- Bill ${idx + 1} ---`);
    console.log(s.background_dialogue);
  });
}
run();

