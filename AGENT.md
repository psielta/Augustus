# AGENT.md

Instrucoes para Codex trabalhar neste repositorio.

## Produto

Nome oficial: `Augustus - Controlador de finanças pessoais`.

Este repositorio sera a base do Augustus, um app de controle de financas pessoais. O snapshot atual ainda mistura templates e codigo reaproveitado; nao trate tudo como produto final.

Diretrizes visuais:

- A logo oficial tem fundo branco incorporado.
- Frontend web e app mobile devem ser sempre light mode.
- Nao implementar dark mode nem alternancia claro/escuro.

Aplicacoes atuais:

- `apps/backend`: API Java/Spring Boot do Augustus, atualmente focada em autenticacao, usuarios e base do dominio financeiro.
- `apps/web`: frontend React 19 inicializado do quickstart GovBR-DS Web Components React (migrado de Angular em 2026-05-24).
- `apps/mobile`: app Flutter clonado do template Flutter Riverpod Clean Architecture.

Ainda sem stack propria configurada: `packages/shared` e `docker`. O MySQL local do backend fica em `apps/backend/docker-compose.yml`. A pasta `docs` contem documentacao, assets de marca e blueprints de banco; nada em `docs` e executado automaticamente.

## Regras gerais para Codex

- Antes de editar, leia os arquivos reais da area afetada. Nao assuma stack pelo nome das pastas.
- Preserve mudancas existentes do usuario. Nao reverta arquivos sem pedido explicito.
- Use `rg`/`rg --files` para explorar o repo.
- Mantenha alteracoes pequenas e relacionadas ao pedido.
- Nao declarar tecnologia em documentacao antes de existir no codigo.
- Nao commitar segredos, certificados, tokens ou configuracoes locais.
- Quando fizer commits, usar sempre Conventional Commits no formato `tipo(escopo): descricao curta`.
- Este diretorio nao e necessariamente um repositorio Git; verifique antes de usar comandos Git.
- Quando uma mudanca for so documental, nao rode builds pesados sem necessidade.
- Se alterar contrato HTTP, atualize a documentacao/OpenAPI correspondente quando existir.

## Padrao de commits

Use sempre Conventional Commits:

- Formato: `tipo(escopo): descricao curta`.
- Tipos recomendados: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf` e `style`.
- Exemplos: `docs(readme): documenta stack do mobile`, `fix(backend): corrige validacao de lancamento`.
- Para mudancas incompativeis, usar `!` no tipo/escopo ou rodape `BREAKING CHANGE:`.

## Fontes de verdade

Documentacao de alto nivel:

- `README.md`
- `CLAUDE.md`
- `AGENT.md`

Use este arquivo como guia operacional do Codex. Use `CLAUDE.md` quando precisar de contexto mais longo ou historico de decisoes. Se houver divergencia entre docs e manifests, o codigo/configuracao real vence.

Backend:

- `apps/backend/pom.xml`
- `apps/backend/src/main/resources/application-local.yml`
- `apps/backend/src/test/resources/application-testes.yml`
- `apps/backend/docker-compose.yml`
- `apps/backend/flyway/flyway.conf`

Blueprint documental do banco alvo:

- `docs/database/blueprints/2026-05-23-augustus-multiusuario/README.md`
- `docs/database/blueprints/2026-05-23-augustus-multiusuario/V20260523_01__create_augustus_multiusuario_schema.sql`
- `docs/database/blueprints/2026-05-23-augustus-multiusuario/insert_default_categories_for_user.sql`

Frontend:

- `apps/web/package.json`
- `apps/web/vite.config.ts`
- `apps/web/tsconfig.json`
- `apps/web/tsconfig.app.json`
- `apps/web/tsconfig.node.json`
- `apps/web/index.html`
- `apps/web/src/main.tsx`
- `apps/web/src/App.tsx`

Mobile:

- `apps/mobile/pubspec.yaml`
- `apps/mobile/analysis_options.yaml`
- `apps/mobile/l10n.yaml`
- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/core/constants/app_constants.dart`
- `apps/mobile/lib/core/router/app_router.dart`
- `apps/mobile/lib/core/providers/network_providers.dart`
- `apps/mobile/docs/ARCHITECTURE_GUIDE.md`
- `apps/mobile/docs/TOOLS.md`

## Backend

Stack real:

- Java 21
- Maven Wrapper 3.9.5
- Spring Boot 3.5.7
- Spring Web MVC
- Spring Validation / Jakarta Bean Validation
- Spring Security 6.x
- Spring Mail
- Spring Data JPA
- MySQL com `mysql-connector-j`
- Flyway Maven Plugin, `flyway-core` e `flyway-mysql`
- JJWT 0.12.6
- springdoc-openapi 2.8.9 / Swagger UI
- Actuator + Micrometer Prometheus
- Lombok
- Docker Compose para MySQL local em `apps/backend/docker-compose.yml`
- JUnit 5, AssertJ, Mockito, Spring Test, MockMvc e Testcontainers
- JaCoCo

Nao existe no backend atual:

- PostgreSQL
- H2
- bancos embarcados como dependencia do backend
- Spotless
- Flutter ou React como dependencia do backend

Comandos, a partir de `apps/backend`:

```powershell
.\mvnw.cmd clean package
.\mvnw.cmd test
docker compose up -d
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
```

Runtime:

- API: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/api/api-docs`
- Health: `http://localhost:9101/health`
- Prometheus: `http://localhost:9101/metrics`
- MySQL local: `localhost:3307` -> container `3306`, schema `augustus`
- Banco de testes: MySQL efemero via Testcontainers, recriado por `.\mvnw.cmd clean test`

Endpoints principais:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `POST /api/auth/verify-email`
- `GET /api/auth/verify-email?token=...`
- `POST /api/auth/resend-verification`

Padroes:

- Controllers em `api/controller` implementam interfaces `api/openapi/controller`.
- Regras ficam em `domain/service`.
- Repositories usam Spring Data JPA.
- Erros REST centralizados em `ApiExceptionHandler` com `ProblemDetail`.
- Modelos atuais usam classes Java com Lombok, nao records.
- Banco atual e MySQL; qualquer troca exige atualizar configs, migrations, Docker Compose e testes.

Testes:

- Unitarios com JUnit 5, AssertJ e Mockito.
- Integracao com `@SpringBootTest`, `@AutoConfigureMockMvc`, `MockMvc`, `application-testes.yml` e Testcontainers.
- Banco de testes e MySQL efemero via `org.testcontainers.mysql.MySQLContainer`.
- `.\mvnw.cmd clean test` sobe um container limpo e aplica Flyway automaticamente.
- Nao hardcodear `DOCKER_HOST` no Maven/Surefire; deixe o Testcontainers descobrir Docker pelo ambiente.

### Autenticacao Augustus

Implementada no backend em `apps/backend` pela migration `V0001__augustus_auth_baseline.sql`.

Tabelas reais: `usuario`, `usuario_credencial`, `sessao_usuario`, `token_usuario`, `login_auditoria`.

Regras:

- Senha sempre BCrypt.
- Access token e JWT HS256 com `sub` do usuario e `sid` da sessao.
- Refresh token e opaco, rotativo e salvo apenas como SHA-256 hex.
- Token de verificacao de email e salvo apenas como SHA-256 hex.
- Login exige email verificado e retorna 403 `EMAIL_NAO_VERIFICADO` antes disso.
- `POST /auth/verify-email` retorna 204; `GET /auth/verify-email?token=...` retorna `text/plain` para link clicavel.
- `POST /auth/resend-verification` sempre retorna 204 e nao vaza existencia de email.
- `POST /auth/logout` revoga apenas a sessao corrente do `sid`.
- Reset de senha ainda nao existe.

Segredos e SMTP:

- `apps/backend/.env.example` e comitavel.
- `apps/backend/.env` e git-ignored e carregado no profile `local`.
- Nunca commitar `.env` real.
- `AUGUSTUS_DB_USERNAME`, `AUGUSTUS_DB_PASSWORD` e `AUGUSTUS_DB_ROOT_PASSWORD` configuram o MySQL local.
- `AUGUSTUS_JWT_SECRET` e obrigatorio em `local`, com pelo menos 32 caracteres.
- Em desenvolvimento, SMTP local usa Mailpit no Docker Compose: SMTP `localhost:1025`, UI `http://localhost:8025`.
- Mailpit nao usa usuario, senha, autenticacao SMTP nem STARTTLS.
- Para SMTP real/Gmail, usar `AUGUSTUS_MAIL_HOST`, `AUGUSTUS_MAIL_PORT`, `AUGUSTUS_MAIL_USERNAME`, `AUGUSTUS_MAIL_PASSWORD`, `AUGUSTUS_MAIL_FROM`, `AUGUSTUS_MAIL_SMTP_AUTH=true`, `AUGUSTUS_MAIL_STARTTLS_ENABLE=true` e `AUGUSTUS_MAIL_STARTTLS_REQUIRED=true`.
- `AUGUSTUS_MAIL_PASSWORD` no Gmail deve ser App Password de `https://myaccount.google.com/apppasswords`, nao senha normal.
- Nunca logar `AUGUSTUS_MAIL_PASSWORD` nem token de verificacao plain.
- `EmailService` e a abstracao; nao injetar `JavaMailSender` fora de `SmtpEmailService`.
- Nunca expor `senha_hash`, `refresh_token_hash`, `token_hash` ou qualquer `*_hash` em DTOs/respostas.
- Enums de auth usam `@Enumerated(EnumType.STRING)`.

## Blueprint do Banco Augustus

O schema alvo multiusuario esta guardado em `docs/database/blueprints/2026-05-23-augustus-multiusuario`.

Trate esses SQLs como documentacao de arquitetura, nao como migrations ativas. Eles nao estao em `apps/backend/flyway/sql` de proposito.

Resumo do blueprint:

- Usuarios/autenticacao: `usuario`, `usuario_credencial`, `sessao_usuario`, `token_usuario`, `login_auditoria`.
- Categorias: `categoria_template` e `categoria`, sempre por usuario.
- Financeiro: contas, cartoes, faturas, orcamentos, importacoes, recorrencias, parcelamentos, lancamentos e anexos.
- Views de resumo para lancamentos, resumo mensal, despesas por categoria, despesas por cartao e top despesas.

Ao evoluir o backend, quebrar esse blueprint em migrations menores e incrementais. Cada recorte deve ter migration real, entidades/modelos, repositories, services, controllers/OpenAPI quando houver endpoint, e testes.

Ordem recomendada: autenticacao/usuarios; categorias; contas/cartoes/faturas; orcamentos/importacoes/recorrencias/parcelamentos; lancamentos/anexos/views.

## Frontend Web

Stack real (migrado de Angular -> React em 2026-05-24):

- React 19.1.x
- React Router 6.22.x (`BrowserRouter`)
- TypeScript 5.8.x (strict, `noUnusedLocals`, `noUnusedParameters`, `noFallthroughCasesInSwitch`, `jsx: react-jsx`)
- Vite 6.3.x com `@vitejs/plugin-react` (esbuild + Rollup)
- CSS / CSS Modules (sem SCSS)
- GovBR-DS (versoes pinadas, sem `^`):
  - `@govbr-ds/core` 3.6.x
  - `@govbr-ds/webcomponents` 2.0.0-next.41
  - `@govbr-ds/webcomponents-react` 2.0.0-next.41
- HTTP: `fetch` nativo via wrapper `apiFetch` (sem Axios)
- State: Context API + `useReducer` + hook `useAuth` (sem Zustand/Redux)

Existe no frontend:

- Autenticacao real consumindo `/api/auth/*` do backend Augustus
  - Telas: `/auth/login`, `/auth/register`, `/auth/verify-pending`, `/auth/verify-email`
  - `AuthContext` + hook `useAuth()` (function components + hooks)
  - `apiFetch` em `src/services/apiClient.ts` com refresh single-flight em 401 (`let inflightRefresh: Promise<boolean> | null` no module-level) e `lerBody` resiliente para 204/empty/non-JSON
  - Wrapper `<RedirectIfAuthenticated>` em `src/components/RedirectIfAuthenticated.tsx` (substitui o `naoAutenticadoGuard` Angular)
  - `tokenStorage` encapsulando `localStorage` com chaves `augustus.auth.{access,refresh,accessExpiraEm,refreshExpiraEm}` (decisao MVP — divida tecnica registrada; mesmas chaves da fatia Angular anterior)
  - `vite.config.ts` com `server.port: 4200`, `strictPort: true`, `server.proxy: { '/api': { target: 'http://localhost:8080' } }`
  - Restauracao de sessao no bootstrap via `useEffect` no `AuthProvider` (chama `restaurarSessao()` uma vez no mount)
  - Refresh transitorio NAO apaga tokens — so limpa em 401 confirmado (slug `refresh-token-invalido`/`nao-autenticado` ou 401 sem body)

Ainda nao existe no frontend:

- Gerenciamento de estado fora de auth (Zustand, Redux Toolkit, Jotai)
- Testes unitarios escritos (sem `*.test.tsx`; Vitest + React Testing Library nao configurados)
- ESLint/Prettier/Stylelint
- Arquivos de ambiente (`.env`, `src/environments/`)
- i18n
- PWA / Service Worker
- httpOnly cookie para tokens (atualmente usa localStorage por decisao MVP)
- Form library (`react-hook-form`, `zod`, `formik`) — usa state nativo + validacao manual
- HTTP client externo (`axios`, `ky`) — usa `fetch` nativo via `apiFetch`

Diretriz visual: web sempre light mode. Nao adicionar dark mode, theme switcher ou estilos de tema escuro.

Env vars do backend que afetam o frontend em dev:

- `AUGUSTUS_VERIFICACAO_URL` deve ser `http://localhost:4200/auth/verify-email` para o link do email cair na rota do frontend.
- MySQL local precisa estar de pe por `docker compose up -d` em `apps/backend`, exposto em `localhost:3307`.

Comandos, a partir de `apps/web`:

```powershell
npm install
npm run dev              # vite, http://localhost:4200/ (strictPort + proxy /api -> :8080)
npm run build            # tsc -b && vite build (output em dist/)
npm run preview          # serve a build de producao localmente
```

Runtime:

- Dev server: `http://localhost:4200/` (porta fixada via `strictPort: true`)
- Backend: `http://localhost:8080/api` (consumido via proxy `/api`)

Estrutura atual:

```txt
apps/web/
  index.html
  vite.config.ts             # server.port=4200 strictPort + proxy /api -> :8080
  package.json
  tsconfig.{json,app.json,node.json}
  src/
    main.tsx                 # <StrictMode><AuthProvider><App /></AuthProvider></StrictMode>
    App.tsx                  # BrowserRouter + Header/Menu/Breadcrumb/Footer + Routes
    index.css                # @import @govbr-ds/core + .auth-shell
    assets/
    components/
      Header/Header.tsx              # saudacao + botao Sair condicional
      Menu/Menu.tsx                  # Home/Formulario/Cores
      Footer/Footer.tsx              # BrFooter*
      Breadcrumb/Breadcrumb.tsx      # BrBreadcrumb default "Augustus"
      RedirectIfAuthenticated.tsx    # wrapper das rotas /auth/login e /auth/register
      index.ts                       # barrel
    context/AuthContext.tsx          # Provider + useReducer + bootstrap useEffect
    hooks/useAuth.ts                 # consume Context (lanca fora do Provider)
    services/
      tokenStorage.ts                # localStorage (augustus.auth.*)
      apiClient.ts                   # apiFetch + refresh single-flight + lerBody
      authService.ts                 # funcoes puras chamando apiFetch
    types/auth.ts                    # Usuario, ProblemDetail, extrairTipoErro, mensagemAmigavel
    pages/
      Home.tsx, Formulario.tsx, Colors.tsx           # demo do quickstart
      auth/{Login,Register,VerifyPending,VerifyEmail}Page.tsx
    data/cores.ts
```

Padroes:

- Function components + hooks (`useState`, `useReducer`, `useEffect`, `useMemo`, `useSearchParams`, `useNavigate`, `useContext`); sem class components.
- Preferir wrappers de `@govbr-ds/webcomponents-react` (`<BrBreadcrumb>`, `<BrButton>`, `<BrInput>`, `<BrMessage>`, etc.) — nao tags `<br-*>` diretas.
- Forms: state local com `useState` + validacao manual por campo, igual ao `Formulario.tsx` do quickstart.
- Toda chamada HTTP ao backend usa path relativo `/api/...` via `apiFetch` (passa pelo proxy em dev e e mesma origem em prod); nao chamar `fetch` direto em paginas/componentes.
- Toda autenticacao passa pelo hook `useAuth()`; nao ler/gravar `localStorage` direto fora de `tokenStorage`.
- Nao remover `server.proxy` ou `strictPort: true` de `vite.config.ts` sem mover frontend para mesmo dominio do backend ou habilitar CORS no `SecurityConfig`.
- Nao trocar `localStorage` por outra estrategia (`sessionStorage`/cookie/IndexedDB) sem auditar XSS no codigo (`dangerouslySetInnerHTML`, `eval`, `new Function`).
- Nao expor `accessToken` ou `refreshToken` em logs ou em `console.log`/`console.warn`/`console.error`.
- Nao substituir GovBR-DS por Material UI, PrimeReact, Chakra, Tailwind UI ou Bootstrap sem decisao explicita.
- Nao desfixar (`^`) as versoes `@govbr-ds/webcomponents*` em `2.0.0-next.41` enquanto o pacote estiver em `-next` — risco de breaking change silenciosa.
- Vitest + React Testing Library nao estao configurados; antes de habilitar testes, criar `vitest.config.ts` (ou `defineConfig` em `vite.config.ts`) e instalar `vitest`, `@testing-library/react`, `@testing-library/jest-dom`, `jsdom`.

## Mobile

Stack real:

- Flutter com `MaterialApp.router`
- Dart SDK `>=3.10.0 <4.0.0`
- Riverpod 3.0.3
- Clean Architecture por feature
- `go_router` 17.0.1
- `dio` 5.8.0+1 com log e retry
- `fpdart` com `Either<Failure, T>`
- `freezed`, `json_serializable`, `equatable`, `build_runner`
- `flutter_gen_runner`
- `shared_preferences`, `hive`, `flutter_secure_storage`
- `flutter_localizations`, `intl`, ARB e `l10n.yaml`
- `connectivity_plus`, cache local e sincronizacao local
- `cached_network_image`, `shimmer`
- `flutter_form_builder`, `form_builder_validators`
- `local_auth`, `url_launcher`, `package_info_plus`, `in_app_review`, `workmanager`, `flutter_tts`
- `web_socket_channel`
- `flutter_test`, `mocktail`, `golden_toolkit`
- `flutter_launcher_icons`
- `fastlane/Fastfile`
- Plataformas: Android, iOS, Web, Linux, macOS e Windows

Stack adicionada na fatia de autenticacao:

- `AuthInterceptor` (`Interceptor`) e `RefreshInterceptor` (`QueuedInterceptor`, Dio 5) em `lib/core/network/interceptors/`.
- `refreshDioProvider` (Dio limpo so para `/auth/refresh`).
- `AuthTokenStorage` em `lib/core/storage/auth_token_storage.dart`, wrapper sobre `SecureStorageService` — tokens **so** em `flutter_secure_storage`.
- Models Freezed: `UsuarioModel`, `TokenPairModel`, `RegistroModel`, ProblemDetail (sem Freezed).
- Enums: `StatusUsuario`, `PapelSistema`, `TipoToken` com `@JsonValue`.
- Use cases: `Login`, `Register`, `Logout`, `Refresh`, `Me`, `VerifyEmail`, `ResendVerification`, `RestoreSession`.
- 4 telas: `LoginScreen`, `RegisterScreen`, `VerifyPendingScreen`, `VerifyEmailScreen`.
- `appBootstrapProvider` no `main.dart` restaura sessao no startup.
- Base URL via `--dart-define=API_BASE_URL=...` com fallback runtime usando `kIsWeb` + `defaultTargetPlatform` (sem `dart:io`).

Ja consolidado nesta fatia (nao mais "template"):

- `AppConstants.appName` agora e `Augustus - Controlador de finanças pessoais`.
- `AppConstants.apiBaseUrl` resolve para o backend Augustus por padrao (10.0.2.2 em Android emulator, localhost no resto).
- `darkTheme` removido; `MaterialApp.router` sem `darkTheme` nem `themeMode`. `themeModeProvider` mantido com `set()` no-op.
- Feature `auth` totalmente substituida: data source mock deletado, repository real consumindo `/api/auth/*`.

Ainda e template (fora do escopo desta fatia):

- Package atual: `flutter_riverpod_clean_architecture`.
- Android namespace/applicationId ainda `com.example.flutter_riverpod_clean_architecture`. Renomear via `apps/mobile/rename_app.sh`.
- Features `chat`, `survey`, `home`, `settings`, demos e showcase continuam exemplos do template.
- Deep link / app link / universal link para `/auth/verify-email` nao implementado — UX usa "colar token" como fallback.

Comandos, a partir de `apps/mobile`:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter test
flutter test --update-goldens
flutter analyze
flutter build apk --release
```

Scripts do template exigem Bash no Windows (Git Bash, WSL ou equivalente):

```bash
./generate_feature.sh --name nome_da_feature
./rename_app.sh --app-name "Augustus - Controlador de finanças pessoais" --package-name com.suaempresa.augustus
./generate_icons.sh
./generate_language.sh --sync
./test_generator.sh nome_da_feature
```

Padroes:

- Criar features em `features/<feature>/domain`, `data`, `presentation` e `providers`.
- Domain nao deve depender de Flutter.
- UI nao chama `Dio` direto; use data source, repository e use case.
- Nao passar `BuildContext` para use cases, repositories ou data sources.
- Tokens e segredos devem ir para `flutter_secure_storage`, nao `shared_preferences`.
- Rodar build runner depois de alterar modelos ou providers anotados.
- Ajustar nome/package/base URL antes de tratar o mobile como produto.
- Remover ou neutralizar suporte a dark mode ao adaptar o template mobile para Augustus.

Estrutura atual:

```txt
apps/mobile/lib/
  main.dart
  core/
    accessibility/
    analytics/
    auth/
    constants/
    error/
    feature_flags/
    localization/
    network/
    providers/
    router/
    storage/
    theme/
    ui/
  features/
    auth/
    chat/
    home/
    settings/
    survey/
    ui_showcase/
  l10n/
  examples/
```

Estrutura esperada por feature:

```txt
features/<feature>/
  domain/
    entities/
    repositories/
    usecases/
  data/
    datasources/
    models/
    repositories/
  presentation/
    providers/
    screens/
    widgets/
  providers/
```

## Integracao futura

- Backend continua em `http://localhost:8080/api`.
- Frontend web deve configurar base URL ou proxy, nao hardcodear endpoint em cada service.
- Mobile deve trocar `AppConstants.apiBaseUrl` pela URL real do backend.
- Ao criar contratos compartilhados, usar `packages/shared` apenas depois de definir formato real.

## O que nao fazer

- Nao tratar PostgreSQL ou H2 como stack atual.
- Nao tratar React/GovBR-DS como tecnologia do backend.
- Nao tratar Flutter como tecnologia do backend ou do frontend web.
- Nao implementar dark mode ou alternancia de tema no web/mobile.
- Nao trocar MySQL por outro banco sem alterar configuracao, migracoes, Docker Compose e testes.
- Nao impor records no backend; o padrao atual usa classes com Lombok.
- Nao expor hashes, tokens plain ou senha SMTP em respostas, logs ou DTOs.
- Nao injetar `JavaMailSender` fora de `SmtpEmailService`.
- Nao commitar `.env` real; somente `.env.example`.
- Nao recriar endpoints removidos de tributacao sem decisao explicita de produto.
- Nao mover o blueprint de banco de `docs/database/blueprints` para Flyway como uma migration unica sem plano incremental.
- Nao reintroduzir Angular em `apps/web`, nem wrapper `@govbr-ds/webcomponents-angular`, nem dependencias que recriem padroes Angular (`@ngrx/*`, RxJS como state manager) — a stack foi migrada para React em 2026-05-24.
- Nao introduzir class components em `apps/web` — function components + hooks sao o padrao.
- Nao substituir GovBR-DS por outra biblioteca visual (Material UI, PrimeReact, Chakra, Tailwind UI) sem decisao explicita.
- Nao desfixar (`^`) versoes `@govbr-ds/webcomponents*` enquanto estiverem em pre-release `-next`.
- Nao remover CDNs de Rawline/Raleway/Font Awesome em `apps/web/index.html` sem substituto.
- Nao tratar as features Flutter de exemplo (`chat`, `survey`) como dominio final do Augustus. A feature `auth` ja foi substituida por integracao real com o backend.
- Em `apps/web`, nao remover `server.proxy` ou `strictPort: true` de `vite.config.ts` sem mover frontend para mesmo dominio do backend ou habilitar CORS no `SecurityConfig`.
- Em `apps/web`, nao trocar `localStorage` por outra estrategia para `accessToken`/`refreshToken` sem auditar XSS no codigo React (uso de `dangerouslySetInnerHTML`, `eval`, `new Function`).
- Em `apps/web`, nao chamar `fetch` direto em paginas/componentes — toda chamada HTTP ao backend deve passar pelo wrapper `apiFetch` em `src/services/apiClient.ts`. Nao ler/gravar `localStorage` direto fora de `src/services/tokenStorage.ts`.
- Em `apps/web` e `apps/mobile`, nao logar `accessToken`, `refreshToken` ou conteudo do `AuthTokenStorage` no console.
- Em `apps/mobile`, nao guardar `accessToken`/`refreshToken` em `shared_preferences`, `Hive` ou cache em memoria; somente `flutter_secure_storage` via `AuthTokenStorage`.
- Em `apps/mobile`, o `RefreshInterceptor` nao pode depender de `authProvider`, `authRepositoryProvider` ou qualquer outro provider de UI/dominio — so `AuthTokenStorage` e `refreshDioProvider`.
- Em `apps/mobile`, nao usar `dart:io` em arquivos compartilhados (`AppConstants`, providers) para detectar plataforma; usar `kIsWeb` + `defaultTargetPlatform` de `package:flutter/foundation.dart` para nao quebrar Flutter Web.
- Em `apps/mobile`, nao reintroduzir `darkTheme` em `AppTheme` nem `ThemeMode.system`/`dark` em `main.dart`.
- Em `apps/mobile`, nao trocar `SafeLogInterceptor` pelo `LogInterceptor` padrao do Dio com `requestBody`/`responseBody=true` — vaza senha em `/auth/login` e tokens em `/auth/refresh`.
- Em `apps/mobile`, nao habilitar retry em metodos nao-idempotentes — `RetryInterceptor` so retenta `GET`/`HEAD`/`OPTIONS` por padrao. Use `extra: {'noRetry': true}` para opt-out explicito quando necessario.
- Em `apps/mobile`, nao remover `android.permission.INTERNET` do `main/AndroidManifest.xml` — release precisa. Nao ampliar `network_security_config.xml` para alem dos hosts de dev (`10.0.2.2`, `localhost`, `127.0.0.1`); producao deve usar HTTPS via `--dart-define=API_BASE_URL=https://...`.

## Verificacao por tipo de mudanca

- Docs: checar com `rg` que termos antigos/inconsistentes nao ficaram.
- Backend: `.\mvnw.cmd test` ou `.\mvnw.cmd clean package`, conforme escopo.
- Frontend: `npm run build`; testes (Vitest + React Testing Library) ainda precisam de setup antes de existirem.
- Mobile: `flutter analyze` e `flutter test`; usar `build_runner` quando houver codegen.
