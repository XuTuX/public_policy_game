import { createClient } from "npm:@supabase/supabase-js";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

async function run() {
  const { data: bills, error: billsErr } = await supabase.from('assembly_bills')
    .select(`id, vote_date, bill_no, bill_summaries!inner(status)`)
    .eq('bill_summaries.status', 'ready')
    .not('vote_date', 'is', null)
    .order('vote_date', { ascending: false })
    .order('bill_no', { ascending: false })
    .limit(10);
    
  if (billsErr || !bills || bills.length === 0) {
    console.error("Failed to fetch bills", billsErr);
    return;
  }
  
  const selected_bills = bills.map(b => b.id);
  const fingerprintStr = [...selected_bills].sort().join(',');
  const fingerprint = btoa(fingerprintStr).replace(/=/g, '');
  
  // Try to find existing first
  const { data: existingSet } = await supabase.from('game_sets').select('id').eq('fingerprint', fingerprint).maybeSingle();
  let gameSetId = existingSet?.id;

  if (!gameSetId) {
    const { data: gameSet, error: setErr } = await supabase.from('game_sets')
      .insert({ fingerprint, data_as_of: new Date().toISOString() })
      .select('id')
      .single();
      
    if (setErr) {
      console.error("Failed to create game set", setErr);
      return;
    }
    gameSetId = gameSet.id;
    console.log(`Created new game set: ${gameSetId}`);
  } else {
    console.log(`Using existing game set: ${gameSetId}`);
  }
  
  const gameSetBills = selected_bills.map((bill_id, index) => ({
    game_set_id: gameSetId,
    bill_id,
    position: index + 1
  }));
  
  const { error: relErr } = await supabase.from('game_set_bills')
    .upsert(gameSetBills);
    
  if (relErr) {
    console.error("Failed to link bills", relErr);
  } else {
    console.log("Successfully linked bills to game set!");
  }
}
run();
