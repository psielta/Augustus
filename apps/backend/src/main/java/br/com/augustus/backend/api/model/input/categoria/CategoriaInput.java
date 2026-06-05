package br.com.augustus.backend.api.model.input.categoria;

import br.com.augustus.backend.api.model.SerializationVisibility;
import br.com.augustus.backend.domain.model.enumeration.TipoCategoria;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
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
public class CategoriaInput implements SerializationVisibility {

    @NotBlank
    @Size(max = 80)
    @Schema(example = "Alimentação")
    private String nome;

    @NotNull
    @Schema(example = "DESPESA")
    private TipoCategoria tipo;

    @Size(max = 36)
    @Schema(example = "87d62df4-c564-4c44-b091-81048a9189c0")
    private String categoriaPaiId;

    @Size(max = 7)
    @Pattern(regexp = "^#?[0-9A-Fa-f]{6}$")
    @Schema(example = "#22AA55")
    private String corHex;

    @Size(max = 60)
    @Schema(example = "fas fa-utensils")
    private String icone;

    @PositiveOrZero
    @Schema(example = "10")
    private Integer ordem;

    @Schema(example = "true")
    private Boolean ativo;

}