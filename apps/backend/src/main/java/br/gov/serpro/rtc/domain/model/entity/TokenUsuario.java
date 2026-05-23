package br.gov.serpro.rtc.domain.model.entity;

import java.time.Instant;

import br.gov.serpro.rtc.domain.model.converter.InstantTextConverter;
import br.gov.serpro.rtc.domain.model.enumeration.TipoToken;
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
@Table(name = "token_usuario")
public class TokenUsuario {

    @EqualsAndHashCode.Include
    @Id
    @Column(name = "id")
    private String id;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false)
    private TipoToken tipo;

    @Column(name = "token_hash", nullable = false)
    private String tokenHash;

    @Column(name = "destino_email")
    private String destinoEmail;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "expira_em", nullable = false)
    private Instant expiraEm;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "usado_em")
    private Instant usadoEm;

}
