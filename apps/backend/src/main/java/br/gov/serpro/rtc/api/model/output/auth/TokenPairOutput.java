package br.gov.serpro.rtc.api.model.output.auth;

import java.time.Instant;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

import br.gov.serpro.rtc.api.model.SerializationVisibility;
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
public class TokenPairOutput implements SerializationVisibility {

    @Schema(description = "JWT HS256 para chamadas autenticadas")
    private String accessToken;

    @Schema(description = "Refresh token opaco, exibido uma unica vez")
    private String refreshToken;

    @Schema(example = "2026-05-23T12:15:00Z")
    private Instant accessTokenExpiraEm;

    @Schema(example = "2026-06-22T12:00:00Z")
    private Instant refreshTokenExpiraEm;

    @Builder.Default
    @Schema(example = "Bearer")
    private String tokenType = "Bearer";

}
