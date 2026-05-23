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

- `apps/backend`: API Java/Spring Boot reaproveitada de uma API publica da SERPRO para calculo de tributos da Reforma Tributaria sobre o Consumo.
- `apps/web`: frontend Angular 19 inicializado do quickstart GovBR-DS Web Components.
- `apps/mobile`: app Flutter clonado do template Flutter Riverpod Clean Architecture.

Ainda sem stack propria configurada: `packages/shared`, `docker` e `docs`.

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
- `apps/backend/src/main/resources/application-offline.yml`
- `apps/backend/src/test/resources/application-testes.yml`
- `apps/backend/flyway/flyway-pro.conf`
- `apps/backend/flyway/flyway-nonpro.conf`

Frontend:

- `apps/web/package.json`
- `apps/web/angular.json`
- `apps/web/tsconfig.json`
- `apps/web/tsconfig.app.json`
- `apps/web/src/index.html`
- `apps/web/src/app/app.config.ts`
- `apps/web/src/app/app.routes.ts`

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
- Spring Web MVC e WebFlux
- Spring Validation / Jakarta Bean Validation
- Spring Data JPA
- SQLite com Hibernate Community Dialects
- Flyway Maven Plugin
- Spring Cache + Caffeine
- Spring Retry
- springdoc-openapi 2.8.9 / Swagger UI
- Actuator + Micrometer Prometheus
- Lombok
- Jackson XML, JAXB/XSDs
- ModelMapper
- Apache Commons JEXL/Lang
- JUnit 5, AssertJ, Mockito, Spring Test, MockMvc
- JaCoCo

Nao existe no backend atual:

- PostgreSQL
- JWT
- Spring Security como autenticacao de negocio
- H2
- Testcontainers
- Spotless
- Flutter ou Angular como dependencia do backend

Comandos, a partir de `apps/backend`:

```powershell
.\mvnw.cmd clean package
.\mvnw.cmd test
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=offline"
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-pro.conf flyway:migrate
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway-nonpro.conf flyway:migrate
```

Runtime:

- API: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/api/api-docs`
- Health: `http://localhost:9101/health`
- Prometheus: `http://localhost:9101/metrics`

Endpoints principais:

- `POST /api/calculadora/regime-geral`
- `POST /api/calculadora/base-calculo/is-mercadorias`
- `POST /api/calculadora/base-calculo/cbs-ibs-mercadorias`
- `POST /api/calculadora/pedagio`
- `POST /api/calculadora/nfse/base-calculo`
- `POST /api/calculadora/xml/generate`
- `GET /api/calculadora/xml/generate`
- `POST /api/calculadora/xml/validate`
- `GET /api/calculadora/xml/validate`
- `GET /api/calculadora/dados-abertos/...`
- `GET /api/calculadora/dados-abertos/versao`
- `GET /api/versao/status`, somente no perfil `offline`

Padroes:

- Controllers em `api/controller` implementam interfaces `api/openapi/controller`.
- Regras ficam em `domain/service`.
- Repositories usam Spring Data JPA.
- Erros REST centralizados em `ApiExceptionHandler` com `ProblemDetail`.
- Modelos atuais usam classes Java com Lombok, nao records.
- Banco atual e SQLite; nao trocar por outro sem atualizar configs, migrations e testes.

Testes:

- Unitarios com JUnit 5, AssertJ e Mockito.
- Integracao com `@SpringBootTest`, `@AutoConfigureMockMvc`, `MockMvc` e `application-testes.yml`.
- Banco de testes tambem e SQLite.
- Nao converter para H2/Testcontainers sem decisao explicita.

## Frontend Web

Stack real:

- Angular 19.2.x
- TypeScript 5.5.x
- Angular CLI 19.2.x
- Standalone components, sem `NgModule`
- Builder `@angular-devkit/build-angular:application`
- SCSS
- GovBR-DS:
  - `@govbr-ds/core` 3.6.x
  - `@govbr-ds/webcomponents` 2.0.0-next.x
  - `@govbr-ds/webcomponents-angular` 2.0.0-next.x
- RxJS 7.8.x
- Zone.js 0.15.x

Ainda nao existe no frontend:

- `HttpClient` configurado
- Integracao real com `apps/backend`
- Gerenciamento de estado
- Testes unitarios escritos
- ESLint/Prettier/Stylelint
- Environments
- i18n
- PWA

Diretriz visual: web sempre light mode. Nao adicionar dark mode, theme switcher ou estilos de tema escuro.

Comandos, a partir de `apps/web`:

```powershell
npm install
npm run start
npm run build
npm run build:pages
npm run ng -- <args>
```

Runtime:

- Dev server: `http://localhost:4200/`
- Backend independente: `http://localhost:8080/api`
- Ainda nao existe integracao real com backend.

Estrutura atual:

```txt
apps/web/src/
  index.html
  main.ts
  styles.scss
  app/
    app.component.ts
    app.config.ts
    app.routes.ts
    pages/
      home/
      form/
      colors/
    shared/components/
      header/
      menu/
      footer/
  assets/
  data/cores.ts
```

Padroes:

- Manter standalone components.
- Preferir wrappers de `@govbr-ds/webcomponents-angular/standalone`.
- Nao introduzir `NgModule` sem razao explicita.
- Para integrar backend, registrar `provideHttpClient(withFetch())` e centralizar base URL.
- Nao substituir GovBR-DS por Material, PrimeNG, Tailwind ou Bootstrap sem decisao explicita.
- O target de teste referencia `tsconfig.spec.json` e `public/`, mas esses artefatos ainda nao existem; nao assumir que `ng test` funciona sem setup.

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
- `connectivity_plus`, cache local e sync offline
- `cached_network_image`, `shimmer`
- `flutter_form_builder`, `form_builder_validators`
- `local_auth`, `url_launcher`, `package_info_plus`, `in_app_review`, `workmanager`, `flutter_tts`
- `web_socket_channel`
- `flutter_test`, `mocktail`, `golden_toolkit`
- `flutter_launcher_icons`
- `fastlane/Fastfile`
- Plataformas: Android, iOS, Web, Linux, macOS e Windows

Ainda e template:

- Package atual: `flutter_riverpod_clean_architecture`.
- `AppConstants.appName` ainda e `Flutter Riverpod Clean Architecture`.
- Display name futuro: `Augustus - Controlador de finanças pessoais`.
- `AppConstants.apiBaseUrl` aponta para `https://api.yourdomain.com`.
- Android namespace/applicationId ainda usa `com.ssoad.flutter_riverpod_clean_architecture`.
- O template ainda tem `darkTheme` e `ThemeMode.system`; o produto deve ser sempre light mode.
- Features `auth`, `chat`, `survey`, `home`, `settings`, demos e showcase ainda sao exemplos.
- Nao ha integracao real com `apps/backend`.

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

- Nao tratar JWT ou PostgreSQL como stack atual.
- Nao tratar Angular/GovBR-DS como tecnologia do backend.
- Nao tratar Flutter como tecnologia do backend ou do frontend web.
- Nao implementar dark mode ou alternancia de tema no web/mobile.
- Nao trocar SQLite por outro banco sem alterar configuracao, migracoes e testes.
- Nao impor records no backend; o padrao atual usa classes com Lombok.
- Nao assumir autenticacao Spring Security/JWT porque existe log de `security` ou exclusao de autoconfiguracao.
- Nao remover XSDs/modelos XML sem entender endpoints `/calculadora/xml`.
- Nao alterar comportamento tributario original sem plano de migracao para o dominio financeiro.
- Nao introduzir `NgModule` em `apps/web`.
- Nao substituir GovBR-DS por outra biblioteca visual sem decisao explicita.
- Nao remover CDNs de Rawline/Raleway/Font Awesome em `apps/web/src/index.html` sem substituto.
- Nao tratar as features Flutter de exemplo (`auth`, `chat`, `survey`) como dominio final do Augustus.

## Verificacao por tipo de mudanca

- Docs: checar com `rg` que termos antigos/inconsistentes nao ficaram.
- Backend: `.\mvnw.cmd test` ou `.\mvnw.cmd clean package`, conforme escopo.
- Frontend: `npm run build`; testes ainda precisam setup antes de `ng test`.
- Mobile: `flutter analyze` e `flutter test`; usar `build_runner` quando houver codegen.
