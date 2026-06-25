import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.4";
import { load } from "https://deno.land/std@0.224.0/dotenv/mod.ts";
import { fetchAssemblyRows, assemblyEndpoints, text } from "./supabase/functions/_shared/assembly_api.ts";
import { sha256 } from "./supabase/functions/_shared/source_document.ts";

async function main() {
  const env = await load();
  const supabaseUrl = env["SUPABASE_URL"];
  const supabaseKey = env["SUPABASE_SERVICE_ROLE_KEY"];
  const assemblyApiKey = env["ASSEMBLY_API_KEY"];
  const deepseekApiKey = env["DEEPSEEK_API_KEY"];
  const deepseekModel = env["DEEPSEEK_MODEL"];

  if (!supabaseUrl || !supabaseKey || !assemblyApiKey || !deepseekApiKey) {
    console.error("Missing required credentials in .env");
    Deno.exit(1);
  }

  const supabase = createClient(supabaseUrl, supabaseKey);

  // 1. Get all bills
  const { data: bills, error: billsError } = await supabase
    .from("assembly_bills")
    .select("id, assembly_bill_id, bill_no, bill_name, raw_payload");

  if (billsError || !bills) {
    console.error("Error fetching bills:", billsError);
    return;
  }

  console.log(`Found ${bills.length} bills to process.`);

  for (const bill of bills) {
    console.log(`Processing bill: ${bill.bill_name} (${bill.bill_no})`);

    // 2. Fetch source text
    let sourceText = "";
    try {
      const reasons = await fetchAssemblyRows(
        assemblyApiKey,
        assemblyEndpoints.billSummary,
        { BILL_NO: bill.bill_no, BILL_ID: bill.assembly_bill_id },
        10
      );
      const reasonRow = reasons.find((row: any) => text(row, "BILL_ID") === bill.assembly_bill_id) ?? reasons[0];
      if (reasonRow) {
        const summary = text(reasonRow, "SUMMARY") || "내용 없음";
        sourceText = `법안명:\n${bill.bill_name}\n\n${summary}`;
      } else {
        sourceText = `법안명:\n${bill.bill_name}\n\n(안내: 국회 API 응답 데이터 부족으로 상세 본문을 수집하지 못했습니다. 위 법안 명칭을 바탕으로 주요 내용을 추론하여 요약해주세요.)`;
      }
    } catch (e) {
      sourceText = `법안명:\n${bill.bill_name}\n\n(안내: 국회 API 에러. 명칭을 바탕으로 추론하세요.)`;
    }

    const sourceHash = await sha256(sourceText);

    // 3. Summarize using DeepSeek with new prompt
    console.log(`Summarizing ${bill.bill_name}...`);
    const response = await fetch("https://api.deepseek.com/chat/completions", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${deepseekApiKey}`,
      },
      body: JSON.stringify({
        model: deepseekModel,
        stream: false,
        response_format: { type: "json_object" },
        messages: [
          {
            role: "system",
            content: [
              "당신은 대한민국 국회 법안을 일반인에게 알기 쉽게 설명해주는 친절한 보좌관입니다.",
              "모든 대사와 설명은 실제 사람과 대화하듯 자연스럽고 친절한 구어체(~해요, ~습니다, ~군요 등)로 작성해주세요.",
              "사용자가 국회의원이 되어 보좌관의 브리핑을 듣는 스토리텔링 형태를 위해 다음 항목들을 구체적으로 생성해야 합니다.",
              "1. 도입 배경 (backgroundDialogue): 3~6개의 말풍선으로 순차적으로 설명할 수 있는 배열. 최근 사회 문제, 발의 이유, 정부의 해결 목표 등을 채팅하듯 구성하세요.",
              "2. 찬성 논리 (pros): 최소 3~5개의 찬성 논리를 담은 배열. 각 항목은 제목(title), 짧은 설명(description), 구체적인 사례(example)를 포함해야 합니다.",
              "3. 반대 논리 (cons): 최소 3~5개의 우려사항/반대 논리를 담은 배열. 예산 부담, 형평성, 집행 가능성, 악용 가능성, 정책 부작용 관점에서 검토가 필요한 쟁점을 중립적인 톤으로 작성하세요. 원문에 우려가 없어도 반드시 생성하세요.",
              "반드시 JSON 객체만 응답하세요."
            ].join(" "),
          },
          {
            role: "user",
            content: `법안명: ${bill.bill_name}\n\n${sourceText}\n\n다음 JSON 구조에 맞게 생성해주세요:\n{\n  "category": "분류(예: 복지, 경제 등)",\n  "background": "전체 배경 짧은 요약",\n  "pros": [{"title": "...", "description": "...", "example": "..."}],\n  "cons": [{"title": "...", "description": "...", "example": "..."}],\n  "backgroundDialogue": ["말풍선1", "말풍선2", ...],\n  "positiveDialogue": "찬성 측 짧은 대사",\n  "concernDialogue": "우려 측 짧은 대사",\n  "positiveImpact": "핵심 기대 효과",\n  "concernImpact": "핵심 부작용 우려"\n}`,
          },
        ],
      }),
    });

    const completion = await response.json();
    if (!completion.choices?.[0]?.message?.content) {
      console.error("DeepSeek API error:", completion);
      continue;
    }

    const summaryContent = completion.choices[0].message.content;
    let parsed: any;
    try {
      parsed = JSON.parse(summaryContent);
    } catch (e) {
      console.error("Failed to parse JSON for bill:", bill.bill_name);
      continue;
    }

    // 4. Call complete_summary_job RPC
    const dummyJobId = crypto.randomUUID();
    const { error: rpcError } = await supabase.rpc("complete_summary_job", {
      p_job_id: dummyJobId,
      p_bill_id: bill.id,
      p_source_hash: sourceHash,
      p_category: parsed.category ?? "기타",
      p_background: parsed.background ?? "",
      p_pros: JSON.stringify(parsed.pros ?? []),
      p_cons: JSON.stringify(parsed.cons ?? []),
      p_background_dialogue: JSON.stringify(parsed.backgroundDialogue ?? []),
      p_positive_dialogue: parsed.positiveDialogue ?? "",
      p_concern_dialogue: parsed.concernDialogue ?? "",
      p_positive_impact: parsed.positiveImpact ?? "",
      p_concern_impact: parsed.concernImpact ?? "",
      p_model: deepseekModel,
      p_prompt_version: "bill-storytelling-ux-v1",
    });

    if (rpcError) {
      console.error("RPC Error:", rpcError);
    } else {
      console.log("Successfully updated bill:", bill.bill_name);
    }
  }

  console.log("All done!");
}

main();
