CREATE TABLE categoria_template (
    codigo VARCHAR(60) PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    tipo VARCHAR(40) NOT NULL
        CHECK (tipo IN ('DESPESA', 'RECEITA', 'PAGAMENTO_CARTAO', 'TRANSFERENCIA')),
    cor_hex VARCHAR(7) NULL,
    icone VARCHAR(60) NULL,
    ordem INT NOT NULL DEFAULT 0,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CHECK (CHAR_LENGTH(TRIM(nome)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX ux_categoria_template_nome_tipo
    ON categoria_template (nome, tipo);

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

CREATE TABLE categoria (
    id VARCHAR(36) PRIMARY KEY,
    usuario_id VARCHAR(36) NOT NULL,
    categoria_pai_id VARCHAR(36) NULL,
    nome VARCHAR(80) NOT NULL,
    tipo VARCHAR(40) NOT NULL
        CHECK (tipo IN ('DESPESA', 'RECEITA', 'PAGAMENTO_CARTAO', 'TRANSFERENCIA')),
    cor_hex VARCHAR(7) NULL,
    icone VARCHAR(60) NULL,
    ordem INT NOT NULL DEFAULT 0,
    criada_por_template TINYINT(1) NOT NULL DEFAULT 0,
    template_codigo VARCHAR(60) NULL,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT uq_categoria_id_usuario UNIQUE (id, usuario_id),
    CHECK (CHAR_LENGTH(TRIM(nome)) > 0),

    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (template_codigo) REFERENCES categoria_template(codigo) ON DELETE SET NULL,
    FOREIGN KEY (categoria_pai_id, usuario_id) REFERENCES categoria(id, usuario_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX ux_categoria_usuario_nome_tipo
    ON categoria (usuario_id, nome, tipo);

CREATE INDEX idx_categoria_usuario_tipo_ativa
    ON categoria (usuario_id, tipo, ativo);

CREATE INDEX idx_categoria_usuario_template
    ON categoria (usuario_id, template_codigo);

CREATE INDEX idx_categoria_pai
    ON categoria (categoria_pai_id, usuario_id);