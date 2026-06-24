import { createClient } from "npm:@supabase/supabase-js";
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);
async function run() {
  const { data: bills, error: err2 } = await supabase.from('assembly_bills')
    .select(`
      id, bill_no, official_yes_count, official_no_count, official_abstain_count,
      member_votes(status)
    `);
  if (!bills) { console.log(err2); return; }
  
  const { data: summaries } = await supabase.from('bill_summaries').select('bill_id').eq('status', 'ready');
  const readyBillIds = new Set(summaries?.map(s => s.bill_id));

  let valid = 0;
  for (const b of bills) {
     if (!readyBillIds.has(b.id)) continue;
     let yes = 0, no = 0, abstain = 0;
     for (const v of b.member_votes) {
        if (v.status === 'yes') yes++;
        if (v.status === 'no') no++;
        if (v.status === 'abstain') abstain++;
     }
     if (yes === b.official_yes_count && no === b.official_no_count && abstain === b.official_abstain_count) {
        valid++;
        console.log(`Valid: ${b.bill_no}`);
     } else {
        console.log(`Mismatch ${b.bill_no}: Official(${b.official_yes_count},${b.official_no_count},${b.official_abstain_count}) vs Computed(${yes},${no},${abstain})`);
     }
  }
  console.log("Strict valid count:", valid);
}
run();
