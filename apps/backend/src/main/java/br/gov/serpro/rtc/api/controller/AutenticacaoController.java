package br.gov.serpro.rtc.api.controller;

import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;
import static org.springframework.http.MediaType.TEXT_PLAIN_VALUE;

import java.nio.charset.StandardCharsets;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import br.gov.serpro.rtc.api.model.input.auth.LoginInput;
import br.gov.serpro.rtc.api.model.input.auth.ReenviarVerificacaoInput;
import br.gov.serpro.rtc.api.model.input.auth.RefreshInput;
import br.gov.serpro.rtc.api.model.input.auth.RegistrarUsuarioInput;
import br.gov.serpro.rtc.api.model.input.auth.VerificarEmailInput;
import br.gov.serpro.rtc.api.model.output.auth.RegistroOutput;
import br.gov.serpro.rtc.api.model.output.auth.TokenPairOutput;
import br.gov.serpro.rtc.api.model.output.auth.UsuarioOutput;
import br.gov.serpro.rtc.api.openapi.controller.AutenticacaoControllerOpenApi;
import br.gov.serpro.rtc.domain.service.auth.AutenticacaoService;
import br.gov.serpro.rtc.domain.service.auth.AutenticadoUsuarioResolver;
import br.gov.serpro.rtc.domain.service.exception.TokenVerificacaoInvalidoException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/auth", produces = APPLICATION_JSON_VALUE)
public class AutenticacaoController implements AutenticacaoControllerOpenApi {

    private static final MediaType TEXT_PLAIN_UTF8 = new MediaType("text", "plain", StandardCharsets.UTF_8);

    private final AutenticacaoService autenticacaoService;
    private final AutenticadoUsuarioResolver autenticadoUsuarioResolver;

    @Override
    @PostMapping(value = "/register", consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<RegistroOutput> registrar(@RequestBody @Valid RegistrarUsuarioInput input) {
        return ResponseEntity.status(HttpStatus.CREATED).body(autenticacaoService.registrar(input));
    }

    @Override
    @PostMapping(value = "/login", consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenPairOutput> login(@RequestBody @Valid LoginInput input, HttpServletRequest request) {
        return ResponseEntity.ok(autenticacaoService.login(input, userAgent(request), ip(request)));
    }

    @Override
    @PostMapping(value = "/refresh", consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<TokenPairOutput> refresh(@RequestBody @Valid RefreshInput input, HttpServletRequest request) {
        return ResponseEntity.ok(autenticacaoService.refresh(input, userAgent(request), ip(request)));
    }

    @Override
    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        autenticacaoService.logout(autenticadoUsuarioResolver.usuarioIdAtual(), autenticadoUsuarioResolver.sessaoIdAtual());
        return ResponseEntity.noContent().build();
    }

    @Override
    @GetMapping("/me")
    public ResponseEntity<UsuarioOutput> me() {
        return ResponseEntity.ok(autenticacaoService.me(autenticadoUsuarioResolver.usuarioAtual()));
    }

    @Override
    @PostMapping(value = "/verify-email", consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> verificarEmail(@RequestBody @Valid VerificarEmailInput input) {
        autenticacaoService.verificarEmail(input);
        return ResponseEntity.noContent().build();
    }

    @Override
    @GetMapping(value = "/verify-email", produces = TEXT_PLAIN_VALUE)
    public ResponseEntity<String> verificarEmailPorLink(@RequestParam String token) {
        try {
            autenticacaoService.verificarEmail(token);
            return ResponseEntity.ok()
                    .contentType(TEXT_PLAIN_UTF8)
                    .body("Email verificado com sucesso. Voce ja pode fazer login.");
        } catch (TokenVerificacaoInvalidoException ex) {
            return ResponseEntity.badRequest()
                    .contentType(TEXT_PLAIN_UTF8)
                    .body("Token invalido, expirado ou ja utilizado.");
        }
    }

    @Override
    @PostMapping(value = "/resend-verification", consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> reenviarVerificacao(@RequestBody @Valid ReenviarVerificacaoInput input) {
        autenticacaoService.reenviarVerificacao(input);
        return ResponseEntity.noContent().build();
    }

    private String userAgent(HttpServletRequest request) {
        return request.getHeader("User-Agent");
    }

    private String ip(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",", 2)[0].trim();
        }
        return request.getRemoteAddr();
    }

}
