@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1"
if errorlevel 1 (
  echo.
  echo Falha ao iniciar o Augustus. Veja a mensagem acima.
  pause
  exit /b 1
)