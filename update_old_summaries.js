const fs = require('fs');

async function main() {
  // Load .env
  const envText = fs.readFileSync('.env', 'utf-8');
  const env = {};
  envText.split('\n').forEach(line => {
    if (line && !line.startsWith('#')) {
      const parts = line.split('=');
      if (parts.length >= 2) {
        env[parts[0].trim()] = parts.slice(1).join('=').trim();
      }
    }
  });

  const SUPABASE_URL = env['SUPABASE_URL'];
  const SUPABASE_KEY = env['SUPABASE_SERVICE_ROLE_KEY'];
  const ASSEMBLY_API_KEY = env['ASSEMBLY_API_KEY'];
  const DEEPSEEK_API_KEY = env['DEEPSEEK_API_KEY'];
  const DEEPSEEK_MODEL = env['DEEPSEEK_MODEL'];

  async function supabaseRpc(rpcName, payload) {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${rpcName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      },
      body: JSON.stringify(payload)
    });
    if (!res.ok) {
      console.error(`RPC ${rpcName} failed:`, await res.text());
      return null;
    }
    // RPC might return empty response
    try { return await res.json(); } catch(e) { return true; }
  }

  async function supabaseQuery(table, select) {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/${table}?select=${select}`, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      }
    });
    if (!res.ok) throw new Error(`Query ${table} failed: ` + await res.text());
    return res.json();
  }

  const crypto = require('crypto');
  function sha256(value) {
    return crypto.createHash('sha256').update(value).digest('hex');
  }

  console.log("Fetching bills from Supabase...");
  const bills = await supabaseQuery('assembly_bills', 'id,assembly_bill_id,bill_no,bill_name');
  console.log(`Found ${bills.length} bills.`);

  for (const bill of bills) {
    console.log(`Processing: ${bill.bill_name}`);

    // Fetch from National Assembly API
    const url = `https://open.assembly.go.kr/portal/openapi/nzatspkbebcotwclk?KEY=${ASSEMBLY_API_KEY}&Type=json&pSize=10&pIndex=1&BILL_NO=${bill.bill_no}`;
    let sourceText = "";
    try {
      const res = await fetch(url);
      const data = await res.json();
      const rows = data.nzatspkbebcotwclk?.[1]?.row || [];
      const reasonRow = rows.find(r => r.BILL_ID === bill.assembly_bill_id) || rows[0];
      if (reasonRow && reasonRow.SUMMARY) {
        sourceText = `법안명:\n${bill.bill_name}\n\n${reasonRow.SUMMARY}`;
      } else {
        sourceText = `법안명:\n${bill.bill_name}\n\n(안내: 국회 API 응답 데이터 부족. 명칭으로 주요 내용 추론 요망)`;
      }
    } catch (e) {
      sourceText = `법안명:\n${bill.bill_name}\n\n(안내: 국회 API 에러. 명칭으로 추론 요망)`;
    }

    const sourceHash = sha256(sourceText);

    console.log(`Summarizing with DeepSeek (${DEEPSEEK_MODEL})...`);
    const dsRes = await fetch("https://api.deepseek.com/chat/completions", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${DEEPSEEK_API_KEY}`
      },
      body: JSON.stringify({
        model: DEEPSEEK_MODEL,
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
            content: `법안명: ${bill.bill_name}\n\n${sourceText}\n\n다음 JSON 구조에 맞게 생성해주세요:\n{\n  "category": "분류(예: 복지, 경제 등)",\n  "background": "전체 배경 짧은 요약",\n  "pros": [{"title": "...", "description": "...", "example": "..."}],\n  "cons": [{"title": "...", "description": "...", "example": "..."}],\n  "backgroundDialogue": [\n    "보좌관: 의원님, 오늘은 [법안명] 개정안 브리핑을 드리려고 합니다. (3~6개 대화 필수)",\n    "의원: 아, 그 법안이군요. 요즘 관련해서 어떤 사회적 이슈가 있었죠?",\n    "보좌관: 네, 최근 [최근 사회적 배경/문제점]이 심각해지면서...",\n    "의원: 그렇군요. 그래서 이를 개선하고자 이번 개정안이 발의된 거네요?",\n    "보좌관: 맞습니다. 주요 골자는 [정부의 해결 목표/수단]입니다.",\n    "의원: 이해했습니다. 그럼 이 법안의 찬성과 반대 논리들을 자세히 알려주세요."\n  ],\n  "positiveDialogue": "찬성 측 짧은 대사",\n  "concernDialogue": "우려 측 짧은 대사",\n  "positiveImpact": "핵심 기대 효과",\n  "concernImpact": "핵심 부작용 우려"\n}`,
          }
        ]
      })
    });

    const completion = await dsRes.json();
    const content = completion.choices?.[0]?.message?.content;
    if (!content) {
      console.error("DeepSeek empty response:", completion);
      continue;
    }

    let parsed;
    try {
      parsed = JSON.parse(content);
    } catch(e) {
      console.error("JSON parse failed");
      continue;
    }

    const payload = {
      bill_id: bill.id,
      status: 'ready',
      category: parsed.category || "기타",
      background: parsed.background || "",
      pros: JSON.stringify(parsed.pros || []),
      cons: JSON.stringify(parsed.cons || []),
      background_dialogue: JSON.stringify(parsed.backgroundDialogue || []),
      positive_dialogue: parsed.positiveDialogue || "",
      concern_dialogue: parsed.concernDialogue || "",
      positive_impact: parsed.positiveImpact || "",
      concern_impact: parsed.concernImpact || "",
      model: DEEPSEEK_MODEL,
      prompt_version: "bill-storytelling-ux-v1",
      source_hash: sourceHash,
      updated_at: new Date().toISOString()
    };

    const upsertRes = await fetch(`${SUPABASE_URL}/rest/v1/bill_summaries?on_conflict=bill_id`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates',
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      },
      body: JSON.stringify(payload)
    });

    if (!upsertRes.ok) {
      console.error("Upsert failed:", await upsertRes.text());
    } else {
      console.log("Successfully upserted into DB!");
    }
  }
}

main().catch(console.error);
