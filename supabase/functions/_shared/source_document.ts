import { AssemblyRow, text } from "./assembly_api.ts";

const USER_AGENT = "Mozilla/5.0 public-policy-game/1.0";

function decodeHtml(value: string): string {
  const entities: Record<string, string> = {
    amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ",
  };
  return value
    .replace(/<br\s*\/?\s*>/gi, "\n")
    .replace(/<\/p>/gi, "\n")
    .replace(/<[^>]+>/g, " ")
    .replace(/&(#x?[0-9a-f]+|[a-z]+);/gi, (_, entity: string) => {
      if (entity.startsWith("#x")) {
        return String.fromCodePoint(Number.parseInt(entity.slice(2), 16));
      }
      if (entity.startsWith("#")) {
        return String.fromCodePoint(Number.parseInt(entity.slice(1), 10));
      }
      return entities[entity.toLowerCase()] ?? `&${entity};`;
    })
    .replace(/\r/g, "")
    .replace(/[ \t]+/g, " ")
    .replace(/\n\s*\n\s*\n+/g, "\n\n")
    .trim();
}

function extractSourceText(html: string): string {
  const selectors = [
    /<pre[^>]+id=["']prntSummary["'][^>]*>([\s\S]*?)<\/pre>/i,
    /<[^>]+id=["']prntSummary["'][^>]*>([\s\S]*?)<\/[^>]+>/i,
    /<[^>]+class=["'][^"']*bill-summary[^"']*["'][^>]*>([\s\S]*?)<\/[^>]+>/i,
  ];
  for (const selector of selectors) {
    const match = html.match(selector);
    if (match?.[1]) {
      const result = decodeHtml(match[1]);
      if (result.length >= 100) return result;
    }
  }

  const plain = decodeHtml(html);
  const marker = plain.search(/\uc81c\uc548\uc774\uc720(?:\s*\ubc0f\s*\uc8fc\uc694\ub0b4\uc6a9)?/);
  if (marker >= 0) {
    const result = plain.slice(marker, marker + 20_000).trim();
    if (result.length >= 100) return result;
  }
  throw new Error("Official bill page did not contain proposal text");
}

function attribute(tag: string, name: string): string {
  const match = tag.match(new RegExp(`${name}\\s*=\\s*["']([^"']*)["']`, "i"));
  return match?.[1] ? decodeHtml(match[1]) : "";
}

function postFormFrom(html: string, baseUrl: string, billId: string) {
  const forms = [...html.matchAll(/<form\b([^>]*)>([\s\S]*?)<\/form>/gi)];
  const selected = forms.find((match) =>
    /method\s*=\s*["']?post/i.test(match[1]) &&
    /billId|_csrf|csrf/i.test(match[2])
  ) ?? forms.find((match) => /method\s*=\s*["']?post/i.test(match[1]));
  if (!selected) throw new Error("Official bill page has no POST form");

  const params = new URLSearchParams();
  for (const input of selected[2].matchAll(/<input\b[^>]*>/gi)) {
    const name = attribute(input[0], "name");
    if (name) params.set(name, attribute(input[0], "value"));
  }
  params.set("billId", billId);
  const action = attribute(selected[1], "action");
  return {
    url: new URL(action || baseUrl, baseUrl).toString(),
    body: params,
  };
}

function cookieHeader(headers: Headers): string {
  const extended = headers as Headers & { getSetCookie?: () => string[] };
  const values = extended.getSetCookie?.() ??
    (headers.get("set-cookie") ? [headers.get("set-cookie")!] : []);
  return values
    .map((value) => value.split(";", 1)[0])
    .filter(Boolean)
    .join("; ");
}

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
  const response = await fetch(url, {
    headers: { "user-agent": USER_AGENT, accept: "text/html" },
    redirect: "follow",
    signal: AbortSignal.timeout(20_000),
  });
  if (!response.ok) throw new Error(`Official bill page returned ${response.status}`);
  const firstHtml = await response.text();
  let sourceText: string;
  let method = "official_html_direct";
  try {
    sourceText = extractSourceText(firstHtml);
  } catch (_) {
    const form = postFormFrom(firstHtml, response.url || url, billId);
    const postResponse = await fetch(form.url, {
      method: "POST",
      headers: {
        "user-agent": USER_AGENT,
        accept: "text/html",
        "content-type": "application/x-www-form-urlencoded",
        referer: response.url || url,
        cookie: cookieHeader(response.headers),
      },
      body: form.body,
      redirect: "follow",
      signal: AbortSignal.timeout(20_000),
    });
    if (!postResponse.ok) {
      throw new Error(`Official bill detail POST returned ${postResponse.status}`);
    }
    sourceText = extractSourceText(await postResponse.text());
    method = "official_html_csrf_post";
  }
  return {
    url: response.url || url,
    sourceText,
    sourceHash: await sha256(sourceText),
    method,
  };
}
