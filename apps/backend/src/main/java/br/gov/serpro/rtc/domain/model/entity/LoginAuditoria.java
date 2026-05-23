package br.gov.serpro.rtc.domain.model.entity;

import java.time.Instant;

import br.gov.serpro.rtc.domain.model.converter.InstantTextConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Data
@Entity
@Table(name = "login_auditoria")
public class LoginAuditoria {

    @EqualsAndHashCode.Include
    @Id
    @Column(name = "id")
    private String id;

    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @Column(name = "email_informado")
    private String emailInformado;

    @Column(name = "sucesso", nullable = false)
    private Boolean sucesso;

    @Column(name = "motivo")
    private String motivo;

    @Column(name = "ip")
    private String ip;

    @Column(name = "user_agent")
    private String userAgent;

    @Convert(converter = InstantTextConverter.class)
    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

}
