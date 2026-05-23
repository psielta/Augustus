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
public class LoginInput implements SerializationVisibility {

    @NotBlank
    @Email
    @Size(max = 254)
    @Schema(description = "Email usado no cadastro", example = "maria@example.com")
    private String email;

    @NotBlank
    @Size(min = 8, max = 128)
    @Schema(description = "Senha do usuario", example = "senha-forte-123")
    private String senha;

}
