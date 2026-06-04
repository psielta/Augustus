package br.com.augustus.backend.api.model.output.auth;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

import br.com.augustus.backend.api.model.SerializationVisibility;
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
public class RegistroOutput implements SerializationVisibility {

    @Schema(description = "Usuario criado ainda pendente de verificacao")
    private UsuarioOutput usuario;

    @Schema(example = "Cadastro criado. Verifique seu email para liberar o login.")
    private String mensagem;

}
