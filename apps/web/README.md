# apps/web — Augustus (frontend React)

Frontend web do **Augustus - Controlador de finanças pessoais**.

Migrado de Angular para React em 2026-05-24, preservando porta `4200`, chaves `localStorage` (`augustus.auth.*`) e contrato HTTP `/api/auth/*` com o backend.

## Stack

- React 19.1 + React Router 6.22
- TypeScript 5.8 (strict)
- Vite 6.3 (`@vitejs/plugin-react`)
- `@govbr-ds/core` 3.6.x + `@govbr-ds/webcomponents-react` 2.0.0-next.41 (versão pinada exata enquanto pre-release)

## Pré-requisitos

- Node.js 20+ e npm.
- Backend Augustus rodando em `http://localhost:8080/api` (perfil `local`, com MySQL local via Docker em `localhost:3307`).
- No `apps/backend/.env`, definir `AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email` para que o link de verificação enviado por email caia na rota do frontend.

## Comandos

```sh
npm install
npm run dev       # vite, http://localhost:4200/ (strictPort + proxy /api -> :8080)
npm run build     # tsc -b && vite build (output em dist/)
npm run preview   # serve a build de produção localmente
```

## Estrutura

```
apps/web/
  index.html
  vite.config.ts          # server.port=4200 strictPort + proxy /api -> :8080
  package.json
  tsconfig.{json,app.json,node.json}
  src/
    main.tsx              # <StrictMode><AuthProvider><App /></AuthProvider></StrictMode>
    App.tsx               # BrowserRouter + Header/Menu/Breadcrumb/Footer + Routes
    index.css             # @import @govbr-ds/core + .auth-shell
    assets/               # imagens públicas servidas em /
      brand/              # logo e símbolo do Augustus
    components/
      Header/, Menu/, Footer/, Breadcrumb/
      RedirectIfAuthenticated.tsx
    context/AuthContext.tsx
    hooks/useAuth.ts
    services/
      tokenStorage.ts
      apiClient.ts        # apiFetch + refresh single-flight + lerBody resiliente
      authService.ts
    types/auth.ts
    pages/
      Home.tsx, Formulario.tsx, Colors.tsx        # demos do quickstart (referência)
      auth/{Login,Register,VerifyPending,VerifyEmail}Page.tsx
    data/cores.ts
```

## Convenções

- Function components + hooks; sem class components.
- Forms: state local com `useState` + validação manual por campo.
- Toda chamada HTTP usa `apiFetch` (`src/services/apiClient.ts`); nunca `fetch` direto.
- Toda leitura/escrita de tokens passa por `tokenStorage` (`src/services/tokenStorage.ts`); nunca `localStorage` direto.
- Toda autenticação passa pelo hook `useAuth()` (`src/hooks/useAuth.ts`).
- Light mode obrigatório: não introduzir dark mode ou theme switcher.
- Preferir wrappers de `@govbr-ds/webcomponents-react` (`<BrButton>`, `<BrInput>`, etc.) a tags `<br-*>` diretas.

Para diretrizes detalhadas, consultar `CLAUDE.md` e `AGENT.md` na raiz do monorepo.
