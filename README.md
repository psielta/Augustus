<p align="center">
  <img src="docs/assets/brand/augustus-logo.svg" alt="Augustus - Controlador de finanças pessoais" width="360">
</p>

# Augustus - Controlador de finanças pessoais

Este repositorio sera usado como base para o Augustus - Controlador de finanças pessoais.

Nome oficial do produto: `Augustus - Controlador de finanças pessoais`.

Diretrizes visuais:

- A logo oficial tem fundo branco incorporado.
- O frontend web e o app mobile devem ser sempre light mode.
- Não implementar dark mode nem alternância de tema claro/escuro.

Padrao de commits:

- Usar sempre Conventional Commits.
- Formato: `tipo(escopo): descricao curta`.
- Tipos recomendados: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf` e `style`.
- Exemplos: `docs(readme): documenta stack do mobile`, `feat(backend): adiciona cadastro de despesas`.
- Para mudancas incompativeis, usar `!` no tipo/escopo ou rodape `BREAKING CHANGE:`.

Aplicacoes presentes no snapshot atual:

- `apps/backend` — API Java/Spring Boot, originalmente aproveitada de uma API publica da SERPRO para calculo de tributos da Reforma Tributaria sobre o Consumo.
- `apps/web` — Frontend React 19 inicializado a partir do quickstart oficial GovBR-DS Web Components React (https://gitlab.com/govbr-ds/bibliotecas/wbc/govbr-ds-wbc-quickstart-react).
- `apps/mobile` - Aplicativo Flutter clonado do template Flutter Riverpod Clean Architecture (https://github.com/ssoad/flutter_riverpod_clean_architecture).

As pastas `packages/shared` e `docker` continuam como estrutura inicial e ainda nao possuem stack configurada no codigo atual. A pasta `docs` contem documentacao, assets de marca e blueprints de banco, mas nada ali e executado automaticamente pela aplicacao.

## Backend

Localizacao: `apps/backend`

Projeto Maven/Spring Boot chamado `api-regime-geral`, com artefato `CalculadorTributo` e pacote base `br.gov.serpro.rtc`.

### Tecnologias usadas no codigo atual

- Java 21
- Maven Wrapper com Maven 3.9.5
- Spring Boot 3.5.7
- Spring Web MVC (`spring-boot-starter-web`)
- Spring WebFlux (`spring-boot-starter-webflux`)
- Spring Validation / Jakarta Bean Validation
- Spring Security 6.x
- Spring Mail
- Spring Data JPA
- Hibernate Community Dialects
- SQLite (`sqlite-jdbc`)
- Flyway Maven Plugin e Flyway runtime, com scripts em `apps/backend/flyway/sql`
- Spring Cache com Caffeine
- Spring Retry
- springdoc-openapi 2.8.9 / Swagger UI
- Spring Boot Actuator
- Micrometer Prometheus
- Lombok
- Jackson XML
- ModelMapper 3.2.5
- JJWT 0.12.6 (`jjwt-api`, `jjwt-impl`, `jjwt-jackson`)
- Apache Commons JEXL 3.5.0
- Apache Commons Lang 3.18.0
- JUnit 5, AssertJ, Mockito, Spring Test e MockMvc via `spring-boot-starter-test`
- JaCoCo 0.8.12

O backend atual nao usa PostgreSQL, H2, Docker Compose, Testcontainers, React ou Flutter como dependencia do backend.

### Banco e perfis

O perfil principal configurado no repositorio e `offline`.

- API: porta `8080`
- Context path da API: `/api`
- Actuator/Prometheus: porta `9101`
- Banco offline: SQLite em `./calculadora/db/${application.db.filename}`
- Arquivo padrao do perfil `offline`: `calculadora-pro.db`
- Perfil de testes: `application-testes.yml`, usando SQLite isolado em `./target/test-db/calculadora-test.db`
- No profile `testes`, Flyway runtime aplica as migrations automaticamente antes do contexto Spring. `.\mvnw.cmd clean test` recria o banco do zero.
- `application.memoriacalculo.enabled=true` permanece definido em `application-testes.yml` porque os testes legados carregam `MemoriaCalculoService`.

Configs Flyway presentes:

- `apps/backend/flyway/flyway-pro.conf`
- `apps/backend/flyway/flyway-nonpro.conf`

### Blueprint do banco Augustus

A estrutura alvo do banco de dados do produto esta armazenada como referencia em:

- `docs/database/blueprints/2026-05-23-augustus-multiusuario/V20260523_01__create_augustus_multiusuario_schema.sql`
- `docs/database/blueprints/2026-05-23-augustus-multiusuario/insert_default_categories_for_user.sql`
- `docs/database/blueprints/2026-05-23-augustus-multiusuario/README.md`

Esses arquivos nao sao migrations ativas. Eles nao estao em `apps/backend/flyway/sql` e nao devem ser executados automaticamente pelo backend atual.

O blueprint descreve a estrutura padrao desejada para o Augustus multiusuario: usuarios/autenticacao, categorias por usuario, templates de categoria, contas, cartoes, faturas, orcamentos, importacoes, recorrencias, parcelamentos, lancamentos, anexos e views de resumo.

A evolucao deve ser incremental. Ao implementar uma parte do dominio, criar migrations menores no backend, acompanhadas de model, repository, service, controller e testes. Ordem sugerida:

1. Autenticacao e usuarios.
2. Categorias padrao e categorias por usuario.
3. Contas financeiras, cartoes e faturas.
4. Orcamentos, importacoes, recorrencias e parcelamentos.
5. Lancamentos financeiros, anexos e views de consulta.

### Autenticacao Augustus (V0030)

A primeira fatia real do dominio Augustus esta implementada em `apps/backend/flyway/sql/manutencao/V0030__augustus_autenticacao_usuarios.sql`.

Tabelas entregues: `usuario`, `usuario_credencial`, `sessao_usuario`, `token_usuario` e `login_auditoria`.

Endpoints REST sob `/api`:

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`
- `POST /auth/verify-email`
- `GET /auth/verify-email?token=...`
- `POST /auth/resend-verification`

Regras entregues:

- Login exige email verificado; antes disso retorna 403 `EMAIL_NAO_VERIFICADO`.
- Senha sempre BCrypt.
- Access token e JWT HS256 com `sub` do usuario e `sid` da sessao.
- Refresh token e opaco, rotativo e armazenado apenas como SHA-256 hex em `sessao_usuario.refresh_token_hash`.
- Token de verificacao de email tambem e armazenado apenas como SHA-256 hex em `token_usuario.token_hash`.
- `/auth/refresh` revoga a sessao antiga e invalida o access token antigo pelo `sid`.
- `/auth/logout` exige access token valido e revoga somente a sessao corrente.
- `/auth/resend-verification` nao vaza existencia de email e respeita cooldown padrao de 1 minuto.
- Endpoints legados da calculadora, Swagger e Actuator continuam publicos.
- Reset de senha ainda esta pendente.
- Tabelas financeiras do blueprint ainda nao foram implementadas.

Configuracao local de segredos:

- `apps/backend/.env.example` e o template comitavel.
- `apps/backend/.env` e opcional, carregado automaticamente no profile `offline` por `spring.config.import: "optional:file:./.env[.properties]"`.
- `.env` real e ignorado pelo git; nao commitar segredos.
- Variaveis de ambiente do sistema continuam tendo precedencia sobre o `.env`.

Variaveis relevantes:

- `AUGUSTUS_JWT_SECRET` obrigatoria no profile `offline`, com pelo menos 32 caracteres. A aplicacao falha ao iniciar se faltar ou contiver `dev-only`/`trocar-em-producao`.
- `AUGUSTUS_MAIL_HOST` default `smtp.gmail.com`.
- `AUGUSTUS_MAIL_PORT` default `587`.
- `AUGUSTUS_MAIL_USERNAME`.
- `AUGUSTUS_MAIL_PASSWORD`, que deve ser Gmail App Password, nao a senha normal da conta. A conta precisa de 2FA e a senha deve ser criada em `https://myaccount.google.com/apppasswords`.
- `AUGUSTUS_MAIL_FROM`.
- `AUGUSTUS_VERIFICACAO_URL` opcional, default `http://localhost:8080/api/auth/verify-email`. Para o fluxo web em dev, **sobrescrever para `http://localhost:4200/auth/verify-email`** (o frontend React intercepta o `?token=...` e chama o POST do backend, dando UX melhor que o GET text/plain).

Exemplo de setup local:

```powershell
cd apps\backend
Copy-Item .env.example .env
# edite .env e preencha AUGUSTUS_JWT_SECRET e SMTP
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-nonpro.conf flyway:migrate
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=offline"
```

### Comandos

No Windows PowerShell:

```powershell
cd apps\backend
.\mvnw.cmd clean package
.\mvnw.cmd test
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=offline"
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-pro.conf flyway:migrate
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-nonpro.conf flyway:migrate
```

Em Linux/macOS:

```bash
cd apps/backend
./mvnw clean package
./mvnw test
./mvnw spring-boot:run -Dspring-boot.run.profiles=offline
./mvnw -Dflyway.configFiles=./flyway/flyway-pro.conf flyway:migrate
./mvnw -Dflyway.configFiles=./flyway/flyway-nonpro.conf flyway:migrate
```

### Documentacao da API em runtime

Com a aplicacao rodando:

- Swagger UI: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/api/api-docs`
- Health: `http://localhost:9101/health`
- Metricas Prometheus: `http://localhost:9101/metrics`

### Principais areas da API existente

- `POST /api/calculadora/regime-geral`
- `POST /api/calculadora/base-calculo/is-mercadorias`
- `POST /api/calculadora/base-calculo/cbs-ibs-mercadorias`
- `POST /api/calculadora/pedagio`
- `POST /api/calculadora/nfse/base-calculo`
- `POST /api/calculadora/xml/generate`
- `POST /api/calculadora/xml/validate`
- `GET /api/calculadora/dados-abertos/...`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `POST /api/auth/verify-email`
- `GET /api/auth/verify-email?token=...`
- `POST /api/auth/resend-verification`

## Frontend Web

Localizacao: `apps/web`

Projeto React inicializado a partir do quickstart oficial [GovBR-DS Web Components React](https://gitlab.com/govbr-ds/bibliotecas/wbc/govbr-ds-wbc-quickstart-react). Consome o design system [GovBR-DS](https://www.gov.br/ds/home) via biblioteca de [Web Components](https://webcomponent-ds.estaleiro.serpro.gov.br/) atraves dos wrappers React em `@govbr-ds/webcomponents-react`.

### Tecnologias usadas no codigo atual

- React 19.1.x (function components + hooks, sem class components)
- React Router 6.22.x (`BrowserRouter`)
- TypeScript 5.8.x (`strict`, `noUnusedLocals`, `noUnusedParameters`, `noFallthroughCasesInSwitch`)
- Vite 6.3.x (`@vitejs/plugin-react`, dev server em 4200 com proxy `/api`)
- Estilos em CSS / CSS Modules (sem SCSS)
- `@govbr-ds/core` 3.6.x — CSS base do design system (importado em `src/index.css`)
- `@govbr-ds/webcomponents` 2.0.0-next.41 (pinado) — biblioteca de Web Components
- `@govbr-ds/webcomponents-react` 2.0.0-next.41 (pinado) — wrappers React (`BrBreadcrumb`, `BrButton`, `BrInput`, `BrMessage`, `BrFooter*`, etc.)

CDNs referenciadas em `index.html`:

- Fonte Rawline (`cdngovbr-ds.estaleiro.serpro.gov.br`)
- Fonte Raleway (Google Fonts)
- Font Awesome 5.15.4 (cdnjs)

Existe: integracao real com `apps/backend` para autenticacao (`/api/auth/*`) via wrapper `apiFetch` baseado em `fetch`, refresh single-flight em 401 com checagem de erro transitorio, Context API + `useReducer` para estado de auth, hook `useAuth()`, restauracao automatica de sessao no bootstrap, wrapper `<RedirectIfAuthenticated>` para rotas publicas de auth.

Ainda nao existe no frontend: gerenciamento de estado fora de auth (Zustand, Redux), testes unitarios (`vitest` + React Testing Library nao configurados), ESLint/Prettier, environments, i18n ou PWA.

Diretriz visual do frontend: a aplicação web será sempre light mode. Não adicionar dark mode, theme switcher ou estilos alternativos de tema escuro.

### Autenticacao web (v1)

Rotas novas em `apps/web/src/pages/auth/`:

- `/auth/login` — formulario email/senha, mostra erros do `ProblemDetail`, oferece reenvio de email quando o backend retorna `EMAIL_NAO_VERIFICADO`.
- `/auth/register` — formulario nome/email/senha, redireciona para `/auth/verify-pending?email=...` em sucesso.
- `/auth/verify-pending` — instrucao para abrir o link no email, botao "Reenviar email" (checa `r.ok` antes de mostrar sucesso).
- `/auth/verify-email?token=...` — callback do link do email. Le o token, chama `POST /api/auth/verify-email`, redireciona para `/auth/login?verificado=1` em sucesso.

Decisoes de seguranca (MVP — registrar como divida tecnica):

- **`accessToken` e `refreshToken` em `localStorage`**. Centralizado em `src/services/tokenStorage.ts` (mesmas chaves `augustus.auth.*` da fatia Angular anterior). Risco aceito: XSS rouba tokens. Migrar para httpOnly cookie quando o backend suportar Set-Cookie + CSRF.
- **Refresh single-flight em 401**: o wrapper `apiFetch` (`src/services/apiClient.ts`) usa um `inflightRefresh: Promise<boolean> | null` no module-level para garantir 1 refresh por vez mesmo com varios 401 em paralelo. Em erro transitorio (rede, timeout, 5xx) NAO apaga tokens — so limpa storage com slug `refresh-token-invalido`/`nao-autenticado` ou 401 sem body parseavel.
- **Sem CORS no backend**: dev usa `vite.config.ts` com `server.proxy` mapeando `/api` -> `http://localhost:8080`. Producao precisa mover frontend para o mesmo dominio do backend ou habilitar CORS no `SecurityConfig`.

Setup do backend para o fluxo web funcionar end-to-end (dev):

```powershell
# em apps/backend/.env (gitignored)
AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email
spring.datasource.url=jdbc:sqlite:file:./calculadora/db/calculadora-nonpro.db?date_class=TEXT&date_string_format=yyyy-MM-dd&foreign_keys=ON
```

Sem esse `spring.datasource.url`, o profile `offline` aponta para SQLite read-only, e qualquer registro/login falha porque auth precisa de `INSERT`/`UPDATE`.

### Comandos

A partir de `apps/web`:

```powershell
npm install
npm run dev              # vite em http://localhost:4200/ com proxy /api -> :8080
npm run build            # tsc -b && vite build (output em dist/)
npm run preview          # serve a build em modo producao
```

Linux/macOS: mesmos comandos `npm`.

> Sem suite de testes configurada nesta fatia. Para adicionar `vitest` + React Testing Library, instalar deps e criar `vitest.config.ts` — fora do escopo desta fatia.

### Runtime

- Dev server: `http://localhost:4200/` (porta fixada com `strictPort: true` em `vite.config.ts`)
- Backend: `http://localhost:8080/api` (consumido via proxy `/api`)

## Mobile

Localizacao: `apps/mobile`

Projeto Flutter clonado do template [Flutter Riverpod Clean Architecture](https://github.com/ssoad/flutter_riverpod_clean_architecture), cuja documentacao publica esta em https://ssoad.github.io/flutter_riverpod_clean_architecture/getting_started.html.

### Tecnologias usadas no codigo atual

- Flutter com Material App (`MaterialApp.router`)
- Dart SDK `>=3.10.0 <4.0.0`
- Riverpod 3.0.3 (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `riverpod_lint`)
- Clean Architecture por feature: `domain`, `data`, `presentation` e `providers`
- Roteamento com `go_router` 17.0.1
- HTTP com `dio` 5.8.0+1, `LogInterceptor` e `RetryInterceptor`
- Erros funcionais com `fpdart` (`Either<Failure, T>`)
- Modelos com `freezed`, `json_serializable`, `equatable` e `build_runner`
- Assets/codegen com `flutter_gen_runner` e `lib/gen/assets.gen.dart`
- Persistencia local com `shared_preferences`, `hive` e `flutter_secure_storage`
- Localizacao com `flutter_localizations`, `intl`, ARB e `l10n.yaml`
- Recursos offline e conectividade com `connectivity_plus`, cache e sync local
- UI e UX auxiliares com `cached_network_image`, `shimmer`, `flutter_form_builder` e `form_builder_validators`
- Recursos nativos: `local_auth`, `url_launcher`, `package_info_plus`, `in_app_review`, `workmanager`, `flutter_tts`
- WebSocket de exemplo com `web_socket_channel`
- Testes com `flutter_test`, `mocktail` e `golden_toolkit`
- Geracao de icones com `flutter_launcher_icons`
- Automacao mobile com `fastlane/Fastfile`
- Plataformas presentes: Android, iOS, Web, Linux, macOS e Windows

Stack adicionada nesta fatia de autenticacao (acima do template):

- `AuthInterceptor` (injeta `Authorization: Bearer`) e `RefreshInterceptor` (`extends QueuedInterceptor`) com checagem de token obsoleto e refresh single-flight em 401.
- `AuthTokenStorage` em `flutter_secure_storage` (decisao de produto: tokens **so** em secure storage).
- `ProblemDetail` parser que mapeia slugs do backend (`email-nao-verificado`, `usuario-bloqueado`, etc.) para `Failure`s tipados.
- Models Freezed (`UsuarioModel`, `TokenPairModel`, `RegistroModel`) espelhando os DTOs camelCase do backend.
- Use cases por endpoint: `Login`, `Register`, `Logout`, `Refresh`, `Me`, `VerifyEmail`, `ResendVerification`, `RestoreSession`.
- 4 telas: `LoginScreen`, `RegisterScreen`, `VerifyPendingScreen`, `VerifyEmailScreen` (paste-token fallback, ja que deep link foi adiado).
- `appBootstrapProvider` no `main.dart` restaura a sessao no inicio.

Ainda e template (nao alterado nesta fatia): o package Android/iOS continua `com.example.flutter_riverpod_clean_architecture` — renomeacao fica para outra fatia (ver `apps/mobile/rename_app.sh`). O `AppConstants.appName` agora e `Augustus - Controlador de finanças pessoais`.

Diretriz visual do mobile: o app sera **sempre light mode**. `AppTheme.darkTheme` foi removido e `ThemeMode.light` esta fixado em `main.dart`. O provider `themeModeProvider` foi mantido por compatibilidade, mas sempre devolve light e `set()` e no-op.

### Autenticacao mobile (v1)

Base URL do backend Augustus, em ordem de prioridade:

1. `--dart-define=API_BASE_URL=...` (qualquer plataforma).
2. Default por plataforma em runtime, usando `kIsWeb` + `defaultTargetPlatform` (nao depende de `dart:io`, mantendo Flutter Web operacional):
   - Android emulator: `http://10.0.2.2:8080/api`
   - iOS sim / desktop / web: `http://localhost:8080/api`

Dispositivo fisico exige passar `--dart-define=API_BASE_URL=http://<ip-da-maquina>:8080/api`.

Setup do backend para o fluxo mobile funcionar end-to-end (mesmo `.env` da fatia web):

```properties
# apps/backend/.env (gitignored)
AUGUSTUS_JWT_SECRET=...
AUGUSTUS_MAIL_USERNAME=...
AUGUSTUS_MAIL_PASSWORD=...
AUGUSTUS_MAIL_FROM=...
spring.datasource.url=jdbc:sqlite:file:./calculadora/db/calculadora-nonpro.db?date_class=TEXT&date_string_format=yyyy-MM-dd&foreign_keys=ON
```

Fluxo end-to-end:

1. Abrir app -> redireciona para `/login`.
2. Tap "Cadastrar" -> formulario -> redireciona para `/auth/verify-pending`.
3. Abrir o email no desktop, **copiar o valor de `?token=...`** do link recebido.
4. Voltar ao app, tap "Ja tenho o token" -> rota `/auth/verify-email` -> colar -> verificar -> redireciona para `/login?verificado=1`.
5. Login -> tokens salvos no secure storage, `/home`.
6. Fechar app, reabrir -> `appBootstrapProvider` faz `/auth/me`, mantem sessao.
7. Apos `accessTokenExpiraEm` (15 min em prod), qualquer chamada autenticada dispara `RefreshInterceptor`: refresh transparente, request retentada sem o usuario perceber.
8. Logout -> tokens limpos, volta para `/login`.

Endpoints consumidos: ver secao "Autenticacao Augustus" do backend.

### Comandos

A partir de `apps/mobile`:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter test
flutter test --update-goldens
flutter analyze
flutter build apk --release
```

Scripts utilitarios incluidos pelo template:

```bash
./generate_feature.sh --name nome_da_feature
./rename_app.sh --app-name "Augustus - Controlador de finanças pessoais" --package-name com.suaempresa.augustus
./generate_icons.sh
./generate_language.sh --sync
./test_generator.sh nome_da_feature
```

No Windows, esses scripts `.sh` exigem Git Bash, WSL ou outro shell compativel com Bash.

### Estrutura mobile

```txt
apps/mobile/
  pubspec.yaml
  analysis_options.yaml
  l10n.yaml
  lib/
    main.dart
    core/
      accessibility/
      analytics/
      auth/
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
  test/
  android/
  ios/
  web/
  linux/
  macos/
  windows/
  docs/
```

## Estrutura do snapshot atual

```txt
apps/
  backend/
    pom.xml
    mvnw
    mvnw.cmd
    flyway/
      flyway-pro.conf
      flyway-nonpro.conf
      sql/
    src/
      main/
        java/br/gov/serpro/rtc/
        resources/
      test/
        java/br/gov/serpro/rtc/
        resources/application-testes.yml

  web/
    package.json
    vite.config.ts            # server.proxy /api -> :8080, port 4200
    tsconfig.json
    tsconfig.app.json
    tsconfig.node.json
    index.html
    src/
      main.tsx                # <AuthProvider><App /></AuthProvider>
      App.tsx                 # BrowserRouter + rotas (incluindo /auth/*)
      index.css               # @import @govbr-ds/core + .auth-shell
      assets/                 # imagens locais
      components/
        Header/, Menu/, Footer/, Breadcrumb/   # shell GovBR-DS
        RedirectIfAuthenticated.tsx            # wrapper para rotas anonimas
        index.ts                                # barrel
      context/AuthContext.tsx                  # Provider + useReducer
      hooks/useAuth.ts                         # consume Context
      services/
        tokenStorage.ts                        # localStorage (chaves augustus.auth.*)
        apiClient.ts                           # apiFetch + refresh single-flight
        authService.ts                         # registrar/login/refresh/me/...
      types/auth.ts                            # Usuario, TokenPair, ProblemDetail, ...
      pages/
        Home.tsx, Formulario.tsx, Colors.tsx   # demo do quickstart (preservado)
        auth/{Login,Register,VerifyPending,VerifyEmail}Page.tsx
      data/cores.ts

  mobile/
    pubspec.yaml
    lib/
      core/
      features/
      main.dart
    test/
    android/
    ios/
    web/
    linux/
    macos/
    windows/

packages/
  shared/    # vazio no snapshot atual

docs/
  assets/brand/
  database/blueprints/2026-05-23-augustus-multiusuario/
```
