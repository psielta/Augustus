package br.com.augustus.backend.domain.model.entity;

import java.time.Instant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Data
@Entity
@Table(name = "usuario_credencial")
public class UsuarioCredencial {

    @EqualsAndHashCode.Include
    @Id
    @Column(name = "usuario_id")
    private String usuarioId;

    @Column(name = "senha_hash", nullable = false)
    private String senhaHash;

    @Column(name = "algoritmo_hash", nullable = false)
    private String algoritmoHash;

    @Column(name = "senha_alterada_em", nullable = false)
    private Instant senhaAlteradaEm;

    @Column(name = "deve_alterar_senha", nullable = false)
    private Boolean deveAlterarSenha;

    @Column(name = "tentativas_login_falhas", nullable = false)
    private Integer tentativasLoginFalhas;

    @Column(name = "bloqueado_ate")
    private Instant bloqueadoAte;

    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

    @Column(name = "atualizado_em", nullable = false)
    private Instant atualizadoEm;

}
