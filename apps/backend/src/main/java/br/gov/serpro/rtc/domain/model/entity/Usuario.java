package br.gov.serpro.rtc.domain.model.entity;

import java.time.Instant;

import br.gov.serpro.rtc.domain.model.converter.InstantTextConverter;
import br.gov.serpro.rtc.domain.model.enumeration.PapelSistema;
import br.gov.serpro.rtc.domain.model.enumeration.StatusUsuario;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Data
@Entity
@Table(name = "usuario")
public class Usuario {

    @EqualsAndHashCode.Include
    @Id
    @Column(name = "id")
    private String id;

    @Column(name = "nome", nullable = false)
    private String nome;

    @Column(name = "email", nullable = false)
    private String email;

    @Column(name = "email_normalizado", nullable = false)
    private String emailNormalizado;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private StatusUsuario status;

    @Enumerated(EnumType.STRING)
    @Column(name = "papel_sistema", nullable = false)
    private PapelSistema papelSistema;

    @Column(name = "email_verificado", nullable = false)
    private Boolean emailVerificado;

    @Column(name = "moeda_padrao", nullable = false)
    private String moedaPadrao;

    @Column(name = "timezone", nullable = false)
    private String timezone;

    @Column(name = "locale", nullable = false)
    private String locale;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "ultimo_login_em")
    private Instant ultimoLoginEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "atualizado_em", nullable = false)
    private Instant atualizadoEm;

}
