package br.com.augustus.backend.api.model.output.categoria;

import java.time.Instant;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

import br.com.augustus.backend.api.model.SerializationVisibility;
import br.com.augustus.backend.domain.model.enumeration.TipoCategoria;
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
public class CategoriaOutput implements SerializationVisibility {

    @Schema(example = "87d62df4-c564-4c44-b091-81048a9189c0")
    private String id;

    @Schema(example = "Alimentação")
    private String nome;

    @Schema(example = "DESPESA")
    private TipoCategoria tipo;

    @Schema(example = "87d62df4-c564-4c44-b091-81048a9189c0")
    private String categoriaPaiId;

    @Schema(example = "#22AA55")
    private String corHex;

    @Schema(example = "fas fa-utensils")
    private String icone;

    @Schema(example = "10")
    private Integer ordem;

    @Schema(example = "true")
    private Boolean ativo;

    @Schema(example = "false")
    private Boolean criadaPorTemplate;

    @Schema(example = "despesa_alimentacao")
    private String templateCodigo;

    @Schema(example = "2026-05-23T12:00:00Z")
    private Instant criadoEm;

    @Schema(example = "2026-05-23T12:00:00Z")
    private Instant atualizadoEm;

}