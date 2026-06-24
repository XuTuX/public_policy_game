import {
  adminClient,
  assertCronAuthorization,
  errorResponse,
  jsonResponse,
  requiredEnv,
} from "../_shared/runtime.ts";
import {
  assemblyEndpoints,
  AssemblyRow,
  fetchAssemblyRows,
  integer,
  isoDate,
  text,
} from "../_shared/assembly_api.ts";
import { fetchOfficialSource } from "../_shared/source_document.ts";

const ASSEMBLY_AGE = 22;

function normalizeMemberVote(raw: string): "yes" | "no" | "abstain" | "not_voted" | null {
  const value = raw.replaceAll(/\s/g, "");
  if (["\ucc2c\uc131", "\uac00", "yes", "Y"].includes(value)) return "yes";
  if (["\ubc18\ub300", "\ubd80", "no", "N"].includes(value)) return "no";
  if (["\uae30\uad8c", "abstain", "\uae30\uad8c\ud45c"].includes(value)) return "abstain";
  if (["\ubd88\ucc38", "\ubbf8\ud22c\ud45c", "\uc7ac\uc11d\ud558지\uc54a음", "absent"].includes(value)) return "not_voted";
  return null;
}

function voteDateValue(row: AssemblyRow): number {
  const date = isoDate(row, "VOTE_DATE", "PROC_DT", "PROC_DATE") ?? "0000-00-00";
  return Number(date.replaceAll("-", ""));
}

Deno.serve(async (request) => {
  let runId: string | null = null;
  let billsSeen = 0;
  let votesSeen = 0;
  const failures: Array<{ billId: string; error: string }> = [];
  try {
    if (request.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);
    assertCronAuthorization(request);
    const apiKey = requiredEnv("ASSEMBLY_API_KEY");
    const supabase = adminClient();
    const { data: started, error: startError } = await supabase.rpc("start_sync_run", {
      p_job_name: "daily-assembly-sync",
    });
    if (startError) throw startError;
    runId = started as string;

    const [memberRows, tallyRows] = await Promise.all([
      fetchAssemblyRows(apiKey, assemblyEndpoints.members, { AGE: ASSEMBLY_AGE }),
      fetchAssemblyRows(apiKey, assemblyEndpoints.voteTallies, { AGE: ASSEMBLY_AGE }),
    ]);

    const members = memberRows.map((row) => ({
      member_code: text(row, "MONA_CD"),
      name: text(row, "HG_NM", "NAAS_NM"),
      party: text(row, "POLY_NM", "PLPT_NM"),
      district: text(row, "ORIG_NM", "ELECD_NM"),
      profile_image_url: text(row, "NAAS_PIC", "PROFILE_IMG") || null,
      assembly_age: ASSEMBLY_AGE,
      active: true,
      collected_at: new Date().toISOString(),
      raw_payload: row,
    })).filter((member) => member.member_code && member.name);

    if (members.length === 0) throw new Error("Assembly member API returned no members");
    const { error: memberError } = await supabase.from("assembly_members").upsert(members, {
      onConflict: "member_code",
    });
    if (memberError) throw memberError;

    const candidateLimit = Math.max(
      10,
      Math.min(Number.parseInt(Deno.env.get("SYNC_CANDIDATE_LIMIT") ?? "30", 10), 100),
    );
    const candidates = tallyRows
      .filter((row) => text(row, "BILL_ID") && text(row, "BILL_NO"))
      .sort((a, b) => voteDateValue(b) - voteDateValue(a))
      .slice(0, candidateLimit);

    for (const tally of candidates) {
      const assemblyBillId = text(tally, "BILL_ID");
      try {
        const billNo = text(tally, "BILL_NO");
        const details = await fetchAssemblyRows(
          apiKey,
          assemblyEndpoints.billDetail,
          { BILL_NO: billNo },
          20,
        );
        const detail = details.find((row) => text(row, "BILL_ID") === assemblyBillId) ?? details[0];
        if (!detail) throw new Error("Bill detail was not found");

        const billPayload = {
          assembly_bill_id: assemblyBillId,
          bill_no: billNo,
          bill_name: text(detail, "BILL_NAME") || text(tally, "BILL_NAME"),
          assembly_age: ASSEMBLY_AGE,
          proposer: text(detail, "PROPOSER", "RST_PROPOSER", "PUBL_PROPOSER"),
          committee: text(detail, "COMMITTEE", "CURR_COMMITTEE", "COMMITTEE_NM"),
          process_result: text(detail, "PROC_RESULT") || text(tally, "PROC_RESULT"),
          proposed_date: isoDate(detail, "PROPOSE_DT", "PROPOSE_DATE"),
          vote_date: isoDate(tally, "VOTE_DATE", "PROC_DT", "PROC_DATE"),
          official_source_url: text(detail, "LINK_URL", "DETAIL_LINK", "BILL_URL") ||
            `https://likms.assembly.go.kr/bill/billDetail.do?billId=${assemblyBillId}`,
          official_yes_count: integer(tally, "YES_TCNT", "YES_COUNT"),
          official_no_count: integer(tally, "NO_TCNT", "NO_COUNT"),
          official_abstain_count: integer(tally, "BLANK_TCNT", "ABSTAIN_COUNT"),
          collected_at: new Date().toISOString(),
          last_seen_at: new Date().toISOString(),
          raw_payload: { detail, tally },
        };
        if (!billPayload.bill_name || !billPayload.vote_date) {
          throw new Error("Bill is missing a name or vote date");
        }

        const { data: bill, error: billError } = await supabase
          .from("assembly_bills")
          .upsert(billPayload, { onConflict: "assembly_bill_id" })
          .select("id")
          .single();
        if (billError) throw billError;
        billsSeen++;

        const rollCalls = await fetchAssemblyRows(
          apiKey,
          assemblyEndpoints.memberVotes,
          { AGE: ASSEMBLY_AGE, BILL_ID: assemblyBillId },
          500,
        );
        if (rollCalls.length === 0) throw new Error("Bill has no per-member vote records");

        const knownMemberCodes = new Set(members.map((member) => member.member_code));
        const missingMembers = rollCalls
          .filter((row) => text(row, "MONA_CD") && !knownMemberCodes.has(text(row, "MONA_CD")))
          .map((row) => ({
            member_code: text(row, "MONA_CD"),
            name: text(row, "HG_NM", "NAAS_NM"),
            party: text(row, "POLY_NM", "PLPT_NM"),
            district: text(row, "ORIG_NM", "ELECD_NM"),
            assembly_age: ASSEMBLY_AGE,
            active: false,
            collected_at: new Date().toISOString(),
            raw_payload: row,
          }));
        if (missingMembers.length > 0) {
          const { error } = await supabase.from("assembly_members").upsert(missingMembers, {
            onConflict: "member_code",
          });
          if (error) throw error;
        }

        const votes = rollCalls.map((row) => {
          const rawVoteResult = text(row, "RESULT_VOTE_MOD", "VOTE_RESULT");
          const status = normalizeMemberVote(rawVoteResult);
          const memberCode = text(row, "MONA_CD");
          return status && memberCode ? {
            bill_id: bill.id,
            member_code: memberCode,
            status,
            raw_vote_result: rawVoteResult,
            party_at_vote: text(row, "POLY_NM", "PLPT_NM"),
            district_at_vote: text(row, "ORIG_NM", "ELECD_NM"),
            collected_at: new Date().toISOString(),
            raw_payload: row,
          } : null;
        }).filter((vote): vote is NonNullable<typeof vote> => vote !== null);
        if (votes.length === 0) throw new Error("No recognized member vote values");
        const { error: voteError } = await supabase.from("member_votes").upsert(votes, {
          onConflict: "bill_id,member_code",
        });
        if (voteError) throw voteError;
        votesSeen += votes.length;

        const source = await fetchOfficialSource(assemblyBillId, detail);
        const { error: sourceError } = await supabase.rpc("record_source_document", {
          p_bill_id: bill.id,
          p_source_url: source.url,
          p_source_text: source.sourceText,
          p_source_hash: source.sourceHash,
          p_extraction_method: source.method,
        });
        if (sourceError) throw sourceError;
      } catch (error) {
        failures.push({
          billId: assemblyBillId,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    const { error: finishError } = await supabase.rpc("finish_sync_run", {
      p_run_id: runId,
      p_status: "completed",
      p_bills_seen: billsSeen,
      p_votes_seen: votesSeen,
      p_details: { candidates: candidates.length, failures },
    });
    if (finishError) throw finishError;
    return jsonResponse({ ok: true, billsSeen, votesSeen, failures });
  } catch (error) {
    if (runId) {
      await adminClient().rpc("finish_sync_run", {
        p_run_id: runId,
        p_status: "failed",
        p_bills_seen: billsSeen,
        p_votes_seen: votesSeen,
        p_details: { failures },
        p_error_message: error instanceof Error ? error.message : String(error),
      });
    }
    return errorResponse(error);
  }
});

