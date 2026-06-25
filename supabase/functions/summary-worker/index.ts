// @ts-ignore: Deno is available in Supabase edge functions
declare const Deno: any;
import {
  adminClient,
  assertCronAuthorization,
  errorResponse,
  jsonResponse,
  requiredEnv,
} from "../_shared/runtime.ts";

const PROMPT_VERSION = "bill-storytelling-ux-v1";
const REQUIRED_FIELDS = [
  "category",
  "background",
  "pros",
  "cons",
  "backgroundDialogue",
  "positiveDialogue",
  "concernDialogue",
  "positiveImpact",
  "concernImpact",
] as const;

type Summary = Record<typeof REQUIRED_FIELDS[number], string>;

function validateSummary(value: unknown): Summary {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("DeepSeek returned a non-object JSON value");
  }
  const record = value as Record<string, unknown>;
  const result: Record<string, string> = {};
  
  for (const field of REQUIRED_FIELDS) {
    if (record[field] === undefined || record[field] === null) {
      throw new Error(`DeepSeek response is missing ${field}`);
    }
    
    // If the field is an object/array, stringify it so we can store it in text columns
    let val = record[field];
    if (typeof val !== "string") {
      val = JSON.stringify(val);
    }
    
    const strVal = (val as string).trim();
    if (strVal.length > 5000) {
      throw new Error(`DeepSeek response field ${field} is too long`);
    }
    result[field] = strVal;
  }
  return result as Summary;
}

async function summarizeBill(
  apiKey: string,
  model: string,
  billName: string,
  sourceText: string,
): Promise<Summary> {
  const response = await fetch("https://api.deepseek.com/chat/completions", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      stream: false,
      response_format: { type: "json_object" },
      messages: [
        {
          role: "system",
          content: [
            "당신은 대한민국 국회 법안을 일반인에게 알기 쉽게 설명해주는 친절한 보좌관입니다.",
            "모든 대사와 설명은 실제 사람과 대화하듯 자연스럽고 친절한 구어체(~해요, ~습니다, ~군요 등)로 작성해주세요.",
            "사용자가 국회의원이 되어 보좌관의 브리핑을 듣는 스토리텔링 형태를 위해 다음 항목들을 구체적으로 생성해야 합니다.",
            "1. 도입 배경 (backgroundDialogue): 3~6개의 말풍선으로 이루어진 '보좌관'과 '의원' 간의 티키타카(상호 대화) 배열입니다. 무조건 보좌관의 대사와 의원의 대사가 핑퐁 형식으로 번갈아 나오며 실시간 채팅처럼 상호작용하도록 구성하세요. 각 대사 앞에 반드시 '보좌관: ' 또는 '의원: ' 접두사를 붙여 대화 주체를 명확히 해주세요. 보좌관이 대화 시작을 제안(Turn 1)하고, 의원이 리액션과 질문(Turn 2)을 던지며, 보좌관이 답변(Turn 3)하는 순서로 자연스럽게 대화가 이어져야 합니다. 의원의 대사 없이 보좌관만 혼자 길게 설명하는 형태는 절대 금지합니다.",
            "2. 찬성 논리 (pros): 최소 3~5개의 찬성 논리를 담은 배열. 각 항목은 제목(title), 짧은 설명(description), 구체적인 사례(example)를 포함해야 합니다.",
            "3. 반대 논리 (cons): 최소 3~5개의 우려사항/반대 논리를 담은 배열. 예산 부담, 형평성, 집행 가능성, 악용 가능성, 정책 부작용 관점에서 검토가 필요한 쟁점을 중립적인 톤으로 작성하세요. 원문에 우려가 없어도 반드시 생성하세요.",
            "반드시 JSON 객체만 응답하세요."
          ].join(" "),
        },
        {
          role: "user",
          content: JSON.stringify({
            billName,
            officialSource: sourceText.slice(0, 60_000),
            output: {
              category: "\uad50\uc721|\ud658\uacbd|\uacbd\uc81c|\ubcf5\uc9c0|\uae30\uc220|\uc548\ubcf4|\ubb38\ud654|\ub178\ub3d9|\uc8fc\uac70|\uad50\ud1b5|\uae30\ud0c0 \uc911 \ud558\ub098",
              background: "\ubc1c\uc758 \ubc30\uacbd 2~4\ubb38\uc7a5 (\uae30\uc874 \ud638\ud658\uc6a9)",
              pros: [
                {
                  title: "\ucc2c\uc131 \ub17c\ub9ac \uc81c\ubaa9 (3~5\uac1c \ud544\uc218)",
                  description: "\uc9e7\uc740 \uc124\uba85",
                  example: "\uad6c\uccb4\uc801\uc778 \uc0ac\ub840 \ub610\ub294 \ud6a8\uacfc"
                }
              ],
              cons: [
                {
                  title: "\uc6b0\ub824\uc0ac\ud56d/\ubc18\ub300 \ub17c\ub9ac \uc81c\ubaa9 (\uc608\uc0b0, \ud615\ud3c9\uc131, \ubd80\uc791\uc6a9 \ub4f1 \uc911\ub9bd\uc801 3~5\uac1c \ud544\uc218)",
                  description: "\uc9e7\uc740 \uc124\uba85",
                  example: "\uad6c\uccb4\uc801\uc778 \uc0ac\ub840 \ub610\ub294 \uac80\ud1a0 \uc7c1\uc810"
                }
              ],
              backgroundDialogue: [
                "보좌관: 의원님, 오늘은 [법안명] 개정안 브리핑을 드리려고 합니다. (3~6개 대화 필수)",
                "의원: 아, 그 법안이군요. 요즘 관련해서 어떤 사회적 이슈가 있었죠?",
                "보좌관: 네, 최근 [최근 사회적 배경/문제점]이 심각해지면서...",
                "의원: 그렇군요. 그래서 이를 개선하고자 이번 개정안이 발의된 거네요?",
                "보좌관: 맞습니다. 주요 골자는 [정부의 해결 목표/수단]입니다.",
                "의원: 이해했습니다. 그럼 이 법안의 찬성과 반대 논리들을 자세히 알려주세요."
              ],
              positiveDialogue: "\uae30\ub300 \ud6a8\uacfc\ub97c \ubcf4\uc5ec\uc8fc\ub294 \uc911\ub9bd\uc801 \ub300\uc0ac 1~2\ubb38\uc7a5",
              concernDialogue: "\uc6b0\ub824\ub97c \ubcf4\uc5ec\uc8fc\ub294 \uc911\ub9bd\uc801 \ub300\uc0ac 1~2\ubb38\uc7a5",
              positiveImpact: "\ud575\uc2ec \uae30\ub300 \ud6a8\uacfc 30\uc790 \uc774\ub0b4 (\ucd5c\uc885 \uc815\ub9ac\uc6a9)",
              concernImpact: "\ud575\uc2ec \uc6b0\ub824 30\uc790 \uc774\ub0b4 (\ucd5c\uc885 \uc815\ub9ac\uc6a9)",
            },
          }),
        },
      ],
    }),
    signal: AbortSignal.timeout(90_000),
  });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`DeepSeek returned ${response.status}: ${body.slice(0, 500)}`);
  }
  const payload = await response.json();
  const content = payload?.choices?.[0]?.message?.content;
  if (typeof content !== "string") throw new Error("DeepSeek response has no content");
  return validateSummary(JSON.parse(content));
}

Deno.serve(async (request: Request) => {
  try {
    if (request.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);
    assertCronAuthorization(request);
    const apiKey = requiredEnv("DEEPSEEK_API_KEY");
    const model = Deno.env.get("DEEPSEEK_MODEL")?.trim() || "deepseek-v4-flash";
    const body = await request.json().catch(() => ({}));
    const limit = Math.max(1, Math.min(Number(body?.limit ?? 3), 5));
    const supabase = adminClient();
    const { data: jobs, error: claimError } = await supabase.rpc("claim_summary_jobs", {
      p_limit: limit,
    });
    if (claimError) throw claimError;

    const results: Array<{ jobId: string; ok: boolean; error?: string }> = [];
    for (const job of jobs ?? []) {
      try {
        const summary = await summarizeBill(
          apiKey,
          model,
          job.bill_name,
          job.source_text,
        );
        const { error } = await supabase.rpc("complete_summary_job", {
          p_job_id: job.job_id,
          p_bill_id: job.bill_id,
          p_source_hash: job.source_hash,
          p_category: summary.category,
          p_background: summary.background,
          p_pros: summary.pros,
          p_cons: summary.cons,
          p_background_dialogue: summary.backgroundDialogue,
          p_positive_dialogue: summary.positiveDialogue,
          p_concern_dialogue: summary.concernDialogue,
          p_positive_impact: summary.positiveImpact,
          p_concern_impact: summary.concernImpact,
          p_model: model,
          p_prompt_version: PROMPT_VERSION,
        });
        if (error) throw error;
        results.push({ jobId: job.job_id, ok: true });
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        await supabase.rpc("fail_summary_job", {
          p_job_id: job.job_id,
          p_error: message,
        });
        results.push({ jobId: job.job_id, ok: false, error: message });
      }
    }

    const { data: gameSetId, error: publishError } = await supabase.rpc(
      "publish_latest_game_set",
    );
    if (publishError) throw publishError;
    return jsonResponse({ ok: true, processed: results.length, results, gameSetId });
  } catch (error) {
    return errorResponse(error);
  }
});

