package br.com.augustus.backend.api.model.output.categoria;

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
public class CategoriaTemplateOutput implements SerializationVisibility {

    @Schema(example = "despesa_alimentacao")
    private String codigo;

    @Schema(example = "Alimentação")
    private String nome;

    @Schema(example = "DESPESA")
    private TipoCategoria tipo;

    @Schema(example = "#22AA55")
    private String corHex;

    @Schema(example = "fas fa-utensils")
    private String icone;

    @Schema(example = "10")
    private Integer ordem;

}