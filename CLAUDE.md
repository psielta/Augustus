# CLAUDE.md

Contexto para agentes de codigo. Mantenha este arquivo sincronizado com a realidade do repositorio; nao documente tecnologias que ainda nao existem no codigo.

## Visao geral

Este repositorio sera usado como base para o Augustus - Controlador de finanças pessoais.

Nome oficial do produto: `Augustus - Controlador de finanças pessoais`.

Diretrizes visuais do produto:

- A logo oficial tem fundo branco incorporado.
- Frontend web e app mobile devem ser sempre light mode.
- Nao implementar dark mode, theme switcher ou alternancia claro/escuro.

Padrao de commits:

- Usar sempre Conventional Commits.
- Formato: `tipo(escopo): descricao curta`.
- Tipos recomendados: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf` e `style`.
- Exemplos: `docs(readme): documenta stack do mobile`, `feat(backend): adiciona cadastro de despesas`.
- Para mudancas incompativeis, usar `!` no tipo/escopo ou rodape `BREAKING CHANGE:`.

Aplicacoes presentes no snapshot atual:

- `apps/backend` — Aplicacao Java/Spring Boot do Augustus, atualmente focada em autenticacao, usuarios e base do dominio financeiro. Tem Flyway, MySQL, OpenAPI, Actuator e testes de integracao com Testcontainers.
- `apps/web` — Frontend Angular (restaurado do quickstart GovBR-DS Web Components Angular) com autenticacao integrada. Ver secao [Frontend Web](#frontend-web-appsweb).
- `apps/mobile` - Aplicativo Flutter clonado do template Flutter Riverpod Clean Architecture (`https://github.com/ssoad/flutter_riverpod_clean_architecture`). Ver secao [Mobile](#mobile-appsmobile).

As pastas `packages/shared` e `docker` continuam vazias ou sem manifests de tecnologia no snapshot atual. O Docker Compose ativo do backend fica em `apps/backend/docker-compose.yml` e sobe MySQL em `localhost:3307`. A pasta `docs` contem documentacao, assets de marca e blueprints de banco, mas nada ali e executado automaticamente pela aplicacao.

## Fonte de verdade (backend)

Para o backend, derive versoes e dependencias destes arquivos:

- `apps/backend/pom.xml`
- `apps/backend/src/main/resources/application-local.yml`
- `apps/backend/src/test/resources/application-testes.yml`
- `apps/backend/docker-compose.yml`
- `apps/backend/flyway/flyway.conf`

Para o frontend, ver secao [Frontend Web](#frontend-web-appsweb). Para o mobile, ver secao [Mobile](#mobile-appsmobile).

## Versoes e tecnologias do backend

- Java: 21
- Maven Wrapper: Maven 3.9.5
- Spring Boot: 3.5.7
- API HTTP: Spring Web MVC
- Validacao: Spring Validation / Jakarta Bean Validation
- Autenticacao: Spring Security 6.x
- Email: Spring Mail
- Persistencia: Spring Data JPA
- Banco configurado: MySQL via `com.mysql:mysql-connector-j`
- Migracoes: Flyway Maven Plugin, `flyway-core` e `flyway-mysql`
- Tokens JWT: JJWT 0.12.6
- OpenAPI/Swagger: `org.springdoc:springdoc-openapi-starter-webmvc-ui` 2.8.9
- Observabilidade: Spring Boot Actuator + Micrometer Prometheus
- Reducao de boilerplate: Lombok
- Testes: `spring-boot-starter-test`, JUnit 5, AssertJ, Mockito, Spring Test e MockMvc
- Testcontainers: `spring-boot-testcontainers`, `testcontainers-junit-jupiter` e `testcontainers-mysql`
- Cobertura: JaCoCo 0.8.12

Nao existe no backend atual:

- PostgreSQL
- H2
- banco embarcado como dependencia de runtime
- Spotless
- Flutter

Observacao 1: a aplicacao exclui `UserDetailsServiceAutoConfiguration`; a autenticacao Augustus valida credenciais no `AutenticacaoService` e nao usa `UserDetailsService` customizado.

Observacao 2: React e GovBR-DS existem no repositorio, porem somente em `apps/web` — o backend nao depende deles nem ha integracao escrita entre as duas aplicacoes ainda.

## Comandos do backend

Executar a partir de `apps/backend`.

Windows PowerShell:

```powershell
.\mvnw.cmd clean package
.\mvnw.cmd test
docker compose up -d
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
```

Linux/macOS:

```bash
./mvnw clean package
./mvnw test
docker compose up -d
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
./mvnw -Dflyway.configFiles=./flyway/flyway.conf flyway:migrate
```

O script `migrate.sh` existe, mas para validacao manual prefira o comando explicito com `-Dflyway.configFiles=./flyway/flyway.conf`, que aponta para MySQL local em `localhost:3307`.

## Runtime do backend

Perfil principal documentado: `local`.

- API: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/api/api-docs`
- Actuator health: `http://localhost:9101/health`
- Prometheus metrics: `http://localhost:9101/metrics`
- MySQL local: `localhost:3307` -> container `3306`, schema `augustus`
- Banco de testes: MySQL efemero via Testcontainers, recriado por `.\mvnw.cmd clean test`

## Arquitetura existente do backend

Pacote base: `br.com.augustus.backend`.

Estrutura principal:

```txt
api/
  controller/          # controllers REST
  exceptionhandler/    # ProblemDetail e tratamento central de excecoes
  model/               # inputs, outputs, ROC e modelos XML
  openapi/controller/  # interfaces com anotacoes OpenAPI
config/
core/
domain/
  model/entity/        # entidades JPA
  model/enumeration/   # enums de dominio
  repository/          # Spring Data JPA repositories
  service/             # regras de negocio
```

Padrao predominante:

- Controller implementa uma interface `*OpenApi`.
- Controller delega regra para service.
- Service contem regra de negocio.
- Repository acessa JPA/MySQL.
- Modelos de entrada/saida sao classes Java, em geral com Lombok (`@Getter`, `@Setter`, `@Builder`, `@NoArgsConstructor`), nao records.
- Excecoes REST sao centralizadas em `ApiExceptionHandler`, usando `ProblemDetail`.
- Cache e aplicado com `@Cacheable` em services/repositories e configurado por `cache.specs`.

## Endpoints principais (backend)

Todos ficam sob o context path `/api`.

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`
- `POST /auth/verify-email`
- `GET /auth/verify-email?token=...`
- `POST /auth/resend-verification`

## Autenticacao Augustus

Implementacao atual: primeira fatia de autenticacao/usuarios em `apps/backend`, com migration `V0001__augustus_auth_baseline.sql`.

Stack real dessa fatia:

- Spring Security stateless.
- JWT HS256 via JJWT 0.12.6.
- Refresh token opaco com SHA-256 hex persistido.
- BCrypt para senha.
- Spring Mail via SMTP.
- Flyway runtime habilitado nos profiles `local` e `testes`.

Regras obrigatorias:

- Login exige email verificado; usuario pendente recebe 403 `EMAIL_NAO_VERIFICADO`.
- `register` cria usuario `PENDENTE_VERIFICACAO`, gera token de verificacao e envia email.
- `POST /auth/verify-email` responde 204 em sucesso; `GET /auth/verify-email?token=...` responde `text/plain` para link clicavel.
- `refresh` sempre rotaciona refresh token, revoga a sessao antiga e invalida o access token antigo pelo `sid`.
- `logout` exige access token valido e revoga apenas a sessao do `sid` corrente.
- `resend-verification` sempre retorna 204, nao vaza existencia de email e respeita `auth.resend.cooldown`.
- Swagger e Actuator continuam publicos. Endpoints de auth publicos: registro, login, refresh e verificacao de email. `/auth/me` e `/auth/logout` exigem access token valido.
- Reset de senha ainda nao existe.

Seguranca e dados sensiveis:

- Senha sempre BCrypt.
- Refresh token sempre SHA-256 hex em `sessao_usuario.refresh_token_hash`.
- Token de verificacao sempre SHA-256 hex em `token_usuario.token_hash`.
- Nunca expor `senha_hash`, `refresh_token_hash`, `token_hash` ou qualquer `*_hash` em DTOs.
- Nunca logar token de verificacao plain nem `AUGUSTUS_MAIL_PASSWORD`.
- `EmailService` e a abstracao; controllers e services de negocio nao devem injetar `JavaMailSender` diretamente.
- Enums de auth usam `@Enumerated(EnumType.STRING)` por causa dos `CHECK` constraints do blueprint.

Configuracao local:

- `apps/backend/.env.example` e comitavel.
- `apps/backend/.env` e git-ignored e carregado no profile `local` por `spring.config.import`.
- `AUGUSTUS_DB_USERNAME`, `AUGUSTUS_DB_PASSWORD` e `AUGUSTUS_DB_ROOT_PASSWORD` configuram o MySQL local do compose.
- `AUGUSTUS_JWT_SECRET` e obrigatorio em `local`, deve ter pelo menos 32 caracteres e nao pode conter `dev-only`/`trocar-em-producao`.
- Em desenvolvimento, SMTP local usa Mailpit no Docker Compose: SMTP `localhost:1025`, UI `http://localhost:8025`.
- Mailpit nao usa usuario, senha, autenticacao SMTP nem STARTTLS.
- Para SMTP real/Gmail, usar `AUGUSTUS_MAIL_HOST`, `AUGUSTUS_MAIL_PORT`, `AUGUSTUS_MAIL_USERNAME`, `AUGUSTUS_MAIL_PASSWORD`, `AUGUSTUS_MAIL_FROM`, `AUGUSTUS_MAIL_SMTP_AUTH=true`, `AUGUSTUS_MAIL_STARTTLS_ENABLE=true` e `AUGUSTUS_MAIL_STARTTLS_REQUIRED=true`.
- `AUGUSTUS_MAIL_PASSWORD` no Gmail deve ser Gmail App Password de `https://myaccount.google.com/apppasswords`, com 2FA habilitado.
- `AUGUSTUS_VERIFICACAO_URL` define a URL base do link de verificacao.

## Banco e migracoes

- O banco atual e MySQL, nao PostgreSQL.
- A config Flyway existente e `flyway.conf`, apontando para `jdbc:mysql://localhost:3307/augustus`.
- Os scripts estao em `apps/backend/flyway/sql`.
- Nao alterar migrations antigas sem uma razao explicita. Prefira criar nova migration quando evoluir o schema.
- A configuracao JPA usa `open-in-view: false`.

### Blueprint do banco Augustus

Existe um blueprint documental da estrutura alvo multiusuario em:

- `docs/database/blueprints/2026-05-23-augustus-multiusuario/V20260523_01__create_augustus_multiusuario_schema.sql`
- `docs/database/blueprints/2026-05-23-augustus-multiusuario/insert_default_categories_for_user.sql`
- `docs/database/blueprints/2026-05-23-augustus-multiusuario/README.md`

Esses arquivos sao referencia, nao migration ativa. Eles ficam fora de `apps/backend/flyway/sql` de proposito para evitar execucao acidental.

O blueprint descreve o banco alvo do Augustus: usuario/autenticacao, categorias por usuario, templates de categoria, contas, cartoes, faturas, orcamentos, importacoes, recorrencias, parcelamentos, lancamentos, anexos e views de resumo.

Ao implementar o dominio financeiro, quebrar o blueprint em migrations menores e incrementais, sempre acompanhadas de codigo backend e testes do recorte entregue. Ordem sugerida: autenticacao/usuarios; categorias; contas/cartoes/faturas; orcamentos/importacoes/recorrencias/parcelamentos; lancamentos/anexos/views.

## Testes do backend

Padroes reais do backend:

- Testes unitarios com JUnit 5, AssertJ e Mockito.
- Testes de integracao com `@SpringBootTest`, `@AutoConfigureMockMvc`, `MockMvc`, `@TestPropertySource(locations = "classpath:application-testes.yml")` e Testcontainers.
- O banco de testes e MySQL efemero via `org.testcontainers.mysql.MySQLContainer`.
- `.\mvnw.cmd clean test` sobe um container limpo e aplica Flyway automaticamente.
- Nao hardcodear `DOCKER_HOST` no Maven/Surefire; deixe o Testcontainers descobrir Docker pelo ambiente.

## Frontend Web (apps/web)

### Fonte de verdade (frontend)

Para o frontend, derive versoes e dependencias destes arquivos:

- `apps/web/package.json`
- `apps/web/angular.json`
- `apps/web/proxy.conf.json`
- `apps/web/tsconfig*.json`
- `apps/web/src/index.html`
- `apps/web/src/main.ts`
- `apps/web/src/app/app.{config,routes,component}.ts`

### Versoes e tecnologias do frontend

- Angular: 19.2.x (standalone components + signals)
- Angular Router: rotas aninhadas + `canActivateChild` / `canMatch`
- TypeScript: 5.5.x (`strict`)
- RxJS ~7.8, zone.js ~0.15
- Build: Angular CLI (`ng serve` / `ng build`)
- Estilos: SCSS por componente + `styles.scss` global; `@govbr-ds/core` via `angular.json`
- Design system: `@govbr-ds/webcomponents-angular` 2.0.0-next.41 (pinado, sem `^`)

### Autenticacao web (v1)

- `HttpClient` + `authInterceptor` (Bearer; skip em rotas publicas de auth)
- `provideAppInitializer` → `auth.restaurarSessao()` antes do primeiro paint
- `AuthService` com signals; `authGuard` + `naoAutenticadoGuard`
- Layouts: `AppLayoutComponent` (area admin protegida) + `AuthLayoutComponent` (auth centralizada)
- Tokens em `localStorage` via `token-storage.ts` (chaves `augustus.auth.*`)
- `proxy.conf.json` + porta 4200; sanitizacao de `redirect` pos-login (`destinoSeguroPosLogin`)
- `AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email` em dev

### Comandos do frontend

```powershell
cd apps/web
npm install
npm start       # ng serve http://localhost:4200/
npm run build   # ng build → dist/
```

### Runtime do frontend

- Dev server: `http://localhost:4200/` (proxy `/api` → `http://localhost:8080`)
- Backend: `http://localhost:8080/api`

### Arquitetura existente do frontend

```txt
apps/web/src/app/
  app.config.ts, app.routes.ts, app.component.*
  layouts/{app-layout,auth-layout}/
  core/auth/
  shared/components/{header,menu,footer}
  pages/{home,form,colors,auth/*}
```

### Diretrizes para evoluir o frontend

- Preferir wrappers `@govbr-ds/webcomponents-angular/standalone`
- Standalone + signals + Router; sem NgModules nem class components
- HTTP via `HttpClient` + interceptor; auth via `AuthService`; tokens so em `token-storage.ts`
- Manter light mode; manter pin `2.0.0-next.41`; manter proxy 4200
## Mobile (apps/mobile)

### Fonte de verdade (mobile)

Para o mobile, derive versoes, dependencias e padroes destes arquivos:

- `apps/mobile/pubspec.yaml`
- `apps/mobile/analysis_options.yaml`
- `apps/mobile/l10n.yaml`
- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/core/constants/app_constants.dart`
- `apps/mobile/lib/core/router/app_router.dart`
- `apps/mobile/lib/core/providers/network_providers.dart`
- `apps/mobile/docs/ARCHITECTURE_GUIDE.md`
- `apps/mobile/docs/TOOLS.md`

O projeto foi clonado do template:

- `https://github.com/ssoad/flutter_riverpod_clean_architecture`
- `https://ssoad.github.io/flutter_riverpod_clean_architecture/getting_started.html`

### Versoes e tecnologias do mobile

- Flutter: aplicativo multiplataforma com `MaterialApp.router`
- Dart SDK: `>=3.10.0 <4.0.0`
- Package atual: `flutter_riverpod_clean_architecture`
- Versionamento atual: `1.0.0+1`
- State management e DI: `flutter_riverpod` 3.0.3, `riverpod_annotation` 3.0.3, `riverpod_generator` 3.0.3
- Roteamento: `go_router` 17.0.1
- Arquitetura: Clean Architecture por feature (`domain`, `data`, `presentation`, `providers`)
- HTTP: `dio` 5.8.0+1 com `LogInterceptor` e `RetryInterceptor`
- Erros funcionais: `fpdart` 1.2.0 com `Either<Failure, T>`
- Modelos e serializacao: `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`, `equatable`, `build_runner`
- Assets/codegen: `flutter_gen_runner` e `lib/gen/assets.gen.dart`
- Persistencia: `shared_preferences`, `hive`, `flutter_secure_storage`
- Localizacao: `flutter_localizations`, `intl`, ARB em `lib/l10n/arb`, geracao configurada por `l10n.yaml`
- Idiomas configurados: `en`, `es`, `fr`, `de`, `ja`, `bn`
- Rede/conectividade: `connectivity_plus`, cache local e servico de sincronizacao local
- Imagens/UI: `cached_network_image`, `shimmer`, componentes em `lib/core/ui`
- Formularios: `flutter_form_builder`, `form_builder_validators`
- Recursos nativos: `local_auth`, `url_launcher`, `package_info_plus`, `in_app_review`, `workmanager`, `flutter_tts`
- Tempo real/exemplo: `web_socket_channel`
- Testes: `flutter_test`, `mocktail`, `golden_toolkit`
- Lint: `flutter_lints`, `custom_lint`, `riverpod_lint`, regras extras em `analysis_options.yaml`
- Icones: `flutter_launcher_icons`
- Automacao mobile: `fastlane/Fastfile`
- Plataformas presentes no clone: Android, iOS, Web, Linux, macOS e Windows
- Android: Gradle Wrapper 8.10.2, Kotlin Android, Java 11, namespace `com.ssoad.flutter_riverpod_clean_architecture`

### Autenticacao mobile (v1 — fatia atual)

Substitui completamente o auth mock do template. Consome `/api/auth/*` do backend Augustus via Dio.

- **Base URL via dart-define + fallback runtime**: `String.fromEnvironment('API_BASE_URL')` (const) com fallback por plataforma usando `kIsWeb` + `defaultTargetPlatform` (de `package:flutter/foundation.dart`, **nao** `dart:io` — preserva compatibilidade com Flutter Web do template). Defaults: Android emulator -> `10.0.2.2:8080`, iOS sim/desktop/web -> `localhost:8080`. Dispositivo fisico exige `--dart-define=API_BASE_URL=http://<ip>:8080/api`.
- **Tokens em `flutter_secure_storage`** via `AuthTokenStorage` (chaves prefixadas `augustus.auth.*`). **Nunca** usar `shared_preferences` ou cache em memoria para tokens.
- **`AuthInterceptor`** (`extends Interceptor`) injeta `Authorization: Bearer` lendo do storage; skip para paths publicos (`/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/verify-email`, `/auth/resend-verification`).
- **`RefreshInterceptor`** (`extends QueuedInterceptor` — Dio 5 removeu `dio.lock()/unlock()`). Em 401: (1) **token-staleness check** — compara o Bearer da request com o token atual em storage; se outro refresh ja completou, so retenta com o novo token sem chamar `/auth/refresh`; (2) caso storage e header coincidem, faz refresh via `refreshDioProvider` (Dio limpo, sem interceptors), salva novos tokens, retenta a request original com header `X-Augustus-Auth-Retry: 1`; (3) refresh falha -> limpa storage e propaga 401. **Nao depende de `authProvider`, `authRepositoryProvider` ou qualquer provider de UI** — quebra dependencia circular.
- **Detecao de sessao perdida**: nao ha push do interceptor para a UI. A proxima chamada autenticada (`/me`, `/logout`, etc.) falha com 401 (storage ja vazio), `AuthNotifier` atualiza estado, GoRouter redirect leva para `/login`.
- **`appBootstrapProvider`** (`FutureProvider<void>`) em `main.dart` dispara `AuthNotifier.inicializar()` no startup; `MaterialApp.router` mostra `_BootstrapSplash` enquanto carrega.
- **Telas**: `LoginScreen`, `RegisterScreen`, `VerifyPendingScreen`, `VerifyEmailScreen` (paste-token fallback, ja que deep link foi adiado). Texto em PT.
- **GoRouter redirect**: nao redireciona durante `AuthStatus.inicializando`; redireciona para `/auth/verify-pending` quando `precisaVerificarEmail=true`; sem sessao manda para `/login`. Rotas publicas hoje sao so as 4 de auth (`/login`, `/register`, `/auth/verify-pending`, `/auth/verify-email`) — as outras (`/home`, `/settings`, `/settings/language`) exigem autenticacao.
- **`AppConstants.appName`** agora e `Augustus - Controlador de finanças pessoais`. Package Android/iOS continua `com.example.flutter_riverpod_clean_architecture` — renomear via `apps/mobile/rename_app.sh` fica para outra fatia.
- **Light mode obrigatorio**: `AppTheme.darkTheme` deletado; `MaterialApp.router` nao passa `darkTheme` nem `themeMode`. `themeModeProvider` mantido por compatibilidade mas sempre devolve `ThemeMode.light` e `set()` e no-op.

Ainda e template (nao alterado nesta fatia):

- `AppConstants.packageName` e o Android `applicationId` continuam `com.example.flutter_riverpod_clean_architecture`.
- `home` e `settings` foram simplificadas (home so welcome + placeholder do dashboard; settings so language switcher) — dominio financeiro real ainda nao implementado.
- Features `chat`, `survey`, `ui_showcase` e o diretorio `lib/examples/` foram removidos (eram puro template, sem nada de financas). Codigo de auth/`home`/`settings` permanece.
- Deep link / app link / universal link para `/auth/verify-email` nao implementado nesta fatia (UX usa "colar token" como fallback).

### Comandos do mobile

Executar a partir de `apps/mobile`.

Windows PowerShell:

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter test
flutter test --update-goldens
flutter analyze
flutter build apk --release
```

Scripts do template, em shell compativel com Bash:

```bash
./generate_feature.sh --name nome_da_feature
./rename_app.sh --app-name "Augustus - Controlador de finanças pessoais" --package-name com.suaempresa.augustus
./generate_icons.sh
./generate_language.sh --sync
./test_generator.sh nome_da_feature
```

No Windows, usar Git Bash, WSL ou outro shell Bash para os scripts `.sh`.

### Arquitetura existente do mobile

Estrutura principal:

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
    ui/                # inclui app_shell.dart (chrome admin: AppBar + Drawer)
  features/
    auth/              # login, register, verify-pending, verify-email
    home/              # welcome + placeholder do dashboard
    settings/          # language switcher
  l10n/
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

Padrao predominante:

- `main.dart` inicializa `WidgetsFlutterBinding`, carrega `SharedPreferences` e sobe `ProviderScope`.
- `MaterialApp.router` usa `routerProvider`, `AppTheme.lightTheme` e localizacao persistida; o produto e light-only.
- `go_router` redireciona por `authProvider` e rotas constantes em `AppConstants`.
- Providers de DI ficam em `features/<feature>/providers`.
- Providers de estado de tela ficam em `features/<feature>/presentation/providers`.
- Domain nao deve depender de Flutter; use cases recebem interfaces de repository.
- Repositories retornam `Either<Failure, T>` quando ha fluxo de erro esperado.
- Cliente HTTP central fica em `core/network/api_client.dart` e `core/providers/network_providers.dart`.

### Diretrizes para evoluir o mobile

- Antes de desenvolver o app de financas pessoais, rodar `rename_app.sh` ou fazer renome equivalente para remover nomes `flutter_riverpod_clean_architecture` e `com.ssoad...`, usando `Augustus - Controlador de finanças pessoais` como display name.
- Ajustar `AppConstants.apiBaseUrl` para a URL real do backend quando a integracao existir.
- Remover ou neutralizar suporte a dark mode do template; manter o app sempre em light mode.
- Criar features de financas pessoais com o gerador ou seguindo a mesma estrutura `domain/data/presentation/providers`.
- Nao chamar `Dio` diretamente a partir de widgets; use data source, repository e use case.
- Nao passar `BuildContext` para use cases, repositories ou data sources.
- Nao guardar tokens em `shared_preferences`; usar `flutter_secure_storage` para segredos.
- Depois de alterar modelos/providers anotados, rodar `dart run build_runner build --delete-conflicting-outputs`.
- Manter `flutter analyze` e `flutter test` passando antes de considerar a feature pronta.
- Se adicionar idioma, atualizar os ARBs e usar `generate_language.sh` ou `flutter gen-l10n` conforme `l10n.yaml`.

## Diretrizes para evoluir para financas pessoais

- Preserve o backend original enquanto a migracao de dominio nao for planejada.
- Ao adicionar funcionalidades de financas pessoais no backend, siga a arquitetura existente: controller, service, repository, model e tratamento central de erro.
- Use o blueprint em `docs/database/blueprints/2026-05-23-augustus-multiusuario` como mapa de chegada, nao como migration unica a ser aplicada de uma vez.
- Se introduzir outra stack nova, primeiro adicione manifests/configuracoes reais e depois atualize este arquivo e o `README.md`. O frontend Angular esta em `apps/web`, o mobile Flutter em `apps/mobile` e o backend usa MySQL via Docker Compose em `apps/backend`.
- Nao declarar tecnologias em documentacao antes de elas existirem no codigo.
- Ao criar novos modelos no backend, siga o estilo local com Lombok e classes Java, a menos que o projeto decida migrar padrao.
- Contratos HTTP novos no backend devem ter anotacoes OpenAPI nas interfaces em `api/openapi/controller`.
- Logs no backend devem usar SLF4J/Lombok (`@Slf4j`), nao `System.out.println`.
- Quando integrar o frontend ou o mobile ao backend, manter o context path `/api` e a porta `8080` do backend como fonte unica de verdade; configurar a base URL em cada cliente.

## O que nao fazer

- Nao mencionar PostgreSQL ou H2 como stack atual.
- Nao tratar Flutter como tecnologia do backend ou do frontend web; Flutter existe apenas em `apps/mobile`.
- Nao implementar dark mode ou alternancia de tema no frontend web ou no mobile.
- Nao tratar Angular/GovBR-DS ou React como tecnologia do backend — o frontend web (Angular + GovBR-DS) existe apenas em `apps/web` e a integracao com o backend e via HTTP (`/api/auth/*`).
- Nao trocar MySQL por outro banco sem alterar configuracao, migracoes, Docker Compose e testes.
- Nao impor records para DTOs no backend; o projeto atual usa classes com Lombok.
- Nao expor hashes, tokens plain ou senha SMTP em respostas, logs ou DTOs.
- Nao injetar `JavaMailSender` fora de `SmtpEmailService`.
- Nao commitar `.env` real; somente `.env.example`.
- Nao recriar endpoints removidos de tributacao sem decisao explicita de produto.
- Nao mover o blueprint de banco de `docs/database/blueprints` para Flyway como uma migration unica sem plano incremental.
- **Nao reintroduzir React/Vite em `apps/web`**: stack atual e Angular + `@govbr-ds/webcomponents-angular`. Nao adicionar `vite.config.ts`, `.tsx`, React Router, `apiFetch`/`fetch` wrapper, Context `useAuth`, etc.
- Nao introduzir class components em `apps/web`.
- Nao substituir GovBR-DS por outra biblioteca visual (Material UI, PrimeReact, Chakra, Tailwind UI) sem decisao explicita.
- Manter `@govbr-ds/webcomponents-angular` **pinado exato** em `2.0.0-next.41` (sem `^`).
- Manter `proxy.conf.json` e porta 4200; nao remover proxy sem mover o web para mesmo dominio ou habilitar CORS.
- Em `apps/web`, toda autenticacao passa pelo `AuthService` injetado (signals); nao ler/gravar `localStorage` fora de `token-storage.ts`.
- Em `apps/web`, toda chamada HTTP ao backend deve usar `HttpClient` (com `authInterceptor` global); nao usar `fetch` direto.
- Em `apps/web`, sempre sanitizar o parametro `redirect` pos-login (`destinoSeguroPosLogin` ou equivalente).
- Nao remover CDNs (Rawline, Raleway, Font Awesome) de `apps/web/src/index.html` sem substituto.
- Nao logar tokens em console no frontend web.
- Em `apps/mobile`, nao guardar `accessToken`/`refreshToken` em `shared_preferences`, `Hive` ou cache de memoria persistente — somente `flutter_secure_storage` via `AuthTokenStorage`.
- `RefreshInterceptor` nao pode depender de `authProvider`, `authRepositoryProvider` ou outro provider de UI/dominio — apenas `AuthTokenStorage` e o `refreshDioProvider` (Dio limpo). Quebrar essa regra cria dependencia circular.
- Em `apps/mobile`, nao usar `dart:io` em arquivos compartilhados (`AppConstants`, providers genericos) para detectar plataforma; usar `kIsWeb` + `defaultTargetPlatform` de `package:flutter/foundation.dart` para nao quebrar o build Web do template.
- Nao logar `Authorization` header em `apps/mobile`: o `LogInterceptor` esta configurado com `requestHeader: false` e `responseHeader: false` para nao vazar Bearer.
- Em `apps/mobile`, nao reintroduzir `darkTheme` em `AppTheme` nem `ThemeMode.system`/`dark` em `main.dart` — produto e light-only.
