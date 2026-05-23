# Blueprint do banco Augustus multiusuario

Este diretorio guarda a proposta de estrutura alvo do banco de dados do Augustus - Controlador de financas pessoais.

Os arquivos aqui sao referencia documental. Eles nao devem ser tratados como migrations ativas enquanto estiverem em `docs/database/blueprints`.

## Arquivos

- `V20260523_01__create_augustus_multiusuario_schema.sql`: snapshot do schema SQLite alvo para o dominio financeiro multiusuario.
- `insert_default_categories_for_user.sql`: helper para copiar categorias padrao de `categoria_template` para um usuario autenticado.

## Status

- Nao executado pelo backend atual.
- Nao registrado no Flyway atual.
- Nao representa contrato implementado na API.
- Deve orientar a evolucao incremental do backend.

## Resumo do schema alvo

O blueprint define 16 tabelas principais:

- Autenticacao e usuario: `usuario`, `usuario_credencial`, `sessao_usuario`, `token_usuario`, `login_auditoria`.
- Categorias: `categoria_template`, `categoria`.
- Contas e cartoes: `conta_financeira`, `cartao_credito`, `fatura_cartao`.
- Planejamento e importacao: `orcamento_mensal`, `lote_importacao`.
- Recorrencia e parcelamento: `regra_recorrencia`, `plano_parcelamento`.
- Lancamentos: `lancamento_financeiro`, `anexo_lancamento`.

Tambem define views de consulta:

- `vw_lancamento_resultado`
- `vw_resumo_mensal`
- `vw_despesas_por_categoria`
- `vw_despesas_por_cartao`
- `vw_top5_despesas_mensais`

## Decisoes de modelagem

- `usuario` e o dono dos dados e a base da autenticacao.
- Dados financeiros sao isolados por `usuario_id`.
- Categorias nao sao globais: cada categoria pertence a um usuario.
- `categoria_template` guarda sugestoes padrao para serem copiadas para cada usuario.
- Valores monetarios sao armazenados em centavos (`INTEGER`) e sempre positivos.
- Datas usam texto ISO-8601 (`YYYY-MM-DD`) ou `CURRENT_TIMESTAMP`.
- Competencia mensal usa texto `YYYY-MM`.
- Booleanos usam `INTEGER` com `CHECK (0, 1)`.
- Chaves estrangeiras compostas com `(id, usuario_id)` evitam referencia cruzada entre usuarios.

## Ordem sugerida de implementacao

1. Autenticacao e usuarios.
2. Templates de categoria e categorias por usuario.
3. Contas financeiras, cartoes e faturas.
4. Orcamentos, importacoes, recorrencias e parcelamentos.
5. Lancamentos financeiros e anexos.
6. Views e consultas de resumo.

## Como transformar em migration real

Nao mover estes arquivos diretamente para `apps/backend/flyway/sql` sem revisar o escopo.

Quando cada parte for implementada no backend, criar migrations menores e incrementais no padrao do backend, mantendo este blueprint como referencia. Cada migration real deve acompanhar model, repository, service, controller e testes do recorte implementado.
