# Banco de dados

Esta pasta guarda documentacao e referencias de modelagem de banco do Augustus.

Nada aqui e executado automaticamente pelo backend. Migrations reais do backend continuam em `apps/backend/flyway/sql`.

## Blueprints

- `blueprints/2026-05-23-augustus-multiusuario/`: estrutura alvo do banco multiusuario do Augustus.

Use blueprints como mapa de chegada. Ao implementar uma parte do dominio, crie migrations menores no backend e mantenha o SQL documental como referencia historica.
