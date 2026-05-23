-- =====================================================
-- MIGRACAO DE MANUTENCAO
-- Data: 2026-05-23
-- Autor: Augustus
-- =====================================================

INSERT INTO VERSAO_BASE_DADO (VRBD_DATA, VRBD_VERSAO_BASE_DADO, VRBD_DESCRICAO) VALUES
(
    datetime('2026-05-23'),
    'V0030',
    'Augustus - autenticacao, usuarios, sessoes e tokens de verificacao.'
);

PRAGMA foreign_keys = ON;

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
