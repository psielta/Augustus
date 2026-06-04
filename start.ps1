# Augustus - sobe MySQL/Mailpit (Docker), backend e frontend web para testes locais.
# Uso: clique duplo em start.bat ou: powershell -ExecutionPolicy Bypass -File start.ps1

$ErrorActionPreference = 'Stop'

$Root = $PSScriptRoot
$BackendDir = Join-Path $Root 'apps\backend'
$WebDir = Join-Path $Root 'apps\web'
$EnvFile = Join-Path $BackendDir '.env'
$EnvExample = Join-Path $BackendDir '.env.example'

$BACKEND_PORT = 8080
$FRONTEND_PORT = 4200
$MYSQL_CONTAINER = 'augustus-mysql'

function Write-Step([string]$Message, [string]$Color = 'Cyan') {
  Write-Host $Message -ForegroundColor $Color
}

function Set-Utf8NoBom([string]$Path, [string[]]$Lines) {
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllLines($Path, $Lines, $utf8)
}

function Stop-Port([int]$Port) {
  $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
  if (-not $connections) { return }

  $procIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique
  foreach ($procId in $procIds) {
    if ($procId -eq 0) { continue }
    $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
    if ($proc) {
      Write-Host "  Encerrando $($proc.ProcessName) (PID $procId) na porta $Port" -ForegroundColor Yellow
      Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    }
  }
}

function Ensure-BackendEnv {
  $jwtPlaceholder = 'AUGUSTUS_JWT_SECRET='
  $jwtValue = 'AUGUSTUS_JWT_SECRET=augustus-local-development-secret-key-2026'

  if (-not (Test-Path $EnvFile)) {
    Write-Step 'Criando apps\backend\.env a partir do template local...' 'Yellow'
    if (Test-Path $EnvExample) {
      Copy-Item $EnvExample $EnvFile
    } else {
      @'
# Gerado por start.ps1 — nao commitar (.gitignore)
AUGUSTUS_DB_USERNAME=augustus
AUGUSTUS_DB_PASSWORD=augustus
AUGUSTUS_DB_ROOT_PASSWORD=root
AUGUSTUS_JWT_SECRET=augustus-local-development-secret-key-2026
AUGUSTUS_MAIL_HOST=localhost
AUGUSTUS_MAIL_PORT=1025
AUGUSTUS_MAIL_USERNAME=
AUGUSTUS_MAIL_PASSWORD=
AUGUSTUS_MAIL_FROM=noreply@augustus.local
AUGUSTUS_MAIL_SMTP_AUTH=false
AUGUSTUS_MAIL_STARTTLS_ENABLE=false
AUGUSTUS_MAIL_STARTTLS_REQUIRED=false
AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email
'@ -split "`n" | ForEach-Object { $_.TrimEnd("`r") }
      Set-Utf8NoBom $EnvFile $template
    }
  }

  $lines = Get-Content $EnvFile
  $changed = $false
  $out = foreach ($line in $lines) {
    if ($line -match '^\s*AUGUSTUS_JWT_SECRET\s*=\s*$') {
      $changed = $true
      $jwtValue
    } elseif ($line -match '^\s*AUGUSTUS_VERIFICACAO_URL\s*=') {
      if ($line -notmatch 'localhost:4200') {
        $changed = $true
        'AUGUSTUS_VERIFICACAO_URL=http://localhost:4200/auth/verify-email'
      } else {
        $line
      }
    } else {
      $line
    }
  }

  if ($out -notcontains $jwtValue -and ($out | Where-Object { $_ -match '^\s*AUGUSTUS_JWT_SECRET\s*=' }).Count -eq 0) {
    $out += $jwtValue
    $changed = $true
  }

  if ($changed) {
    Set-Utf8NoBom $EnvFile @($out)
    Write-Step 'apps\backend\.env atualizado (JWT e URL de verificacao para o web).' 'Yellow'
  } else {
    Write-Step 'apps\backend\.env ja existe.' 'DarkGray'
  }
}

function Test-Docker {
  try {
    docker version *> $null
    return $true
  } catch {
    return $false
  }
}

function Wait-MySqlHealthy {
  param([int]$MaxSeconds = 90)
  Write-Step "Aguardando MySQL ($MYSQL_CONTAINER) ficar healthy (ate ${MaxSeconds}s)..." 'Yellow'
  $deadline = (Get-Date).AddSeconds($MaxSeconds)
  while ((Get-Date) -lt $deadline) {
    $status = docker inspect --format '{{.State.Health.Status}}' $MYSQL_CONTAINER 2>$null
    if ($status -eq 'healthy') {
      Write-Step 'MySQL pronto.' 'Green'
      return
    }
    if ($status -eq 'unhealthy') {
      throw "Container $MYSQL_CONTAINER esta unhealthy. Rode: docker logs $MYSQL_CONTAINER"
    }
    Start-Sleep -Seconds 2
  }
  throw "Timeout aguardando MySQL. Verifique: docker logs $MYSQL_CONTAINER"
}

function Ensure-WebDeps {
  $nodeModules = Join-Path $WebDir 'node_modules'
  if (Test-Path $nodeModules) { return }

  Write-Step 'Instalando dependencias do frontend (npm install)...' 'Yellow'
  Push-Location $WebDir
  try {
    npm install
  } finally {
    Pop-Location
  }
}

Write-Host ''
Write-Host '=== Augustus - Controlador de financas pessoais (dev local) ===' -ForegroundColor Green
Write-Host ''

if (-not (Test-Docker)) {
  throw 'Docker nao encontrado ou nao esta rodando. Instale Docker Desktop e tente novamente.'
}

Write-Step "Liberando portas $BACKEND_PORT e $FRONTEND_PORT..."
Stop-Port $BACKEND_PORT
Stop-Port $FRONTEND_PORT
Start-Sleep -Seconds 2

Ensure-BackendEnv
Ensure-WebDeps

Write-Step 'Subindo MySQL e Mailpit (docker compose)...'
Push-Location $BackendDir
try {
  docker compose --env-file .env up -d
} finally {
  Pop-Location
}

Wait-MySqlHealthy

Write-Step "Iniciando backend Spring Boot (perfil local, porta $BACKEND_PORT)..."
$backendCmd = @"
Set-Location '$BackendDir'
Write-Host 'Augustus Backend — perfil local' -ForegroundColor Green
Write-Host 'API:      http://localhost:$BACKEND_PORT/api' -ForegroundColor DarkGray
Write-Host 'Swagger:  http://localhost:$BACKEND_PORT/api/swagger-ui/index.html' -ForegroundColor DarkGray
Write-Host 'Mailpit:  http://localhost:8025' -ForegroundColor DarkGray
Write-Host ''
.\mvnw.cmd spring-boot:run '-Dspring-boot.run.profiles=local'
"@
Start-Process powershell -ArgumentList '-NoExit', '-Command', $backendCmd

Write-Step 'Aguardando backend comecar (15s)...' 'Yellow'
Start-Sleep -Seconds 15

Write-Step "Iniciando frontend Angular (porta $FRONTEND_PORT)..."
$webCmd = @"
Set-Location '$WebDir'
Write-Host 'Augustus Web — ng serve + proxy /api -> :8080' -ForegroundColor Green
Write-Host 'App: http://localhost:$FRONTEND_PORT' -ForegroundColor DarkGray
Write-Host ''
npm start
"@
Start-Process powershell -ArgumentList '-NoExit', '-Command', $webCmd

Write-Host ''
Write-Host 'Pronto. Janelas separadas: backend e frontend.' -ForegroundColor Green
Write-Host ''
Write-Host "  App web:     http://localhost:$FRONTEND_PORT" -ForegroundColor White
Write-Host "  Login:       http://localhost:$FRONTEND_PORT/auth/login" -ForegroundColor White
Write-Host "  API:         http://localhost:$BACKEND_PORT/api" -ForegroundColor White
Write-Host "  Swagger:     http://localhost:$BACKEND_PORT/api/swagger-ui/index.html" -ForegroundColor White
Write-Host "  Mailpit:     http://localhost:8025  (emails de verificacao)" -ForegroundColor White
Write-Host "  MySQL:       localhost:3307  (schema augustus)" -ForegroundColor White
Write-Host ''
Write-Host '  .env:        apps\backend\.env (gerado/atualizado por este script)' -ForegroundColor DarkGray
Write-Host '  Dica: crie conta em /auth/register e confira o email no Mailpit.' -ForegroundColor DarkGray
Write-Host ''

Start-Process "http://localhost:$FRONTEND_PORT/auth/login"