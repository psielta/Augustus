package br.gov.serpro.rtc.api.model.input.auth;

import br.gov.serpro.rtc.api.model.SerializationVisibility;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class RegistrarUsuarioInput implements SerializationVisibility {

    @NotBlank
    @Size(max = 120)
    @Schema(description = "Nome do usuario", example = "Maria Silva")
    private String nome;

    @NotBlank
    @Email
    @Size(max = 254)
    @Schema(description = "Email usado para login", example = "maria@example.com")
    private String email;

    @NotBlank
    @Size(min = 8, max = 128)
    @Schema(description = "Senha com pelo menos 8 caracteres", example = "senha-forte-123")
    private String senha;

}
