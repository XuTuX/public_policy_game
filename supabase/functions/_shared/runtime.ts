import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";

export function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
}

export function adminClient(): SupabaseClient {
  return createClient(
    requiredEnv("SUPABASE_URL"),
    requiredEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}

export function assertCronAuthorization(request: Request): void {
  const expected = requiredEnv("CRON_SECRET");
  const authorization = request.headers.get("authorization") ?? "";
  if (authorization !== `Bearer ${expected}`) {
    throw new HttpError(401, "Unauthorized");
  }
}

export class HttpError extends Error {
  constructor(public readonly status: number, message: string) {
    super(message);
  }
}

export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

export function errorResponse(error: unknown): Response {
  const status = error instanceof HttpError ? error.status : 500;
  const message = error instanceof Error ? error.message : "Unknown error";
  console.error(message);
  return jsonResponse({ error: message }, status);
}

