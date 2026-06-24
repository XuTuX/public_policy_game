const BASE_URL = "https://open.assembly.go.kr/portal/openapi";
const USER_AGENT =
  "Mozilla/5.0 (compatible; public-policy-game/1.0; +https://open.assembly.go.kr)";

export const assemblyEndpoints = {
  billList: "ALLBILL", // 의안정보 통합 API
  billSummary: "BPMBILLSUMMARY", // 국회 국회사무처_법률안 제안이유 및 주요내용
  members: "nwvrqwxyaytdsfvhu",
  voteTallies: "ncocpgfiaoituanbr",
  memberVotes: "nojepdqqaweusdfbi",
} as const;

export type AssemblyRow = Record<string, unknown>;

type PageResult = {
  rows: AssemblyRow[];
  totalCount: number;
};

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

function parsePage(endpoint: string, payload: unknown): PageResult {
  const root = asRecord(payload);
  const blocks = root?.[endpoint];
  if (!Array.isArray(blocks)) {
    const result = asRecord(root?.RESULT);
    throw new Error(
      `Assembly API ${endpoint}: ${String(result?.MESSAGE ?? "invalid response")}`,
    );
  }

  let totalCount = 0;
  let rows: AssemblyRow[] = [];
  for (const block of blocks) {
    const record = asRecord(block);
    if (!record) continue;
    const head = record.head;
    if (Array.isArray(head)) {
      for (const item of head) {
        const headItem = asRecord(item);
        const count = Number(headItem?.list_total_count ?? 0);
        if (Number.isFinite(count)) totalCount = count;
        const result = asRecord(headItem?.RESULT);
        const code = String(result?.CODE ?? "INFO-000");
        if (code !== "INFO-000") {
          throw new Error(
            `Assembly API ${endpoint} ${code}: ${String(result?.MESSAGE ?? "error")}`,
          );
        }
      }
    }
    if (Array.isArray(record.row)) rows = record.row as AssemblyRow[];
  }
  return { rows, totalCount };
}

export async function fetchAssemblyRows(
  apiKey: string,
  endpoint: string,
  filters: Record<string, string | number | undefined> = {},
  pageSize = 1000,
): Promise<AssemblyRow[]> {
  const allRows: AssemblyRow[] = [];
  for (let page = 1; page <= 1000; page++) {
    const url = new URL(`${BASE_URL}/${endpoint}`);
    url.searchParams.set("KEY", apiKey);
    url.searchParams.set("Type", "json");
    url.searchParams.set("pIndex", String(page));
    url.searchParams.set("pSize", String(pageSize));
    for (const [key, value] of Object.entries(filters)) {
      if (value !== undefined && String(value).trim()) {
        url.searchParams.set(key, String(value));
      }
    }

    const response = await fetch(url, {
      headers: { accept: "application/json", "user-agent": USER_AGENT },
      signal: AbortSignal.timeout(20_000),
    });
    if (!response.ok) {
      throw new Error(`Assembly API ${endpoint} returned ${response.status}`);
    }
    const pageResult = parsePage(endpoint, await response.json());
    allRows.push(...pageResult.rows);
    if (
      pageResult.rows.length === 0 ||
      pageResult.rows.length < pageSize ||
      allRows.length >= pageResult.totalCount
    ) break;
  }
  return allRows;
}

export function text(row: AssemblyRow, ...keys: string[]): string {
  for (const key of keys) {
    const value = row[key];
    if (value !== null && value !== undefined && String(value).trim()) {
      return String(value).trim();
    }
  }
  return "";
}

export function integer(row: AssemblyRow, ...keys: string[]): number | null {
  const value = text(row, ...keys).replaceAll(",", "");
  if (!value) return null;
  const result = Number.parseInt(value, 10);
  return Number.isFinite(result) ? result : null;
}

export function isoDate(row: AssemblyRow, ...keys: string[]): string | null {
  const value = text(row, ...keys).replaceAll(/[^0-9]/g, "");
  if (value.length !== 8) return null;
  return `${value.slice(0, 4)}-${value.slice(4, 6)}-${value.slice(6, 8)}`;
}
