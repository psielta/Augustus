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
public class ReenviarVerificacaoInput implements SerializationVisibility {

    @NotBlank
    @Email
    @Size(max = 254)
    @Schema(description = "Email que deve receber novo link de verificacao", example = "maria@example.com")
    private String email;

}
