-- Helper para o botão "Inserir categorias padrão".
-- Execute no backend dentro de uma transação, substituindo :usuario_id pelo usuário autenticado.
-- Observação: em produção, o ideal é a aplicação gerar UUIDs para categoria.id.
-- O lower(hex(randomblob(16))) abaixo é apenas um gerador SQLite simples para uso direto em SQL.

PRAGMA foreign_keys = ON;

INSERT INTO categoria (
    id,
    usuario_id,
    nome,
    tipo,
    cor_hex,
    icone,
    ordem,
    criada_por_template,
    template_codigo
)
SELECT
    lower(hex(randomblob(16))) AS id,
    :usuario_id AS usuario_id,
    t.nome,
    t.tipo,
    t.cor_hex,
    t.icone,
    t.ordem,
    1 AS criada_por_template,
    t.codigo AS template_codigo
FROM categoria_template t
WHERE t.ativo = 1
  AND NOT EXISTS (
      SELECT 1
      FROM categoria c
      WHERE c.usuario_id = :usuario_id
        AND lower(trim(c.nome)) = lower(trim(t.nome))
        AND c.tipo = t.tipo
  );
