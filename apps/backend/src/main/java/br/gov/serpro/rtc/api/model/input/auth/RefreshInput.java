package br.gov.serpro.rtc.api.model.input.auth;

import br.gov.serpro.rtc.api.model.SerializationVisibility;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class RefreshInput implements SerializationVisibility {

    @NotBlank
    @Schema(description = "Refresh token opaco retornado no login", example = "2j7qkpuuZXp6H9-Hc88wjT9Vg3ECQn4KckuqaV7aHyY")
    private String refreshToken;

}
