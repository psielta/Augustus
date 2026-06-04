# Augustus Agent Guide

Use este arquivo como contexto operacional para agentes trabalhando neste repositorio.

## Arquitetura atual

- Monorepo em `D:\Augustus`.
- Backend: `apps/backend`, Spring Boot 3.5, Java 21, pacote base `br.com.augustus.backend`.
- Web: `apps/web`, React/Vite, porta `4200`, proxy `/api` para `http://localhost:8080`.
- Mobile: `apps/mobile`, Flutter.
- Banco local do backend: MySQL 8.4 via Docker Compose.
- Profile local do backend: `local`.
- Profile de testes do backend: `testes`.

Nao reintroduza artefatos legados removidos ou endpoints SERPRO. O backend atual exposto neste repositorio e o dominio Augustus de autenticacao.

## Backend local

Arquivos relevantes:

- `apps/backend/pom.xml`
- `apps/backend/docker-compose.yml`
- `apps/backend/.env.example`
- `apps/backend/src/main/resources/application-local.yml`
- `apps/backend/src/test/resources/application-testes.yml`
- `apps/backend/flyway/flyway.conf`
- `apps/backend/flyway/sql/V0001__augustus_auth_baseline.sql`

Porta obrigatoria do MySQL local:

- `localhost:3307` no host
- `3306` dentro do container

String JDBC local:

```properties
jdbc:mysql://localhost:3307/augustus?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8
```

Comandos Windows:

```powershell
cd apps/backend
Copy-Item .env.example .env
docker compose up -d
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
```

`AUGUSTUS_JWT_SECRET` e obrigatorio no `.env` e deve ter pelo menos 32 caracteres. Para testar verificacao por email pelo frontend, configure:

```properties
AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email
```

## Flyway e schema

- Migrations ficam em `apps/backend/flyway/sql`.
- A migration inicial atual e `V0001__augustus_auth_baseline.sql`.
- Nao habilite `baselineOnMigrate` por padrao; isso pode mascarar schema parcial sem tabela `flyway_schema_history`.
- Para reset local de desenvolvimento, use `docker compose down -v` em `apps/backend` e rode `flyway:migrate` novamente.

Pontos de atencao em MySQL:

- `VARCHAR` precisa ser respeitado no codigo antes de persistir headers ou payloads livres.
- Datas do dominio usam `Instant` com Hibernate em UTC.
- Preserve nomes de tabelas em lower case para evitar comportamento diferente de case-sensitivity entre sistemas de arquivos.
- Verifique chaves estrangeiras e ordem de limpeza em testes antes de mudar entidades.

## Testes

Os testes de integracao usam Testcontainers com MySQL, definidos em `AbstractIntegrationTest`.

```powershell
cd apps/backend
.\mvnw.cmd clean test
```

Regras:

- Nao force `DOCKER_HOST` no Surefire.
- Deixe Testcontainers descobrir Docker Desktop, Docker Engine local ou ambiente de CI.
- Os testes nao usam `localhost:3307`; essa porta e apenas para o banco local de desenvolvimento.

## Endpoints backend

Base local:

- API: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/api/api-docs`
- Health: `http://localhost:9101/health`
- Prometheus: `http://localhost:9101/metrics`

Autenticacao:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `POST /api/auth/verify-email`
- `GET /api/auth/verify-email`
- `POST /api/auth/resend-verification`

## Web

```powershell
cd apps/web
npm install
npm run dev
```

O web app consome `/api/auth/*` pelo proxy do Vite. Toda chamada HTTP deve passar por `src/services/apiClient.ts`; tokens continuam centralizados em `src/services/tokenStorage.ts`.

## Validacao antes de finalizar

Para mudancas backend:

```powershell
cd apps/backend
.\mvnw.cmd clean compile
.\mvnw.cmd test
```

Se os testes falharem por Docker indisponivel, reporte explicitamente a falha de ambiente e nao trate como teste aprovado.
