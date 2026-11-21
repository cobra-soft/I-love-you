import { Env } from './types';

interface AnswerPayload {
  answers?: Record<string, unknown>;
  hue?: number;
  lang?: string;
  ts?: number;
}

const RATE = new Map<string, { count: number; reset: number }>();

function rateLimit(ip: string, key: string, limit: number, windowMs: number): boolean {
  const now = Date.now();
  const k = ip + ':' + key;
  const rec = RATE.get(k);
  if (!rec || rec.reset < now) {
    RATE.set(k, { count: 1, reset: now + windowMs });
    return true;
  }
  if (rec.count >= limit) return false;
  rec.count++;
  return true;
}

function esc(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function resolveOrigin(env: Env, reqOrigin: string, urlOrigin: string): string {
  const allowed = (env.ALLOWED_ORIGINS ?? '').split(',').map(x => x.trim()).filter(Boolean);
  if (!reqOrigin) return urlOrigin;
  if (allowed.length === 0 || allowed.includes(reqOrigin)) return reqOrigin;
  return urlOrigin;
}

function corsHeaders(origin: string): Record<string, string> {
  return {
    'access-control-allow-origin': origin,
    'access-control-allow-methods': 'GET, POST, OPTIONS',
    'access-control-allow-headers': 'Content-Type',
  };
}

function json(data: unknown, status: number, origin: string, extra: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json', ...corsHeaders(origin), ...extra },
  });
}

const MAXLEN: Record<string, number> = {
  color: 32, food: 200, movie: 200, music: 200, season: 32, time: 32,
  date: 2000, joy: 500, msg: 2000,
};

function validateAnswers(a: Record<string, unknown>): string | null {
  if (!a || typeof a !== 'object') return 'invalid answers';
  for (const [k, v] of Object.entries(a)) {
    if (!(k in MAXLEN)) return 'unknown field ' + k;
    if (typeof v !== 'string') return 'invalid type ' + k;
    if (v.length > MAXLEN[k]) return 'too long ' + k;
  }
  if (typeof a.color !== 'string' || !a.color) return 'color required';
  return null;
}

function formatTelegram(p: AnswerPayload): string {
  const a = (p.answers || {}) as Record<string, string>;
  const lines: string[] = [];
  lines.push('♡ <b>Новый ответ из опросника</b>');
  lines.push('');
  const label = (ru: string, en: string, uk: string) => {
    if (p.lang === 'en') return en;
    if (p.lang === 'uk') return uk;
    return ru;
  };
  if (a.color) lines.push('🎨 ' + label('Цвет', 'Color', 'Колір') + ': <code>' + esc(a.color) + '</code>');
  if (a.food) lines.push('🍽 ' + label('Блюдо', 'Food', 'Страва') + ': ' + esc(a.food));
  if (a.movie) lines.push('🎬 ' + label('Фильм', 'Movie', 'Фільм') + ': ' + esc(a.movie));
  if (a.music) lines.push('🎵 ' + label('Музыка', 'Music', 'Музика') + ': ' + esc(a.music));
  if (a.season) lines.push('🍂 ' + label('Время года', 'Season', 'Пора року') + ': ' + esc(a.season));
  if (a.time) lines.push('⏰ ' + label('Время суток', 'Time of day', 'Час доби') + ': ' + esc(a.time));
  if (a.date) lines.push('💌 ' + label('Идеальное свидание', 'Perfect date', 'Ідеальне побачення') + ':\n' + esc(a.date));
  if (a.joy) lines.push('✨ ' + label('Радует', 'Joy', 'Радує') + ': ' + esc(a.joy));
  if (a.msg) lines.push('💬 ' + label('Сообщение', 'Message', 'Повідомлення') + ':\n' + esc(a.msg));
  lines.push('');
  lines.push('🌐 lang: ' + esc(String(p.lang || 'ru')) + ' · hue: ' + esc(String(p.hue ?? '')));
  return lines.join('\n');
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const pathname = url.pathname;
    const clientIP = request.headers.get('cf-connecting-ip') ?? 'unknown';
    const reqOrigin = request.headers.get('origin') ?? '';
    const origin = resolveOrigin(env, reqOrigin, url.origin);

    if (pathname === '/api/health') {
      return json({ ok: true }, 200, origin);
    }

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders(origin) });
    }

    if (pathname === '/api/submit' && request.method === 'POST') {
      const sameOrigin = reqOrigin === url.origin || reqOrigin === '';
      const allowed = (env.ALLOWED_ORIGINS ?? '').split(',').map(x => x.trim()).filter(Boolean);
      if (reqOrigin && !sameOrigin && allowed.length > 0 && !allowed.includes(reqOrigin)) {
        return json({ error: 'Invalid origin' }, 403, origin);
      }

      if (!rateLimit(clientIP, 'submit', 5, 60 * 1000)) {
        return json({ error: 'Too many requests' }, 429, origin, { 'Retry-After': '60' });
      }

      let body: AnswerPayload;
      try {
        body = await request.json() as AnswerPayload;
      } catch {
        return json({ error: 'Invalid JSON' }, 400, origin);
      }

      const answers = (body.answers && typeof body.answers === 'object') ? body.answers as Record<string, unknown> : {};
      // honeypot
      if (typeof answers.website === 'string' && answers.website.trim() !== '') {
        return json({ ok: true }, 200, origin);
      }
      delete answers.website;

      const err = validateAnswers(answers);
      if (err) return json({ error: err }, 400, origin);

      if (!env.BOT_TOKEN || !env.OWNER_CHAT_ID) {
        return json({ error: 'Bot not configured' }, 500, origin);
      }

      const text = formatTelegram({ ...body, answers });
      try {
        const tgRes = await fetch(`https://api.telegram.org/bot${env.BOT_TOKEN}/sendMessage`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            chat_id: env.OWNER_CHAT_ID,
            text,
            parse_mode: 'HTML',
            disable_web_page_preview: true,
          }),
        });
        if (!tgRes.ok) {
          const t = await tgRes.text();
          console.error('telegram error', tgRes.status, t);
          return json({ error: 'Telegram send failed' }, 502, origin);
        }
      } catch (e) {
        console.error('telegram exception', e);
        return json({ error: 'Telegram send failed' }, 502, origin);
      }

      return json({ ok: true }, 200, origin);
    }

    // static assets
    return env.ASSETS.fetch(request);
  },
};
