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

- `apps/backend` — Aplicacao Java/Spring Boot completa, aproveitada de uma API publica da SERPRO para calculo de tributos da Reforma Tributaria sobre o Consumo. Tem calculadora tributaria, dados abertos, XML de documentos fiscais, Flyway, SQLite, OpenAPI e testes.
- `apps/web` — Frontend Angular 19 inicializado a partir do quickstart oficial GovBR-DS Web Components (`https://gitlab.com/govbr-ds/bibliotecas/wbc/govbr-ds-wbc-quickstart-angular`). Ver secao [Frontend Web](#frontend-web-appsweb).
- `apps/mobile` - Aplicativo Flutter clonado do template Flutter Riverpod Clean Architecture (`https://github.com/ssoad/flutter_riverpod_clean_architecture`). Ver secao [Mobile](#mobile-appsmobile).

As pastas `packages/shared` e `docker` continuam vazias ou sem manifests de tecnologia no snapshot atual. A pasta `docs` contem documentacao, assets de marca e blueprints de banco, mas nada ali e executado automaticamente pela aplicacao. Nao assumir Docker Compose, PostgreSQL, Node fora de `apps/web` ou qualquer outra stack ate que ela exista no repositorio.

## Fonte de verdade (backend)

Para o backend, derive versoes e dependencias destes arquivos:

- `apps/backend/pom.xml`
- `apps/backend/src/main/resources/application-offline.yml`
- `apps/backend/src/test/resources/application-testes.yml`
- `apps/backend/flyway/flyway-pro.conf`
- `apps/backend/flyway/flyway-nonpro.conf`

Para o frontend, ver secao [Frontend Web](#frontend-web-appsweb). Para o mobile, ver secao [Mobile](#mobile-appsmobile).

## Versoes e tecnologias do backend

- Java: 21
- Maven Wrapper: Maven 3.9.5
- Spring Boot: 3.5.7
- API HTTP: Spring Web MVC
- Dependencia adicional HTTP/reativa: Spring WebFlux
- Validacao: Spring Validation / Jakarta Bean Validation
- Autenticacao: Spring Security 6.x
- Email: Spring Mail
- Persistencia: Spring Data JPA
- Dialeto JPA: Hibernate Community Dialects
- Banco configurado: SQLite via `org.xerial:sqlite-jdbc`
- Migracoes: Flyway Maven Plugin e Flyway runtime no profile `testes`
- Tokens JWT: JJWT 0.12.6
- Cache: Spring Cache + Caffeine
- Retry: Spring Retry
- OpenAPI/Swagger: `org.springdoc:springdoc-openapi-starter-webmvc-ui` 2.8.9
- Observabilidade: Spring Boot Actuator + Micrometer Prometheus
- Reducao de boilerplate: Lombok
- XML: Jackson XML, modelos JAXB e XSDs em `src/main/resources/xml`
- Mapeamento de objetos: ModelMapper 3.2.5
- Expressoes/calculo: Apache Commons JEXL 3.5.0
- Utilitarios: Apache Commons Lang 3.18.0
- Testes: `spring-boot-starter-test`, JUnit 5, AssertJ, Mockito, Spring Test e MockMvc
- Cobertura: JaCoCo 0.8.12

Nao existe no backend atual:

- PostgreSQL
- H2
- Testcontainers
- Spotless
- Flutter
- Docker Compose funcional

Observacao 1: a aplicacao exclui `UserDetailsServiceAutoConfiguration`; a autenticacao Augustus valida credenciais no `AutenticacaoService` e nao usa `UserDetailsService` customizado.

Observacao 2: Angular e GovBR-DS existem no repositorio, porem somente em `apps/web` — o backend nao depende deles nem ha integracao escrita entre as duas aplicacoes ainda.

## Comandos do backend

Executar a partir de `apps/backend`.

Windows PowerShell:

```powershell
.\mvnw.cmd clean package
.\mvnw.cmd test
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=offline"
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-pro.conf flyway:migrate
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-nonpro.conf flyway:migrate
```

Linux/macOS:

```bash
./mvnw clean package
./mvnw test
./mvnw spring-boot:run -Dspring-boot.run.profiles=offline
./mvnw -Dflyway.configFiles=./flyway/flyway-pro.conf flyway:migrate
./mvnw -Dflyway.configFiles=./flyway/flyway-nonpro.conf flyway:migrate
```

O script `migrate.sh` existe, mas aponta para `./flyway/flyway.conf`, arquivo que nao existe neste snapshot. Prefira os comandos explicitos com `flyway-pro.conf` ou `flyway-nonpro.conf`.

## Runtime do backend

Perfil principal documentado: `offline`.

- API: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/api/api-docs`
- Actuator health: `http://localhost:9101/health`
- Prometheus metrics: `http://localhost:9101/metrics`
- Banco offline: `./calculadora/db/calculadora-pro.db`
- Banco de testes: `./target/test-db/calculadora-test.db`, recriado por `.\mvnw.cmd clean test`

## Arquitetura existente do backend

Pacote base: `br.gov.serpro.rtc`.

Estrutura principal:

```txt
api/
  controller/          # controllers REST
  exceptionhandler/    # ProblemDetail e tratamento central de excecoes
  model/               # inputs, outputs, ROC e modelos XML
  openapi/controller/  # interfaces com anotacoes OpenAPI
config/
  cache/               # Caffeine CacheManager
  retry/               # @EnableRetry
  xml/                 # JAXBContext beans
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
- Repository acessa JPA/SQLite.
- Modelos de entrada/saida sao classes Java, em geral com Lombok (`@Getter`, `@Setter`, `@Builder`, `@NoArgsConstructor`), nao records.
- Excecoes REST sao centralizadas em `ApiExceptionHandler`, usando `ProblemDetail`.
- Cache e aplicado com `@Cacheable` em services/repositories e configurado por `cache.specs`.

## Endpoints principais (backend)

Todos ficam sob o context path `/api`.

- `POST /calculadora/regime-geral`
- `POST /calculadora/base-calculo/is-mercadorias`
- `POST /calculadora/base-calculo/cbs-ibs-mercadorias`
- `POST /calculadora/pedagio`
- `POST /calculadora/nfse/base-calculo`
- `POST /calculadora/xml/generate`
- `GET /calculadora/xml/generate`
- `POST /calculadora/xml/validate`
- `GET /calculadora/xml/validate`
- `GET /calculadora/dados-abertos/ufs`
- `GET /calculadora/dados-abertos/ufs/municipios`
- `GET /calculadora/dados-abertos/situacoes-tributarias/cbs-ibs`
- `GET /calculadora/dados-abertos/situacoes-tributarias/imposto-seletivo`
- `GET /calculadora/dados-abertos/classificacoes-tributarias/...`
- `GET /calculadora/dados-abertos/ncm`
- `GET /calculadora/dados-abertos/nbs`
- `GET /calculadora/dados-abertos/fundamentacoes-legais`
- `GET /calculadora/dados-abertos/aliquota-uniao`
- `GET /calculadora/dados-abertos/aliquota-uf`
- `GET /calculadora/dados-abertos/aliquota-municipio`
- `GET /calculadora/dados-abertos/versao`
- `GET /versao/status` somente no perfil `offline`
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`
- `POST /auth/verify-email`
- `GET /auth/verify-email?token=...`
- `POST /auth/resend-verification`

## Autenticacao Augustus

Implementacao atual: primeira fatia de autenticacao/usuarios em `apps/backend`, com migration `V0030__augustus_autenticacao_usuarios.sql`.

Stack real dessa fatia:

- Spring Security stateless.
- JWT HS256 via JJWT 0.12.6.
- Refresh token opaco com SHA-256 hex persistido.
- BCrypt para senha.
- Spring Mail via SMTP.
- Flyway runtime habilitado no profile `testes`.

Regras obrigatorias:

- Login exige email verificado; usuario pendente recebe 403 `EMAIL_NAO_VERIFICADO`.
- `register` cria usuario `PENDENTE_VERIFICACAO`, gera token de verificacao e envia email.
- `POST /auth/verify-email` responde 204 em sucesso; `GET /auth/verify-email?token=...` responde `text/plain` para link clicavel.
- `refresh` sempre rotaciona refresh token, revoga a sessao antiga e invalida o access token antigo pelo `sid`.
- `logout` exige access token valido e revoga apenas a sessao do `sid` corrente.
- `resend-verification` sempre retorna 204, nao vaza existencia de email e respeita `auth.resend.cooldown`.
- Endpoints legados `/calculadora/**`, `/dados-abertos/**`, `/versao/**`, Swagger e Actuator continuam publicos.
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
- `apps/backend/.env` e git-ignored e carregado no profile `offline` por `spring.config.import`.
- `AUGUSTUS_JWT_SECRET` e obrigatorio em `offline`, deve ter pelo menos 32 caracteres e nao pode conter `dev-only`/`trocar-em-producao`.
- SMTP Gmail usa `AUGUSTUS_MAIL_HOST`, `AUGUSTUS_MAIL_PORT`, `AUGUSTUS_MAIL_USERNAME`, `AUGUSTUS_MAIL_PASSWORD`, `AUGUSTUS_MAIL_FROM`.
- `AUGUSTUS_MAIL_PASSWORD` deve ser Gmail App Password de `https://myaccount.google.com/apppasswords`, com 2FA habilitado.
- `AUGUSTUS_VERIFICACAO_URL` define a URL base do link de verificacao.

## Banco e migracoes

- O banco atual e SQLite, nao PostgreSQL.
- As configs Flyway existentes sao `flyway-pro.conf` e `flyway-nonpro.conf`.
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
- Testes de integracao com `@SpringBootTest`, `@AutoConfigureMockMvc`, `MockMvc` e `@TestPropertySource(locations = "classpath:application-testes.yml")`.
- O banco de testes tambem e SQLite.
- O banco de testes fica em `./target/test-db`; `.\mvnw.cmd clean test` recria do zero e aplica Flyway automaticamente.
- `application.memoriacalculo.enabled=true` deve permanecer em `application-testes.yml`, pois testes legados inicializam `MemoriaCalculoService`.
- Nao converter para Testcontainers ou H2 sem decisao explicita.

## Frontend Web (apps/web)

### Fonte de verdade (frontend)

Para o frontend, derive versoes e dependencias destes arquivos:

- `apps/web/package.json`
- `apps/web/angular.json`
- `apps/web/tsconfig.json`
- `apps/web/tsconfig.app.json`
- `apps/web/src/index.html`
- `apps/web/src/app/app.config.ts`
- `apps/web/src/app/app.routes.ts`

### Versoes e tecnologias do frontend

- Angular: 19.2.x (standalone components, sem `NgModule`)
- TypeScript: 5.5.x
- Angular CLI: 19.2.x
- Builder de build: `@angular-devkit/build-angular:application` (esbuild)
- Bootstrap: `bootstrapApplication(AppComponent, appConfig)` em `src/main.ts`
- Roteamento: `provideRouter` em `app.config.ts`, com lazy loading via `loadComponent`
- Estilos: SCSS por componente; `@govbr-ds/core/dist/core.min.css` injetado pelo `angular.json`
- Design system: `@govbr-ds/core` 3.6.x, `@govbr-ds/webcomponents` 2.0.0-next.x, `@govbr-ds/webcomponents-angular` 2.0.0-next.x
- Componentes wrapper Angular: importados de `@govbr-ds/webcomponents-angular/standalone` (ex.: `BrBreadcrumb`)
- RxJS 7.8.x, Zone.js 0.15.x

Externos via CDN em `src/index.html`:

- Fonte Rawline (`cdngovbr-ds.estaleiro.serpro.gov.br`)
- Fonte Raleway (Google Fonts)
- Font Awesome 5.15.4 (cdnjs)

Referencia de uso e catalogo de componentes:

- Design system: `https://www.gov.br/ds/home`
- Storybook dos Web Components: `https://webcomponent-ds.estaleiro.serpro.gov.br/`
- Pacote npm: `https://www.npmjs.com/package/@govbr-ds/webcomponents-angular`

### Autenticacao web (v1 — fatia atual)

Implementada em `apps/web/src/app/core/auth/` + `apps/web/src/app/pages/auth/`. Consome `/api/auth/*` do backend Augustus via proxy reverso de dev.

- **`HttpClient` registrado** em `app.config.ts` via `provideHttpClient(withInterceptors([authInterceptor]))`.
- **Restauracao de sessao no bootstrap** via `provideAppInitializer` que chama `AuthService.restaurarSessao()` (faz `POST /api/auth/refresh` + `GET /api/auth/me` se ha refresh em storage).
- **`AuthService`** baseado em Angular Signals: `usuario`, `status`, `precisaVerificarEmail`, `emailEmVerificacao`, `isAutenticado` (computed). Metodos: `registrar`, `login`, `verificarEmailComToken`, `reenviarVerificacao`, `refresh`, `logout`, `carregarMe`, `restaurarSessao`.
- **`authInterceptor`** (`HttpInterceptorFn` standalone): injeta `Authorization: Bearer ...`, skip para `/api/auth/{login,register,refresh,verify-email,resend-verification}`. Em 401 (fora de skip), chama `auth.refresh()` em **single-flight** (Promise compartilhada) e retenta a request original. Refresh falho propaga 401.
- **Guards funcionais**: `authGuard: CanActivateFn` + `naoAutenticadoGuard: CanMatchFn` em `auth.guard.ts`. Rotas `/auth/login` e `/auth/register` usam `canMatch: [naoAutenticadoGuard]` para evitar mostra-las quando logado. Rotas legadas (`'formulario'`, `'cores'`, `''`) permanecem publicas.
- **Tokens em `localStorage`** via `TokenStorage` (`augustus.auth.access`, `augustus.auth.refresh`, `*.expiraEm`). **Decisao MVP, divida tecnica registrada**: vulneravel a XSS. Migrar para httpOnly cookie quando o backend suportar Set-Cookie + CSRF. Auditar manualmente qualquer uso futuro de `innerHTML`/`bypassSecurityTrust*`/`eval`.
- **`proxy.conf.json`** mapeando `/api -> http://localhost:8080`. Sem CORS no backend; producao precisa mover frontend para mesmo dominio ou habilitar CORS.
- **Link de verificacao por email**: backend usa `AUGUSTUS_VERIFICACAO_URL`. Em dev, **operador deve sobrescrever** para `http://localhost:4200/auth/verify-email`; o frontend tem rota correspondente que extrai `?token=...` e chama `POST /api/auth/verify-email` (JSON, com ProblemDetail em erro — melhor UX que o GET text/plain do backend).
- **Pre-condicao do backend em dev**: precisa rodar `mvnw flyway:migrate` (nonpro) e sobrescrever `spring.datasource.url` no `.env` para o banco gravavel `calculadora-nonpro.db` — o profile `offline` default e read-only.
- **Tratamento de `ProblemDetail`**: helpers em `core/auth/models/problem-detail.ts` (`extrairTipoErro` + `mensagemAmigavel`). Slugs reconhecidos: `email-ja-cadastrado`, `email-nao-verificado`, `credenciais-invalidas`, `usuario-bloqueado`, `refresh-token-invalido`, `token-verificacao-invalido`, `nao-autenticado`, `envio-email-falhou`.

### Nao existe no frontend atual

- Gerenciamento de estado fora de auth (NgRx, NGXS, signal stores customizados — auth usa Signals nativos)
- Outro framework de UI (Tailwind, Bootstrap CSS, Material, PrimeNG)
- Testes unitarios escritos (sem arquivos `*.spec.ts` em `src/`) — `ng test` permanece postpornado, sem `tsconfig.spec.json` nem `public/` nem `karma`/`jasmine` em devDependencies
- ESLint, Prettier ou Stylelint configurados
- Arquivos de ambiente (`src/environments/`)
- i18n / traducoes
- PWA / Service Worker
- httpOnly cookie para tokens (decisao MVP usa localStorage)

Diretriz visual: o frontend web sera sempre light mode. Nao adicionar dark mode, theme switcher ou estilos alternativos de tema escuro.

Versoes GovBR-DS estao **pinadas exatas** em `package.json` (`2.0.0-next.41` sem `^`) para evitar breakage entre pre-releases consecutivos.

### Comandos do frontend

Executar a partir de `apps/web`.

Windows PowerShell:

```powershell
npm install
npm run start            # ng serve, http://localhost:4200/
npm run build            # ng build (production por padrao)
npm run build:pages      # build com base-href para GitLab Pages
npm run ng -- <args>     # Angular CLI direto
```

Linux/macOS: mesmos comandos `npm`.

### Runtime do frontend

- Dev server: `http://localhost:4200/`
- Backend independente: `http://localhost:8080/api` — ainda nao integrado

### Arquitetura existente do frontend

Bootstrap standalone, sem `AppModule`. Estrutura atual:

```txt
apps/web/src/
  index.html
  main.ts                 # bootstrapApplication(AppComponent, appConfig)
  styles.scss
  app/
    app.component.ts      # standalone, importa BrBreadcrumb + componentes shared
    app.config.ts         # provideZoneChangeDetection + provideRouter
    app.routes.ts         # '', 'formulario' (lazy), 'cores' (lazy), wildcard
    pages/
      home/
      form/
      colors/
    shared/
      components/
        header/
        menu/
        footer/
  assets/
  data/cores.ts
```

Padrao predominante:

- Standalone components, declarando `imports: [...]` explicitamente.
- Web Components do GovBR-DS sao consumidos via wrappers `@govbr-ds/webcomponents-angular/standalone` (ex.: `BrBreadcrumb`, `BrButton`, etc.) — preferir esses wrappers ao consumir tags `<br-*>` diretamente.
- Lazy loading de rotas via `loadComponent`.
- Estilos por componente em SCSS; algumas paginas legadas do quickstart ainda usam `.css`.
- TypeScript em modo estrito (`strict`, `noImplicitOverride`, `noPropertyAccessFromIndexSignature`, `strictTemplates`, etc.).

### Diretrizes para evoluir o frontend

- Preferir componentes do GovBR-DS antes de criar componente custom: consultar o Storybook (`https://webcomponent-ds.estaleiro.serpro.gov.br/`) e o catalogo (`https://www.gov.br/ds/components/visao-geral`).
- Manter standalone components — nao introduzir `NgModule` salvo necessidade explicita.
- Para integrar com o backend, registrar `provideHttpClient(withFetch())` em `app.config.ts` e centralizar a base URL (`/api`) em um `InjectionToken` ou arquivo de environment, em vez de hardcoded por servico.
- Antes de habilitar `ng test`, criar `tsconfig.spec.json`, criar o diretorio `public/` e instalar `karma`/`jasmine`/`karma-jasmine-html-reporter`/`karma-chrome-launcher` em devDependencies.
- Logs e erros no console: usar `console.error`/`console.warn` deliberadamente; preferir tratamento de erro em `HttpInterceptor` quando HTTP for adicionado.
- Arquivos herdados do quickstart (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `LICENSE`, `.gitlab-ci.yml`, `release.config.js`, `apps/web/README.md`) ainda nao foram adaptados ao dominio de financas pessoais — confirmar com a pessoa usuaria antes de remove-los ou reescreve-los.

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
- Rede/offline: `connectivity_plus`, cache local e `offline_sync_service`
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
- **GoRouter redirect** atualizado: nao redireciona durante `AuthStatus.inicializando`, redireciona para `/auth/verify-pending` quando `precisaVerificarEmail=true`, mantem rotas publicas do template intocadas (settings, home, chat, etc.).
- **`AppConstants.appName`** agora e `Augustus - Controlador de finanças pessoais`. Package Android/iOS continua `com.example.flutter_riverpod_clean_architecture` — renomear via `apps/mobile/rename_app.sh` fica para outra fatia.
- **Light mode obrigatorio**: `AppTheme.darkTheme` deletado; `MaterialApp.router` nao passa `darkTheme` nem `themeMode`. `themeModeProvider` mantido por compatibilidade mas sempre devolve `ThemeMode.light` e `set()` e no-op.

Ainda e template (nao alterado nesta fatia):

- `AppConstants.packageName` e o Android `applicationId` continuam `com.example.flutter_riverpod_clean_architecture`.
- Features `chat`, `survey`, `home`, `settings`, localization demo e UI showcase sao exemplos do template, nao dominio de financas pessoais.
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

Padrao predominante:

- `main.dart` inicializa `WidgetsFlutterBinding`, carrega `SharedPreferences` e sobe `ProviderScope`.
- `MaterialApp.router` usa `routerProvider`, `AppTheme.lightTheme`, `AppTheme.darkTheme` e localizacao persistida.
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
- Se introduzir PostgreSQL, Docker ou outra stack nova, primeiro adicione manifests/configuracoes reais e depois atualize este arquivo e o `README.md`. O frontend Angular ja foi adicionado em `apps/web`, o mobile Flutter foi adicionado em `apps/mobile` e a autenticacao do backend foi adicionada em `apps/backend`.
- Nao declarar tecnologias em documentacao antes de elas existirem no codigo.
- Ao criar novos modelos no backend, siga o estilo local com Lombok e classes Java, a menos que o projeto decida migrar padrao.
- Contratos HTTP novos no backend devem ter anotacoes OpenAPI nas interfaces em `api/openapi/controller`.
- Logs no backend devem usar SLF4J/Lombok (`@Slf4j`), nao `System.out.println`.
- Quando integrar o frontend ou o mobile ao backend, manter o context path `/api` e a porta `8080` do backend como fonte unica de verdade; configurar a base URL em cada cliente.

## O que nao fazer

- Nao mencionar PostgreSQL como stack atual.
- Nao tratar Flutter como tecnologia do backend ou do frontend web; Flutter existe apenas em `apps/mobile`.
- Nao implementar dark mode ou alternancia de tema no frontend web ou no mobile.
- Nao tratar Angular ou GovBR-DS como tecnologia do backend — eles existem apenas em `apps/web` e ainda nao ha integracao escrita entre as duas aplicacoes.
- Nao trocar SQLite por outro banco sem alterar configuracao, migracoes e testes.
- Nao impor records para DTOs no backend; o projeto atual usa classes com Lombok.
- Nao expor hashes, tokens plain ou senha SMTP em respostas, logs ou DTOs.
- Nao injetar `JavaMailSender` fora de `SmtpEmailService`.
- Nao commitar `.env` real; somente `.env.example`.
- Nao remover XSDs/modelos XML sem entender os endpoints `/calculadora/xml`.
- Nao alterar comportamento tributario original enquanto ele ainda for usado como base de referencia.
- Nao mover o blueprint de banco de `docs/database/blueprints` para Flyway como uma migration unica sem plano incremental.
- Nao introduzir `NgModule` em `apps/web` — o quickstart adotou standalone components e essa direcao deve ser preservada.
- Nao substituir os Web Components do GovBR-DS por outra biblioteca de UI (Material, PrimeNG, Tailwind UI, etc.) sem decisao explicita — o design system foi a razao de escolher esse quickstart.
- Nao remover os links de CDN (Rawline, Raleway, Font Awesome) de `apps/web/src/index.html` sem prover substituto: o CSS do `@govbr-ds/core` depende desses recursos para renderizar corretamente.
- Em `apps/mobile`, nao guardar `accessToken`/`refreshToken` em `shared_preferences`, `Hive` ou cache de memoria persistente — somente `flutter_secure_storage` via `AuthTokenStorage`.
- `RefreshInterceptor` nao pode depender de `authProvider`, `authRepositoryProvider` ou outro provider de UI/dominio — apenas `AuthTokenStorage` e o `refreshDioProvider` (Dio limpo). Quebrar essa regra cria dependencia circular.
- Em `apps/mobile`, nao usar `dart:io` em arquivos compartilhados (`AppConstants`, providers genericos) para detectar plataforma; usar `kIsWeb` + `defaultTargetPlatform` de `package:flutter/foundation.dart` para nao quebrar o build Web do template.
- Nao logar `Authorization` header em `apps/mobile`: o `LogInterceptor` esta configurado com `requestHeader: false` e `responseHeader: false` para nao vazar Bearer.
- Em `apps/mobile`, nao reintroduzir `darkTheme` em `AppTheme` nem `ThemeMode.system`/`dark` em `main.dart` — produto e light-only.
