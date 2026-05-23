package br.gov.serpro.rtc.api.openapi.controller;

import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;
import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON_VALUE;
import static org.springframework.http.MediaType.TEXT_PLAIN_VALUE;

import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;

import br.gov.serpro.rtc.api.model.input.auth.LoginInput;
import br.gov.serpro.rtc.api.model.input.auth.ReenviarVerificacaoInput;
import br.gov.serpro.rtc.api.model.input.auth.RefreshInput;
import br.gov.serpro.rtc.api.model.input.auth.RegistrarUsuarioInput;
import br.gov.serpro.rtc.api.model.input.auth.VerificarEmailInput;
import br.gov.serpro.rtc.api.model.output.auth.RegistroOutput;
import br.gov.serpro.rtc.api.model.output.auth.TokenPairOutput;
import br.gov.serpro.rtc.api.model.output.auth.UsuarioOutput;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@Tag(name = "Autenticacao Augustus", description = "Cadastro, login, refresh token e verificacao de email")
public interface AutenticacaoControllerOpenApi {

    @Operation(summary = "Registrar usuario", description = "Cria usuario pendente e envia email de verificacao.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Cadastro criado", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = RegistroOutput.class))),
        @ApiResponse(responseCode = "400", description = "Dados invalidos", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "409", description = "Email ja cadastrado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "502", description = "Falha no envio de email", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<RegistroOutput> registrar(@Valid RegistrarUsuarioInput input);

    @Operation(summary = "Login", description = "Retorna access token e refresh token para usuario com email verificado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Login realizado", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = TokenPairOutput.class))),
        @ApiResponse(responseCode = "401", description = "Credenciais invalidas", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "403", description = "Email nao verificado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "423", description = "Usuario bloqueado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<TokenPairOutput> login(@Valid LoginInput input, HttpServletRequest request);

    @Operation(summary = "Rotacionar refresh token", description = "Revoga a sessao antiga e cria uma nova sessao.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Tokens renovados", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = TokenPairOutput.class))),
        @ApiResponse(responseCode = "401", description = "Refresh token invalido", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<TokenPairOutput> refresh(@Valid RefreshInput input, HttpServletRequest request);

    @Operation(summary = "Logout", description = "Revoga apenas a sessao do access token atual.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Sessao revogada"),
        @ApiResponse(responseCode = "401", description = "Access token ausente ou invalido", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<Void> logout();

    @Operation(summary = "Usuario autenticado", description = "Retorna os dados basicos do usuario autenticado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario autenticado", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = UsuarioOutput.class))),
        @ApiResponse(responseCode = "401", description = "Access token ausente ou invalido", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<UsuarioOutput> me();

    @Operation(summary = "Verificar email", description = "Valida o token recebido por email via JSON.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Email verificado"),
        @ApiResponse(responseCode = "400", description = "Token invalido", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<Void> verificarEmail(@Valid VerificarEmailInput input);

    @Operation(summary = "Verificar email por link", description = "Alias para o link clicavel enviado por email.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Email verificado", content = @Content(mediaType = TEXT_PLAIN_VALUE,
            examples = @ExampleObject(value = "Email verificado com sucesso. Voce ja pode fazer login."))),
        @ApiResponse(responseCode = "400", description = "Token invalido", content = @Content(mediaType = TEXT_PLAIN_VALUE,
            examples = @ExampleObject(value = "Token invalido, expirado ou ja utilizado.")))
    })
    ResponseEntity<String> verificarEmailPorLink(String token);

    @Operation(summary = "Reenviar verificacao", description = "Reenvia verificacao sem vazar se o email existe.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Solicitacao processada")
    })
    ResponseEntity<Void> reenviarVerificacao(@Valid ReenviarVerificacaoInput input);

}
