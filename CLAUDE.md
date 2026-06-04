# Augustus Claude Context

Este repositorio nao usa mais a base antiga do dominio legado/SERPRO. Considere o dominio atual como Augustus autenticacao, com backend Spring Boot, web React e mobile Flutter.

## Componentes

- `apps/backend`: Spring Boot 3.5, Java 21, Maven wrapper, pacote base `br.com.augustus.backend`.
- `apps/web`: React/Vite, porta `4200`, proxy `/api` para o backend local.
- `apps/mobile`: Flutter.

## Backend

Profile local:

```powershell
cd apps/backend
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
```

Banco local:

- MySQL 8.4 via `apps/backend/docker-compose.yml`.
- Porta do host obrigatoria: `3307`.
- Porta interna do container: `3306`.
- Database: `augustus`.

Setup:

```powershell
cd apps/backend
Copy-Item .env.example .env
docker compose up -d
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
```

Variaveis principais:

- `AUGUSTUS_DB_USERNAME`
- `AUGUSTUS_DB_PASSWORD`
- `AUGUSTUS_DB_ROOT_PASSWORD`
- `AUGUSTUS_JWT_SECRET`
- `AUGUSTUS_VERIFICACAO_URL`
- `AUGUSTUS_MAIL_*`

Para testar links de verificacao pelo web app:

```properties
AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email
```

## Flyway

- Config Maven: `apps/backend/flyway/flyway.conf`.
- Scripts: `apps/backend/flyway/sql`.
- Migration inicial atual: `V0001__augustus_auth_baseline.sql`.
- Nao habilite `baselineOnMigrate` por padrao.

Se o schema local estiver inconsistente, recrie explicitamente o volume:

```powershell
cd apps/backend
docker compose down -v
docker compose up -d
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
```

## Testes

Os testes de integracao usam Testcontainers com MySQL pelo profile `testes`.

```powershell
cd apps/backend
.\mvnw.cmd clean test
```

Nao fixe `DOCKER_HOST` no Maven/Surefire. Testcontainers deve descobrir Docker sozinho para funcionar em Windows Docker Desktop, Linux CI ou Docker remoto configurado pelo usuario.

## Endpoints

Base local:

- API: `http://localhost:8080/api`
- Swagger: `http://localhost:8080/api/swagger-ui/index.html`
- OpenAPI: `http://localhost:8080/api/api-docs`
- Health: `http://localhost:9101/health`
- Metrics: `http://localhost:9101/metrics`

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

O frontend usa `http://localhost:4200` e consome o backend pelo proxy `/api`.

Mantenha chamadas HTTP em `src/services/apiClient.ts` e persistencia de tokens em `src/services/tokenStorage.ts`.

## Regras de manutencao

- Nao troque o MySQL do backend sem atualizar dependencias, profiles, Flyway e Testcontainers.
- Nao documente nem exponha endpoints legados removidos.
- Preserve a porta `3307` para o MySQL local.
- Antes de aprovar mudancas backend, rode `.\mvnw.cmd clean compile` e `.\mvnw.cmd test` em `apps/backend`.
