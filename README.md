# Augustus

Monorepo do Augustus com backend Spring Boot, frontend React e app mobile Flutter.

## Estrutura

- `apps/backend`: API Java/Spring Boot do Augustus.
- `apps/web`: cliente React/Vite para autenticacao.
- `apps/mobile`: app Flutter.

## Backend

O backend atual usa pacote base `br.com.augustus.backend`, profile local `local`, MySQL 8.4 e Flyway.

Principais endpoints:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `POST /api/auth/verify-email`
- `GET /api/auth/verify-email`
- `POST /api/auth/resend-verification`
- `GET /api/swagger-ui/index.html`
- `GET /api/api-docs`
- `GET http://localhost:9101/health`
- `GET http://localhost:9101/metrics`

### Banco local

O MySQL local roda via Docker Compose em `apps/backend/docker-compose.yml`.

- Host: `localhost`
- Porta do host: `3307`
- Porta interna do container: `3306`
- Database: `augustus`
- Usuario padrao: `augustus`

Setup local no Windows:

```powershell
cd apps/backend
Copy-Item .env.example .env
docker compose up -d
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
```

Configure `AUGUSTUS_JWT_SECRET` no `.env` com uma string forte de pelo menos 32 caracteres. Para o fluxo web de verificacao de email, use:

```properties
AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email
```

### Flyway

As migrations ficam em `apps/backend/flyway/sql`.

O arquivo `apps/backend/flyway/flyway.conf` aponta para:

```properties
flyway.url=jdbc:mysql://localhost:3307/augustus?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8
```

`baselineOnMigrate` nao deve ser habilitado por padrao. Se o banco local persistido estiver parcial ou inconsistente, recrie o volume de desenvolvimento explicitamente:

```powershell
cd apps/backend
docker compose down -v
docker compose up -d
.\mvnw.cmd -Dflyway.configFiles=.\flyway\flyway.conf flyway:migrate
```

### Testes

Os testes de integracao usam Testcontainers com MySQL. Eles nao dependem da porta `3307` nem do banco local do Docker Compose; o container de teste e criado isoladamente pelo JUnit.

```powershell
cd apps/backend
.\mvnw.cmd clean test
```

Requisitos:

- Docker disponivel para Testcontainers.
- Nao fixar `DOCKER_HOST` no `pom.xml`; deixe o Testcontainers descobrir o ambiente.

## Frontend web

```powershell
cd apps/web
npm install
npm run dev
```

O Vite usa `http://localhost:4200` e proxy `/api` para `http://localhost:8080`.

## Mobile

O app Flutter fica em `apps/mobile`. Em desenvolvimento, a base URL padrao aponta para o backend em `http://localhost:8080/api` nos ambientes locais suportados e `10.0.2.2` no emulador Android.

## Validacao rapida

```powershell
cd apps/backend
.\mvnw.cmd clean compile
.\mvnw.cmd test
```
