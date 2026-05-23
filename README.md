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
- `apps/web` — Frontend Angular 19 inicializado a partir do quickstart oficial GovBR-DS Web Components (https://gitlab.com/govbr-ds/bibliotecas/wbc/govbr-ds-wbc-quickstart-angular).
- `apps/mobile` - Aplicativo Flutter clonado do template Flutter Riverpod Clean Architecture (https://github.com/ssoad/flutter_riverpod_clean_architecture).

As pastas `packages/shared`, `docker` e `docs` continuam como estrutura inicial e ainda nao possuem stack configurada no codigo atual.

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
- Spring Data JPA
- Hibernate Community Dialects
- SQLite (`sqlite-jdbc`)
- Flyway Maven Plugin, com scripts em `apps/backend/flyway/sql`
- Spring Cache com Caffeine
- Spring Retry
- springdoc-openapi 2.8.9 / Swagger UI
- Spring Boot Actuator
- Micrometer Prometheus
- Lombok
- Jackson XML
- ModelMapper 3.2.5
- Apache Commons JEXL 3.5.0
- Apache Commons Lang 3.18.0
- JUnit 5, AssertJ, Mockito, Spring Test e MockMvc via `spring-boot-starter-test`
- JaCoCo 0.8.12

O backend atual nao usa PostgreSQL, JWT, Spring Security como camada de autenticacao, Angular, Flutter, Docker Compose ou Testcontainers.

### Banco e perfis

O perfil principal configurado no repositorio e `offline`.

- API: porta `8080`
- Context path da API: `/api`
- Actuator/Prometheus: porta `9101`
- Banco offline: SQLite em `./calculadora/db/${application.db.filename}`
- Arquivo padrao do perfil `offline`: `calculadora-pro.db`
- Perfil de testes: `application-testes.yml`, tambem usando SQLite

Configs Flyway presentes:

- `apps/backend/flyway/flyway-pro.conf`
- `apps/backend/flyway/flyway-nonpro.conf`

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

## Frontend Web

Localizacao: `apps/web`

Projeto Angular standalone inicializado a partir do quickstart oficial [GovBR-DS Web Components](https://gitlab.com/govbr-ds/bibliotecas/wbc/govbr-ds-wbc-quickstart-angular). Vai consumir o design system [GovBR-DS](https://www.gov.br/ds/home) via biblioteca de [Web Components](https://webcomponent-ds.estaleiro.serpro.gov.br/).

### Tecnologias usadas no codigo atual

- Angular 19.2.x (standalone components, sem `NgModule`)
- TypeScript 5.5.x
- Angular CLI 19.2.x
- Builder de build: `@angular-devkit/build-angular:application` (esbuild)
- Estilos em SCSS
- `@govbr-ds/core` 3.6.x — CSS base do design system (importado pelo `angular.json`)
- `@govbr-ds/webcomponents` 2.0.0-next.x — biblioteca de Web Components
- `@govbr-ds/webcomponents-angular` 2.0.0-next.x — wrappers Angular standalone (`BrBreadcrumb`, `BrButton`, etc.)
- RxJS 7.8.x, Zone.js 0.15.x

CDNs referenciadas em `src/index.html`:

- Fonte Rawline (`cdngovbr-ds.estaleiro.serpro.gov.br`)
- Fonte Raleway (Google Fonts)
- Font Awesome 5.15.4 (cdnjs)

Ainda nao existe no frontend: HttpClient configurado, integracao com `apps/backend`, gerenciamento de estado, testes unitarios, ESLint/Prettier/Stylelint, environments, i18n ou PWA.

Diretriz visual do frontend: a aplicação web será sempre light mode. Não adicionar dark mode, theme switcher ou estilos alternativos de tema escuro.

### Comandos

A partir de `apps/web`:

```powershell
npm install
npm run start            # ng serve (http://localhost:4200/)
npm run build            # ng build (production por padrao)
npm run build:pages      # build com base-href para GitLab Pages
npm run ng -- <args>     # Angular CLI direto
```

Linux/macOS: mesmos comandos `npm`.

> O `angular.json` referencia `tsconfig.spec.json` e o diretorio `public/` no target de `test`, mas esses arquivos nao existem no snapshot. Para rodar `ng test`, criar primeiro `tsconfig.spec.json` e instalar `karma`/`jasmine`.

### Runtime

- Dev server: `http://localhost:4200/`
- Backend independente em `http://localhost:8080/api` — ainda nao integrado

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

Ainda e template: o pacote continua `flutter_riverpod_clean_architecture`, o nome do app ainda e `Flutter Riverpod Clean Architecture`, a base da API ainda e `https://api.yourdomain.com` em `lib/core/constants/app_constants.dart`, e nao ha integracao real com `apps/backend`.

Diretriz visual do mobile: o app será sempre light mode. O template Flutter ainda possui `darkTheme` e `ThemeMode.system`, mas isso não representa a decisão do produto; ao adaptar o app para Augustus, manter apenas tema claro e não oferecer alternância para dark mode.

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
    angular.json
    package.json
    tsconfig.json
    tsconfig.app.json
    src/
      index.html
      main.ts                 # bootstrapApplication(AppComponent, appConfig)
      styles.scss
      app/
        app.component.{ts,html,scss}
        app.config.ts         # provideRouter + provideZoneChangeDetection
        app.routes.ts         # '', 'formulario' (lazy), 'cores' (lazy)
        pages/                # home, form, colors
        shared/components/    # header, menu, footer
      assets/
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
```
