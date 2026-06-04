CREATE TABLE usuario (
    id VARCHAR(36) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(320) NOT NULL,
    email_normalizado VARCHAR(320) NOT NULL,
    status VARCHAR(40) NOT NULL DEFAULT 'ATIVO'
        CHECK (status IN ('ATIVO', 'PENDENTE_VERIFICACAO', 'BLOQUEADO', 'DESATIVADO')),
    papel_sistema VARCHAR(40) NOT NULL DEFAULT 'USUARIO'
        CHECK (papel_sistema IN ('USUARIO', 'ADMIN')),
    email_verificado TINYINT(1) NOT NULL DEFAULT 0,
    moeda_padrao CHAR(3) NOT NULL DEFAULT 'BRL',
    timezone VARCHAR(64) NOT NULL DEFAULT 'America/Sao_Paulo',
    locale VARCHAR(10) NOT NULL DEFAULT 'pt-BR',
    ultimo_login_em DATETIME(6) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

    CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
    CHECK (CHAR_LENGTH(TRIM(email)) > 0),
    CHECK (CHAR_LENGTH(TRIM(email_normalizado)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX ux_usuario_email_normalizado
    ON usuario (email_normalizado);

CREATE INDEX idx_usuario_status
    ON usuario (status);

CREATE TABLE usuario_credencial (
    usuario_id VARCHAR(36) PRIMARY KEY,
    senha_hash VARCHAR(72) NOT NULL,
    algoritmo_hash VARCHAR(40) NOT NULL DEFAULT 'BCRYPT',
    senha_alterada_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    deve_alterar_senha TINYINT(1) NOT NULL DEFAULT 0,
    tentativas_login_falhas INT NOT NULL DEFAULT 0 CHECK (tentativas_login_falhas >= 0),
    bloqueado_ate DATETIME(6) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sessao_usuario (
    id VARCHAR(36) PRIMARY KEY,
    usuario_id VARCHAR(36) NOT NULL,
    refresh_token_hash CHAR(64) NOT NULL,
    dispositivo_nome VARCHAR(255) NULL,
    user_agent VARCHAR(512) NULL,
    ip_criacao VARCHAR(45) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ultimo_uso_em DATETIME(6) NULL,
    expira_em DATETIME(6) NOT NULL,
    revogado_em DATETIME(6) NULL,
    motivo_revogacao VARCHAR(40) NULL,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX ux_sessao_usuario_refresh_token_hash
    ON sessao_usuario (refresh_token_hash);

CREATE INDEX idx_sessao_usuario_usuario_ativa
    ON sessao_usuario (usuario_id, expira_em, revogado_em);

CREATE TABLE token_usuario (
    id VARCHAR(36) PRIMARY KEY,
    usuario_id VARCHAR(36) NOT NULL,
    tipo VARCHAR(40) NOT NULL
        CHECK (tipo IN ('VERIFICACAO_EMAIL', 'RESET_SENHA', 'ALTERACAO_EMAIL')),
    token_hash CHAR(64) NOT NULL,
    destino_email VARCHAR(320) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    expira_em DATETIME(6) NOT NULL,
    usado_em DATETIME(6) NULL,

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX ux_token_usuario_hash
    ON token_usuario (token_hash);

CREATE INDEX idx_token_usuario_usuario_tipo
    ON token_usuario (usuario_id, tipo, expira_em, usado_em);

CREATE TABLE login_auditoria (
    id VARCHAR(36) PRIMARY KEY,
    usuario_id VARCHAR(36) NULL,
    email_informado VARCHAR(320) NULL,
    sucesso TINYINT(1) NOT NULL CHECK (sucesso IN (0, 1)),
    motivo VARCHAR(255) NULL,
    ip VARCHAR(45) NULL,
    user_agent VARCHAR(512) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_login_auditoria_usuario_data
    ON login_auditoria (usuario_id, criado_em);

CREATE INDEX idx_login_auditoria_email_data
    ON login_auditoria (email_informado, criado_em);
