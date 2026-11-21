# Love Survey

Сайт-опросник для неё. Ответы отправляются в Telegram-бот.

## Стек
- Frontend: `frontend/index.html` (HTML+CSS+JS), локальные шрифты Balsamiq Sans.
- Backend: Cloudflare Worker (TypeScript), Static Assets.
- Доставка: Telegram Bot API.

## Деплой
Через GitHub Actions. Секреты: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`. Воркер-секреты: `BOT_TOKEN`, `OWNER_CHAT_ID`.

## Локально
`cd worker && npm install && npx wrangler dev` (нужен ПК/сервер, не Android).

## Тесты
`bash tests/run_all.sh`
`cd worker && npm run typecheck`
