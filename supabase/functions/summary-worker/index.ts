import {
  adminClient,
  assertCronAuthorization,
  errorResponse,
  jsonResponse,
  requiredEnv,
} from "../_shared/runtime.ts";

const PROMPT_VERSION = "bill-neutral-summary-v1";
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
  for (const field of REQUIRED_FIELDS) {
    if (typeof record[field] !== "string" || !record[field].trim()) {
      throw new Error(`DeepSeek response is missing ${field}`);
    }
    if (record[field].trim().length > 1500) {
      throw new Error(`DeepSeek response field ${field} is too long`);
    }
  }
  return Object.fromEntries(
    REQUIRED_FIELDS.map((field) => [field, (record[field] as string).trim()]),
  ) as Summary;
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
            "\ub2f9\uc2e0\uc740 \ub300\ud55c\ubbfc\uad6d \uad6d\ud68c \ubc95\uc548\uc744 \uc815\ud30c\uc801 \ud3b8\ud5a5 \uc5c6\uc774 \uc124\uba85\ud558\ub294 \uc815\ucc45 \ubd84\uc11d\uac00\ub2e4.",
            "\ubc18\ub4dc\uc2dc \uc81c\uacf5\ub41c \uacf5\uc2dd \uc6d0\ubb38\uc5d0 \uc788\ub294 \uc0ac\uc2e4\ub9cc \uc0ac\uc6a9\ud558\uace0 \uc218\uce58\ub098 \uc601\ud5a5\uc744 \ucd94\uc815\ud558\uc9c0 \ub9c8\ub77c.",
            "\uc7a5\uc810\uacfc \ub2e8\uc810\uc740 \uac00\ub2a5\ud55c \uae30\ub300 \ud6a8\uacfc\uc640 \uc6b0\ub824\ub85c \uad6c\ubd84\ud558\uace0 \ub2e8\uc815\uc801 \ud45c\ud604\uc744 \ud53c\ud558\ub77c.",
            "JSON \uac1d\uccb4\ub9cc \uc751\ub2f5\ud558\ub77c.",
          ].join(" "),
        },
        {
          role: "user",
          content: JSON.stringify({
            billName,
            officialSource: sourceText.slice(0, 60_000),
            output: {
              category: "\uad50\uc721|\ud658\uacbd|\uacbd\uc81c|\ubcf5\uc9c0|\uae30\uc220|\uc548\ubcf4|\ubb38\ud654|\ub178\ub3d9|\uc8fc\uac70|\uad50\ud1b5|\uae30\ud0c0 \uc911 \ud558\ub098",
              background: "\ubc1c\uc758 \ubc30\uacbd 2~4\ubb38\uc7a5",
              pros: "\uae30\ub300 \ud6a8\uacfc 2~4\ubb38\uc7a5",
              cons: "\uc6b0\ub824\uc640 \ud55c\uacc4 2~4\ubb38\uc7a5",
              backgroundDialogue: "\uac8c\uc784 \uc7a5\uba74\uc6a9 \ubc30\uacbd \uc124\uba85 1~2\ubb38\uc7a5",
              positiveDialogue: "\uae30\ub300 \ud6a8\uacfc\ub97c \ubcf4\uc5ec\uc8fc\ub294 \uc911\ub9bd\uc801 \ub300\uc0ac 1~2\ubb38\uc7a5",
              concernDialogue: "\uc6b0\ub824\ub97c \ubcf4\uc5ec\uc8fc\ub294 \uc911\ub9bd\uc801 \ub300\uc0ac 1~2\ubb38\uc7a5",
              positiveImpact: "\ud575\uc2ec \uae30\ub300 \ud6a8\uacfc 30\uc790 \uc774\ub0b4",
              concernImpact: "\ud575\uc2ec \uc6b0\ub824 30\uc790 \uc774\ub0b4",
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

Deno.serve(async (request) => {
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

