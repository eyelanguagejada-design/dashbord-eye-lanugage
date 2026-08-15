# Daftra Financial Intelligence Dashboard

Production-oriented starter for a **Ledger-First / Journal-Driven** management dashboard connected to Daftra in **read-only mode**.

## Security first

Real Daftra credentials are intentionally **not included** in this project or ZIP. Put them only in `.env.local` on the server. Do not expose them to browser code, Git, screenshots, logs, or shared ZIPs.

Because credentials were pasted into a chat during development, rotating the API key/token/password before production use is recommended.

## Stack

- Next.js 16.2 LTS + React + TypeScript
- PostgreSQL
- Prisma ORM 7
- Server-side Daftra integration
- Arabic RTL executive UI

## Run locally

1. Install Node.js compatible with Next.js 16 / Prisma 7.
2. `docker compose up -d`
3. `cp .env.example .env.local` (Windows: copy the file manually). Prisma config also loads `.env.local`.
4. Fill `DAFTRA_SUBDOMAIN`, `DAFTRA_API_KEY`, `DAFTRA_ACCESS_TOKEN` in `.env.local`.
5. `npm install`
6. `npx prisma generate`
7. `npx prisma db push`
8. `npm run dev`
9. Open `http://localhost:3000`

## First use

- Open **حالة المزامنة**.
- Press **Test Connection**.
- Press **Start Initial Sync**.
- Open **الإعدادات** and map the chart of accounts to accounting roles.
- Return to **نظرة عامة**.

## Accounting rules implemented

- Journal entries and journal lines are the accounting source of truth.
- Draft/reversed journals are excluded from official metrics.
- Invoices, payments and expenses are operational / reconciliation sources.
- Journal balance exceptions are surfaced.
- No fake/demo financial numbers are shown as real.
- Every financial mapping uses account IDs and configurable roles rather than hard-coded account names.

## Daftra API paths implemented

- `/journals`
- `/journal_accounts`
- `/journal_cats`
- `/invoices`
- `/invoice_payments`
- `/expenses`
- `/treasuries`
- `/clients` (best-effort)
- `/branches` (best-effort)

The client includes pagination, timeout, retry and rate-limit handling.

## Important implementation note

This source is a solid executable foundation, but a final accounting deployment still requires validating the exact account mapping and Daftra response fields against the live tenant. That validation is intentionally not guessed.
