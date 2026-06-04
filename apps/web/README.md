# Augustus Web

Frontend web do **Augustus - Controlador de finanças pessoais**.

Stack: **Angular 19** + [@govbr-ds/webcomponents-angular](https://www.npmjs.com/package/@govbr-ds/webcomponents-angular) (GovBR-DS), com autenticação integrada ao backend Augustus (`/api/auth/*`).

## Pré-requisitos

- Node.js 20+
- Backend Augustus em `http://localhost:8080/api` (ver `apps/backend`)

## Comandos

```powershell
cd apps/web
npm install
npm run e2e:install   # primeira vez: baixa o Chromium do Playwright
npm start             # ng serve → http://localhost:4200/ (proxy /api → :8080)
npm run build         # ng build → dist/
npm run e2e           # testes E2E (sobe o dev server e mocka /api/auth)
```

## Testes E2E (Playwright)

Os testes em `e2e/` mockam a API `/api/auth/*` (nao exigem backend real). Cobrem:

- Guards (area admin protegida, `naoAutenticadoGuard`)
- Login, logout e posicionamento do botao Sair
- Sanitizacao de `redirect` pos-login (open redirect)
- AuthLayout vs shell admin, footer e marca Augustus

## Desenvolvimento

- Dev server: `http://localhost:4200/`
- Proxy: `proxy.conf.json` encaminha `/api` para `http://localhost:8080`
- Link de verificação de email: configure `AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email` no `.env` do backend

## Estrutura

- `src/app/core/auth/` — AuthService (signals), guards, interceptor, token-storage
- `src/app/layouts/` — AppLayout (área admin) e AuthLayout (telas de login)
- `src/app/pages/` — home, form, colors, auth/*
- `src/assets/brand/` — logos Augustus

Diretriz visual: **light mode** obrigatório (sem dark mode).