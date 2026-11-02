// Eşik sunucusu (Cloudflare Workers). Şimdilik tek iş: Plus denemesinin
// başladığı anı cihaz başına saklamak; uygulama silinip yeniden kurulsa da
// deneme baştan başlamasın.
//
// POST /v1/trial  {"id": "<64 hex>", "localStart": <ms>}
//   → {"start": <ms>}  ilk görülen an (cihazın bildiği daha eskiyse o)
//
// "id", Android'de uygulamaya özel cihaz kimliğinin (ANDROID_ID) SHA-256
// özetidir; ham kimlik sunucuya gelmez. Başka hiçbir şey saklanmaz.

const HEADERS = { 'content-type': 'application/json' };

function json(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: HEADERS });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname !== '/v1/trial') return json({ error: 'not found' }, 404);
    if (request.method !== 'POST') return json({ error: 'method' }, 405);

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'body' }, 400);
    }
    const id = body && body.id;
    if (typeof id !== 'string' || !/^[0-9a-f]{64}$/.test(id)) {
      return json({ error: 'id' }, 400);
    }

    const key = `trial:${id}`;
    const now = Date.now();
    const saved = Number(await env.TRIAL.get(key));
    const local = Number(body.localStart);
    // Yalnızca daha eskiye çekilebilir: deneme hiçbir zaman uzatılamaz.
    const candidates = [now, saved, local].filter(
      (v) => Number.isFinite(v) && v > 1_600_000_000_000 && v <= now,
    );
    const start = Math.min(...candidates);
    if (start !== saved) await env.TRIAL.put(key, String(start));
    return json({ start });
  },
};
