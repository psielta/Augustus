-- Augustus - Controlador de finanças pessoais
-- Schema SQLite inicial corrigido para SaaS multiusuario.
-- Pensado para uso como migration Flyway em apps/backend/flyway/sql.
--
-- Principais decisões:
--   * usuario é o dono dos dados e também a base da autenticação.
--   * Categorias NÃO são globais: categoria.usuario_id é obrigatório.
--   * categoria_template guarda apenas sugestões padrão para copiar para cada usuário.
--   * Todas as tabelas financeiras têm usuario_id para isolamento multiusuário.
--   * Chaves estrangeiras compostas (id, usuario_id) evitam que um lançamento de um usuário
--     aponte para categoria/conta/cartão/fatura de outro usuário.
--   * Valores monetários ficam em centavos (INTEGER), sempre positivos.
--   * Datas ficam em TEXT ISO-8601: YYYY-MM-DD ou CURRENT_TIMESTAMP.
--   * mes_competencia fica em TEXT no formato YYYY-MM.
--   * Booleans usam INTEGER com CHECK (0, 1).

PRAGMA foreign_keys = ON;

-- ============================================================
-- Autenticação e usuários
-- ============================================================

CREATE TABLE usuario (
    id TEXT PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT NOT NULL,
    email_normalizado TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ATIVO'
        CHECK (status IN ('ATIVO', 'PENDENTE_VERIFICACAO', 'BLOQUEADO', 'DESATIVADO')),
    papel_sistema TEXT NOT NULL DEFAULT 'USUARIO'
        CHECK (papel_sistema IN ('USUARIO', 'ADMIN')),
    email_verificado INTEGER NOT NULL DEFAULT 0 CHECK (email_verificado IN (0, 1)),
    moeda_padrao TEXT NOT NULL DEFAULT 'BRL',
    timezone TEXT NOT NULL DEFAULT 'America/Sao_Paulo',
    locale TEXT NOT NULL DEFAULT 'pt-BR',
    ultimo_login_em TEXT,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (length(trim(nome)) > 0),
    CHECK (length(trim(email)) > 0),
    CHECK (length(trim(email_normalizado)) > 0)
);

CREATE UNIQUE INDEX ux_usuario_email_normalizado
    ON usuario (email_normalizado);

CREATE INDEX idx_usuario_status
    ON usuario (status);

CREATE TABLE usuario_credencial (
    usuario_id TEXT PRIMARY KEY,
    senha_hash TEXT NOT NULL,
    algoritmo_hash TEXT NOT NULL DEFAULT 'BCRYPT',
    senha_alterada_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deve_alterar_senha INTEGER NOT NULL DEFAULT 0 CHECK (deve_alterar_senha IN (0, 1)),
    tentativas_login_falhas INTEGER NOT NULL DEFAULT 0 CHECK (tentativas_login_falhas >= 0),
    bloqueado_ate TEXT,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

CREATE TABLE sessao_usuario (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    refresh_token_hash TEXT NOT NULL,
    dispositivo_nome TEXT,
    user_agent TEXT,
    ip_criacao TEXT,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_uso_em TEXT,
    expira_em TEXT NOT NULL,
    revogado_em TEXT,
    motivo_revogacao TEXT,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX ux_sessao_usuario_refresh_token_hash
    ON sessao_usuario (refresh_token_hash);

CREATE INDEX idx_sessao_usuario_usuario_ativa
    ON sessao_usuario (usuario_id, expira_em, revogado_em);

CREATE TABLE token_usuario (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    tipo TEXT NOT NULL
        CHECK (tipo IN ('VERIFICACAO_EMAIL', 'RESET_SENHA', 'ALTERACAO_EMAIL')),
    token_hash TEXT NOT NULL,
    destino_email TEXT,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expira_em TEXT NOT NULL,
    usado_em TEXT,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX ux_token_usuario_hash
    ON token_usuario (token_hash);

CREATE INDEX idx_token_usuario_usuario_tipo
    ON token_usuario (usuario_id, tipo, expira_em, usado_em);

CREATE TABLE login_auditoria (
    id TEXT PRIMARY KEY,
    usuario_id TEXT,
    email_informado TEXT,
    sucesso INTEGER NOT NULL CHECK (sucesso IN (0, 1)),
    motivo TEXT,
    ip TEXT,
    user_agent TEXT,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE SET NULL
);

CREATE INDEX idx_login_auditoria_usuario_data
    ON login_auditoria (usuario_id, criado_em);

CREATE INDEX idx_login_auditoria_email_data
    ON login_auditoria (email_informado, criado_em);

-- ============================================================
-- Sugestões de categorias padrão
-- ============================================================
-- Esta tabela NÃO representa categorias dos usuários.
-- Ela é apenas um catálogo de templates para o frontend/backend copiar para categoria.usuario_id.

CREATE TABLE categoria_template (
    codigo TEXT PRIMARY KEY,
    nome TEXT NOT NULL,
    tipo TEXT NOT NULL
        CHECK (tipo IN ('DESPESA', 'RECEITA', 'PAGAMENTO_CARTAO', 'TRANSFERENCIA')),
    cor_hex TEXT,
    icone TEXT,
    ordem INTEGER NOT NULL DEFAULT 0,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1)),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ux_categoria_template_nome_tipo
    ON categoria_template (lower(trim(nome)), tipo);

INSERT INTO categoria_template (codigo, nome, tipo, ordem) VALUES
    ('despesa_alimentacao', 'Alimentação', 'DESPESA', 10),
    ('despesa_assinaturas', 'Assinaturas', 'DESPESA', 20),
    ('despesa_compras', 'Compras', 'DESPESA', 30),
    ('despesa_educacao', 'Educação', 'DESPESA', 40),
    ('despesa_ia_infraestrutura', 'IA & Infraestrutura', 'DESPESA', 50),
    ('despesa_lazer', 'Lazer', 'DESPESA', 60),
    ('despesa_pix_transferencias', 'PIX / Transferências', 'DESPESA', 70),
    ('despesa_pessoal', 'Pessoal', 'DESPESA', 80),
    ('despesa_saude', 'Saúde', 'DESPESA', 90),
    ('despesa_taxas_juros', 'Taxas & Juros', 'DESPESA', 100),
    ('despesa_telefonia', 'Telefonia', 'DESPESA', 110),
    ('despesa_vestuario', 'Vestuário', 'DESPESA', 120),
    ('receita_salario', 'Salário', 'RECEITA', 10),
    ('pagamento_cartao_parcial', 'Pagamento Parcial', 'PAGAMENTO_CARTAO', 10);

-- ============================================================
-- Categorias do usuário
-- ============================================================

CREATE TABLE categoria (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    categoria_pai_id TEXT,
    nome TEXT NOT NULL,
    tipo TEXT NOT NULL
        CHECK (tipo IN ('DESPESA', 'RECEITA', 'PAGAMENTO_CARTAO', 'TRANSFERENCIA')),
    cor_hex TEXT,
    icone TEXT,
    ordem INTEGER NOT NULL DEFAULT 0,
    criada_por_template INTEGER NOT NULL DEFAULT 0 CHECK (criada_por_template IN (0, 1)),
    template_codigo TEXT,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1)),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (template_codigo) REFERENCES categoria_template(codigo) ON DELETE SET NULL,
    FOREIGN KEY (categoria_pai_id, usuario_id) REFERENCES categoria(id, usuario_id) ON DELETE CASCADE,
    UNIQUE (id, usuario_id),
    CHECK (length(trim(nome)) > 0)
);

CREATE UNIQUE INDEX ux_categoria_usuario_nome_tipo
    ON categoria (usuario_id, lower(trim(nome)), tipo);

CREATE INDEX idx_categoria_usuario_tipo_ativa
    ON categoria (usuario_id, tipo, ativo);

CREATE INDEX idx_categoria_usuario_template
    ON categoria (usuario_id, template_codigo)
    WHERE template_codigo IS NOT NULL;

-- ============================================================
-- Contas, cartões e faturas
-- ============================================================

CREATE TABLE conta_financeira (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    nome TEXT NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'CONTA_CORRENTE'
        CHECK (tipo IN ('CONTA_CORRENTE', 'POUPANCA', 'CARTEIRA', 'INVESTIMENTO', 'OUTRA')),
    instituicao TEXT,
    moeda TEXT NOT NULL DEFAULT 'BRL',
    saldo_inicial_centavos INTEGER NOT NULL DEFAULT 0,
    cor_hex TEXT,
    icone TEXT,
    padrao INTEGER NOT NULL DEFAULT 0 CHECK (padrao IN (0, 1)),
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1)),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    UNIQUE (id, usuario_id),
    CHECK (length(trim(nome)) > 0)
);

CREATE UNIQUE INDEX ux_conta_financeira_usuario_nome
    ON conta_financeira (usuario_id, lower(trim(nome)));

CREATE INDEX idx_conta_financeira_usuario_ativa
    ON conta_financeira (usuario_id, ativo);

CREATE TABLE cartao_credito (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    conta_pagamento_padrao_id TEXT,
    nome TEXT NOT NULL,
    instituicao TEXT,
    ultimos_digitos TEXT,
    limite_centavos INTEGER CHECK (limite_centavos IS NULL OR limite_centavos >= 0),
    dia_fechamento INTEGER CHECK (dia_fechamento IS NULL OR dia_fechamento BETWEEN 1 AND 31),
    dia_vencimento INTEGER CHECK (dia_vencimento IS NULL OR dia_vencimento BETWEEN 1 AND 31),
    cor_hex TEXT,
    icone TEXT,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1)),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (conta_pagamento_padrao_id, usuario_id) REFERENCES conta_financeira(id, usuario_id) ON DELETE RESTRICT,
    UNIQUE (id, usuario_id),
    CHECK (length(trim(nome)) > 0),
    CHECK (ultimos_digitos IS NULL OR length(ultimos_digitos) BETWEEN 2 AND 4)
);

CREATE UNIQUE INDEX ux_cartao_credito_usuario_nome
    ON cartao_credito (usuario_id, lower(trim(nome)));

CREATE INDEX idx_cartao_credito_usuario_ativo
    ON cartao_credito (usuario_id, ativo);

CREATE TABLE fatura_cartao (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    cartao_id TEXT NOT NULL,
    mes_referencia TEXT NOT NULL,
    data_abertura TEXT,
    data_fechamento TEXT,
    data_vencimento TEXT,
    valor_total_centavos INTEGER NOT NULL DEFAULT 0 CHECK (valor_total_centavos >= 0),
    valor_pago_centavos INTEGER NOT NULL DEFAULT 0 CHECK (valor_pago_centavos >= 0),
    status TEXT NOT NULL DEFAULT 'ABERTA'
        CHECK (status IN ('ABERTA', 'FECHADA', 'PAGA', 'VENCIDA', 'CANCELADA')),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (cartao_id, usuario_id) REFERENCES cartao_credito(id, usuario_id) ON DELETE RESTRICT,
    UNIQUE (id, usuario_id),
    UNIQUE (id, cartao_id, usuario_id),
    UNIQUE (cartao_id, mes_referencia),
    CHECK (mes_referencia GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]')
);

CREATE INDEX idx_fatura_cartao_usuario_mes
    ON fatura_cartao (usuario_id, mes_referencia, status);

CREATE INDEX idx_fatura_cartao_cartao_mes
    ON fatura_cartao (cartao_id, mes_referencia);

-- ============================================================
-- Planejamento, recorrência, parcelamento e importação
-- ============================================================

CREATE TABLE orcamento_mensal (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    categoria_id TEXT NOT NULL,
    mes_competencia TEXT NOT NULL,
    valor_limite_centavos INTEGER NOT NULL CHECK (valor_limite_centavos >= 0),
    alerta_percentual INTEGER NOT NULL DEFAULT 80 CHECK (alerta_percentual BETWEEN 1 AND 100),
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1)),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id, usuario_id) REFERENCES categoria(id, usuario_id) ON DELETE RESTRICT,
    UNIQUE (usuario_id, categoria_id, mes_competencia),
    CHECK (mes_competencia GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]')
);

CREATE INDEX idx_orcamento_mensal_usuario_mes
    ON orcamento_mensal (usuario_id, mes_competencia, ativo);

CREATE TABLE lote_importacao (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    origem TEXT NOT NULL DEFAULT 'PLANILHA'
        CHECK (origem IN ('PLANILHA', 'CSV', 'OFX', 'OPEN_FINANCE', 'MANUAL', 'OUTRA')),
    nome_arquivo TEXT,
    hash_arquivo TEXT,
    status TEXT NOT NULL DEFAULT 'PROCESSANDO'
        CHECK (status IN ('PROCESSANDO', 'CONCLUIDO', 'CONCLUIDO_COM_ERROS', 'FALHOU', 'CANCELADO')),
    total_linhas INTEGER NOT NULL DEFAULT 0 CHECK (total_linhas >= 0),
    linhas_processadas INTEGER NOT NULL DEFAULT 0 CHECK (linhas_processadas >= 0),
    linhas_erro INTEGER NOT NULL DEFAULT 0 CHECK (linhas_erro >= 0),
    mensagem_erro TEXT,
    iniciado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    concluido_em TEXT,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    UNIQUE (id, usuario_id)
);

CREATE INDEX idx_lote_importacao_usuario_status
    ON lote_importacao (usuario_id, status, iniciado_em);

CREATE TABLE regra_recorrencia (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    conta_id TEXT,
    cartao_id TEXT,
    categoria_id TEXT,
    tipo_lancamento TEXT NOT NULL
        CHECK (tipo_lancamento IN ('DESPESA', 'RECEITA', 'PAGAMENTO_CARTAO', 'TRANSFERENCIA')),
    descricao TEXT NOT NULL,
    valor_centavos INTEGER NOT NULL CHECK (valor_centavos >= 0),
    frequencia TEXT NOT NULL
        CHECK (frequencia IN ('DIARIA', 'SEMANAL', 'QUINZENAL', 'MENSAL', 'BIMESTRAL', 'TRIMESTRAL', 'SEMESTRAL', 'ANUAL')),
    dia_mes INTEGER CHECK (dia_mes IS NULL OR dia_mes BETWEEN 1 AND 31),
    data_inicio TEXT NOT NULL,
    data_fim TEXT,
    proxima_execucao TEXT,
    ativa INTEGER NOT NULL DEFAULT 1 CHECK (ativa IN (0, 1)),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (conta_id, usuario_id) REFERENCES conta_financeira(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (cartao_id, usuario_id) REFERENCES cartao_credito(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (categoria_id, usuario_id) REFERENCES categoria(id, usuario_id) ON DELETE RESTRICT,
    UNIQUE (id, usuario_id),
    CHECK (length(trim(descricao)) > 0)
);

CREATE INDEX idx_regra_recorrencia_usuario_proxima
    ON regra_recorrencia (usuario_id, ativa, proxima_execucao);

CREATE TABLE plano_parcelamento (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    cartao_id TEXT,
    categoria_id TEXT,
    descricao TEXT NOT NULL,
    valor_total_centavos INTEGER NOT NULL CHECK (valor_total_centavos >= 0),
    quantidade_parcelas INTEGER NOT NULL CHECK (quantidade_parcelas > 0),
    data_primeira_parcela TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ATIVO'
        CHECK (status IN ('ATIVO', 'CONCLUIDO', 'CANCELADO')),
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (cartao_id, usuario_id) REFERENCES cartao_credito(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (categoria_id, usuario_id) REFERENCES categoria(id, usuario_id) ON DELETE RESTRICT,
    UNIQUE (id, usuario_id),
    CHECK (length(trim(descricao)) > 0)
);

CREATE INDEX idx_plano_parcelamento_usuario_status
    ON plano_parcelamento (usuario_id, status);

-- ============================================================
-- Lançamentos financeiros
-- ============================================================

CREATE TABLE lancamento_financeiro (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    conta_id TEXT,
    conta_destino_id TEXT,
    cartao_id TEXT,
    fatura_cartao_id TEXT,
    categoria_id TEXT,
    regra_recorrencia_id TEXT,
    plano_parcelamento_id TEXT,
    lote_importacao_id TEXT,

    data_lancamento TEXT NOT NULL,
    mes_competencia TEXT NOT NULL,
    descricao TEXT NOT NULL,
    estabelecimento TEXT,
    observacao TEXT,
    valor_centavos INTEGER NOT NULL CHECK (valor_centavos >= 0),
    tipo TEXT NOT NULL
        CHECK (tipo IN ('DESPESA', 'RECEITA', 'PAGAMENTO_CARTAO', 'TRANSFERENCIA')),
    forma_pagamento TEXT
        CHECK (forma_pagamento IS NULL OR forma_pagamento IN ('CREDITO', 'DEBITO', 'PIX', 'BOLETO', 'DINHEIRO', 'TRANSFERENCIA', 'OUTRA')),
    status TEXT NOT NULL DEFAULT 'CONFIRMADO'
        CHECK (status IN ('CONFIRMADO', 'PREVISTO', 'CANCELADO')),
    origem TEXT NOT NULL DEFAULT 'MANUAL'
        CHECK (origem IN ('MANUAL', 'PLANILHA', 'CSV', 'OFX', 'OPEN_FINANCE', 'RECORRENCIA', 'PARCELAMENTO', 'OUTRA')),
    numero_parcela INTEGER CHECK (numero_parcela IS NULL OR numero_parcela > 0),
    total_parcelas INTEGER CHECK (total_parcelas IS NULL OR total_parcelas > 0),
    tags_json TEXT,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (conta_id, usuario_id) REFERENCES conta_financeira(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (conta_destino_id, usuario_id) REFERENCES conta_financeira(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (cartao_id, usuario_id) REFERENCES cartao_credito(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (fatura_cartao_id, cartao_id, usuario_id) REFERENCES fatura_cartao(id, cartao_id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (categoria_id, usuario_id) REFERENCES categoria(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (regra_recorrencia_id, usuario_id) REFERENCES regra_recorrencia(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (plano_parcelamento_id, usuario_id) REFERENCES plano_parcelamento(id, usuario_id) ON DELETE RESTRICT,
    FOREIGN KEY (lote_importacao_id, usuario_id) REFERENCES lote_importacao(id, usuario_id) ON DELETE RESTRICT,
    UNIQUE (id, usuario_id),

    CHECK (length(trim(descricao)) > 0),
    CHECK (data_lancamento GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    CHECK (mes_competencia GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]'),
    CHECK (fatura_cartao_id IS NULL OR cartao_id IS NOT NULL),
    CHECK (forma_pagamento IS NULL OR forma_pagamento <> 'CREDITO' OR cartao_id IS NOT NULL),
    CHECK (tipo <> 'PAGAMENTO_CARTAO' OR (cartao_id IS NOT NULL AND conta_id IS NOT NULL)),
    CHECK (tipo <> 'TRANSFERENCIA' OR (conta_id IS NOT NULL AND conta_destino_id IS NOT NULL AND conta_id <> conta_destino_id)),
    CHECK (numero_parcela IS NULL OR total_parcelas IS NULL OR numero_parcela <= total_parcelas)
);

CREATE INDEX idx_lancamento_usuario_data
    ON lancamento_financeiro (usuario_id, data_lancamento DESC);

CREATE INDEX idx_lancamento_usuario_mes_status
    ON lancamento_financeiro (usuario_id, mes_competencia, status);

CREATE INDEX idx_lancamento_usuario_categoria_mes
    ON lancamento_financeiro (usuario_id, categoria_id, mes_competencia);

CREATE INDEX idx_lancamento_usuario_cartao_mes
    ON lancamento_financeiro (usuario_id, cartao_id, mes_competencia)
    WHERE cartao_id IS NOT NULL;

CREATE INDEX idx_lancamento_usuario_conta_data
    ON lancamento_financeiro (usuario_id, conta_id, data_lancamento DESC)
    WHERE conta_id IS NOT NULL;

CREATE INDEX idx_lancamento_usuario_fatura
    ON lancamento_financeiro (usuario_id, fatura_cartao_id)
    WHERE fatura_cartao_id IS NOT NULL;

CREATE TABLE anexo_lancamento (
    id TEXT PRIMARY KEY,
    usuario_id TEXT NOT NULL,
    lancamento_id TEXT NOT NULL,
    nome_arquivo TEXT NOT NULL,
    mime_type TEXT,
    tamanho_bytes INTEGER CHECK (tamanho_bytes IS NULL OR tamanho_bytes >= 0),
    storage_key TEXT NOT NULL,
    criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (lancamento_id, usuario_id) REFERENCES lancamento_financeiro(id, usuario_id) ON DELETE CASCADE,
    CHECK (length(trim(nome_arquivo)) > 0),
    CHECK (length(trim(storage_key)) > 0)
);

CREATE INDEX idx_anexo_lancamento_usuario_lancamento
    ON anexo_lancamento (usuario_id, lancamento_id);

-- ============================================================
-- Views para dashboard multiusuário
-- ============================================================

CREATE VIEW vw_lancamento_resultado AS
SELECT
    l.*,
    CASE
        WHEN l.tipo = 'RECEITA' THEN l.valor_centavos
        WHEN l.tipo = 'DESPESA' THEN -l.valor_centavos
        ELSE 0
    END AS impacto_resultado_centavos,
    CASE
        WHEN l.tipo = 'DESPESA' THEN l.valor_centavos
        ELSE 0
    END AS despesa_centavos,
    CASE
        WHEN l.tipo = 'RECEITA' THEN l.valor_centavos
        ELSE 0
    END AS receita_centavos,
    CASE
        WHEN l.tipo = 'PAGAMENTO_CARTAO' THEN l.valor_centavos
        ELSE 0
    END AS pagamento_cartao_centavos,
    CASE
        WHEN l.tipo = 'TRANSFERENCIA' THEN l.valor_centavos
        ELSE 0
    END AS transferencia_centavos
FROM lancamento_financeiro l;

CREATE VIEW vw_resumo_mensal AS
SELECT
    usuario_id,
    mes_competencia,
    SUM(CASE WHEN status = 'CONFIRMADO' THEN receita_centavos ELSE 0 END) AS receitas_confirmadas_centavos,
    SUM(CASE WHEN status = 'CONFIRMADO' THEN despesa_centavos ELSE 0 END) AS despesas_confirmadas_centavos,
    SUM(CASE WHEN status = 'CONFIRMADO' THEN pagamento_cartao_centavos ELSE 0 END) AS pagamentos_cartao_confirmados_centavos,
    SUM(CASE WHEN status = 'CONFIRMADO' THEN transferencia_centavos ELSE 0 END) AS transferencias_confirmadas_centavos,
    SUM(CASE WHEN status = 'PREVISTO' THEN receita_centavos ELSE 0 END) AS receitas_previstas_centavos,
    SUM(CASE WHEN status = 'PREVISTO' THEN despesa_centavos ELSE 0 END) AS despesas_previstas_centavos,
    SUM(CASE WHEN status = 'CONFIRMADO' THEN impacto_resultado_centavos ELSE 0 END) AS resultado_confirmado_centavos,
    SUM(CASE WHEN status IN ('CONFIRMADO', 'PREVISTO') THEN impacto_resultado_centavos ELSE 0 END) AS resultado_projetado_centavos
FROM vw_lancamento_resultado
WHERE status <> 'CANCELADO'
GROUP BY usuario_id, mes_competencia;

CREATE VIEW vw_despesas_por_categoria AS
SELECT
    l.usuario_id,
    l.mes_competencia,
    c.id AS categoria_id,
    c.nome AS categoria_nome,
    SUM(l.valor_centavos) AS total_centavos,
    COUNT(*) AS quantidade_lancamentos
FROM lancamento_financeiro l
JOIN categoria c
    ON c.id = l.categoria_id
   AND c.usuario_id = l.usuario_id
WHERE l.tipo = 'DESPESA'
  AND l.status = 'CONFIRMADO'
GROUP BY l.usuario_id, l.mes_competencia, c.id, c.nome;

CREATE VIEW vw_despesas_por_cartao AS
SELECT
    l.usuario_id,
    l.mes_competencia,
    cc.id AS cartao_id,
    cc.nome AS cartao_nome,
    SUM(l.valor_centavos) AS total_centavos,
    COUNT(*) AS quantidade_lancamentos
FROM lancamento_financeiro l
JOIN cartao_credito cc
    ON cc.id = l.cartao_id
   AND cc.usuario_id = l.usuario_id
WHERE l.tipo = 'DESPESA'
  AND l.status = 'CONFIRMADO'
  AND l.cartao_id IS NOT NULL
GROUP BY l.usuario_id, l.mes_competencia, cc.id, cc.nome;

CREATE VIEW vw_top5_despesas_mensais AS
SELECT
    usuario_id,
    mes_competencia,
    lancamento_id,
    data_lancamento,
    descricao,
    categoria_id,
    categoria_nome,
    valor_centavos,
    posicao
FROM (
    SELECT
        l.usuario_id,
        l.mes_competencia,
        l.id AS lancamento_id,
        l.data_lancamento,
        l.descricao,
        c.id AS categoria_id,
        c.nome AS categoria_nome,
        l.valor_centavos,
        ROW_NUMBER() OVER (
            PARTITION BY l.usuario_id, l.mes_competencia
            ORDER BY l.valor_centavos DESC, l.data_lancamento DESC, l.id
        ) AS posicao
    FROM lancamento_financeiro l
    LEFT JOIN categoria c
        ON c.id = l.categoria_id
       AND c.usuario_id = l.usuario_id
    WHERE l.tipo = 'DESPESA'
      AND l.status = 'CONFIRMADO'
) ranked
WHERE posicao <= 5;
