import {
  adminClient,
  assertCronAuthorization,
  errorResponse,
  jsonResponse,
} from "../_shared/runtime.ts";

Deno.serve(async (request) => {
  try {
    if (request.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);
    assertCronAuthorization(request);
    const { data, error } = await adminClient().rpc("publish_latest_game_set");
    if (error) throw error;
    return jsonResponse({ ok: data !== null, gameSetId: data });
  } catch (error) {
    return errorResponse(error);
  }
});
