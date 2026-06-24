// @ts-ignore: Deno is available in Supabase edge functions
declare const Deno: any;
import { AssemblyRow, text } from "./assembly_api.ts";



export async function sha256(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

export async function fetchOfficialSource(
  billId: string,
  detail: AssemblyRow,
): Promise<{ url: string; sourceText: string; sourceHash: string; method: string }> {
  const url = text(detail, "LINK_URL", "DETAIL_LINK", "BILL_URL") ||
    `https://likms.assembly.go.kr/bill/billDetail.do?billId=${encodeURIComponent(billId)}`;
  const title = text(detail, "BILL_NAME", "BILL_NM");
  
  let sourceText = "";
    let method = "official_api_summary";

  try {
    const apiKey = Deno.env.get("ASSEMBLY_API_KEY");
    if (!apiKey) throw new Error("ASSEMBLY_API_KEY is not set for source extraction");
    const billNo = text(detail, "BILL_NO");
    
    // Call the newly designated Open API for proposal reason & main content
    const { assemblyEndpoints, fetchAssemblyRows } = await import("./assembly_api.ts");
    
    console.log(`[sync-assembly] API fetch for ${billId}: Calling endpoint ${assemblyEndpoints.billSummary} for BILL_NO=${billNo}`);
    
    const reasons = await fetchAssemblyRows(
      apiKey,
      assemblyEndpoints.billSummary,
      { BILL_NO: billNo, BILL_ID: billId },
      10,
    );

    const reasonRow = reasons.find((row) => text(row, "BILL_ID") === billId) ?? reasons[0];
    if (!reasonRow) {
      console.warn(`[sync-assembly] API source fetch failed for ${billId}: No matching row returned`);
      throw new Error("Proposal reason API returned no matching row");
    }

    const summary = text(reasonRow, "SUMMARY") || "내용 없음";

    if (summary === "내용 없음") {
      console.warn(`[sync-assembly] API source fetch failed for ${billId}: Empty SUMMARY`);
      throw new Error("Summary content is empty in API response");
    }

    console.log(`[sync-assembly] API source fetch success for ${billId}`);
    sourceText = `법안명:\n${title}\n\n${summary}`;
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.warn(`[sync-assembly] Fallback triggered for ${billId} (Reason: ${errorMsg})`);
    sourceText = `법안명:\n${title}\n\n(안내: 국회 API 응답 데이터 부족으로 상세 본문을 수집하지 못했습니다. 위 법안 명칭을 바탕으로 주요 내용을 추론하여 요약해주세요.)`;
    method = "fallback_title_only";
  }

  return {
    url,
    sourceText,
    sourceHash: await sha256(sourceText),
    method,
  };
}

