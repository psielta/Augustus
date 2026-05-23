package br.gov.serpro.rtc.api.model.output.auth;

import java.time.Instant;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

import br.gov.serpro.rtc.api.model.SerializationVisibility;
import br.gov.serpro.rtc.domain.model.enumeration.PapelSistema;
import br.gov.serpro.rtc.domain.model.enumeration.StatusUsuario;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(Include.NON_NULL)
public class UsuarioOutput implements SerializationVisibility {

    @Schema(example = "87d62df4-c564-4c44-b091-81048a9189c0")
    private String id;

    @Schema(example = "Maria Silva")
    private String nome;

    @Schema(example = "maria@example.com")
    private String email;

    @Schema(example = "ATIVO")
    private StatusUsuario status;

    @Schema(example = "USUARIO")
    private PapelSistema papelSistema;

    @Schema(example = "true")
    private Boolean emailVerificado;

    @Schema(example = "2026-05-23T12:00:00Z")
    private Instant criadoEm;

}
