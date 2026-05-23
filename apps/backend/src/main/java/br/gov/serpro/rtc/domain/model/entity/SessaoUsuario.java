package br.gov.serpro.rtc.domain.model.entity;

import java.time.Instant;

import br.gov.serpro.rtc.domain.model.converter.InstantTextConverter;
import br.gov.serpro.rtc.domain.model.enumeration.MotivoRevogacaoSessao;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Data
@Entity
@Table(name = "sessao_usuario")
public class SessaoUsuario {

    @EqualsAndHashCode.Include
    @Id
    @Column(name = "id")
    private String id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "refresh_token_hash", nullable = false)
    private String refreshTokenHash;

    @Column(name = "dispositivo_nome")
    private String dispositivoNome;

    @Column(name = "user_agent")
    private String userAgent;

    @Column(name = "ip_criacao")
    private String ipCriacao;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "ultimo_uso_em")
    private Instant ultimoUsoEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "expira_em", nullable = false)
    private Instant expiraEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "revogado_em")
    private Instant revogadoEm;

    @Enumerated(EnumType.STRING)
    @Column(name = "motivo_revogacao")
    private MotivoRevogacaoSessao motivoRevogacao;

}
