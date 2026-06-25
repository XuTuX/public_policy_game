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
            content: "당신은 대한민국 국회 법안을 일반인에게 알기 쉽게 설명해주는 친절한 보좌관입니다. 모든 대사와 설명은 실제 사람과 대화하듯 자연스럽고 친절한 구어체(~해요, ~습니다, ~군요 등)로 작성해주세요. 사용자가 국회의원이 되어 보좌관의 브리핑을 듣는 스토리텔링 형태를 위해 다음 항목들을 구체적으로 생성해야 합니다. 1. 도입 배경 (backgroundDialogue): 3~6개의 말풍선으로 순차적으로 설명할 수 있는 배열. 최근 사회 문제, 발의 이유, 정부의 해결 목표 등을 채팅하듯 구성하세요. 2. 찬성 논리 (pros): 최소 3~5개의 찬성 논리를 담은 배열. 각 항목은 제목(title), 짧은 설명(description), 구체적인 사례(example)를 포함해야 합니다. 3. 반대 논리 (cons): 최소 3~5개의 우려사항/반대 논리를 담은 배열. 예산 부담, 형평성, 집행 가능성, 악용 가능성, 정책 부작용 관점에서 검토가 필요한 쟁점을 중립적인 톤으로 작성하세요. 원문에 우려가 없어도 반드시 생성하세요. 반드시 JSON 객체만 응답하세요."
          },
          {
            role: "user",
            content: `법안명: ${bill.bill_name}\n\n${sourceText}\n\n다음 JSON 구조에 맞게 생성해주세요:\n{\n  "category": "분류(예: 복지, 경제 등)",\n  "background": "전체 배경 짧은 요약",\n  "pros": [{"title": "...", "description": "...", "example": "..."}],\n  "cons": [{"title": "...", "description": "...", "example": "..."}],\n  "backgroundDialogue": ["말풍선1", "말풍선2", ...],\n  "positiveDialogue": "찬성 측 짧은 대사",\n  "concernDialogue": "우려 측 짧은 대사",\n  "positiveImpact": "핵심 기대 효과",\n  "concernImpact": "핵심 부작용 우려"\n}`
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
