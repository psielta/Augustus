package br.gov.serpro.rtc.domain.model.entity;

import java.time.Instant;

import br.gov.serpro.rtc.domain.model.converter.InstantTextConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
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

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "senha_alterada_em", nullable = false)
    private Instant senhaAlteradaEm;

    @Column(name = "deve_alterar_senha", nullable = false)
    private Boolean deveAlterarSenha;

    @Column(name = "tentativas_login_falhas", nullable = false)
    private Integer tentativasLoginFalhas;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "bloqueado_ate")
    private Instant bloqueadoAte;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "atualizado_em", nullable = false)
    private Instant atualizadoEm;

}
