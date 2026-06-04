package br.com.augustus.backend.testesintegracao.auth;

import static org.hamcrest.Matchers.containsString;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.http.HttpHeaders.AUTHORIZATION;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.com.augustus.backend.domain.model.entity.SessaoUsuario;
import br.com.augustus.backend.domain.model.entity.TokenUsuario;
import br.com.augustus.backend.domain.repository.LoginAuditoriaRepository;
import br.com.augustus.backend.domain.repository.SessaoUsuarioRepository;
import br.com.augustus.backend.domain.repository.TokenUsuarioRepository;
import br.com.augustus.backend.domain.repository.UsuarioCredencialRepository;
import br.com.augustus.backend.domain.repository.UsuarioRepository;
import br.com.augustus.backend.domain.service.auth.EmailService;
import br.com.augustus.backend.domain.service.auth.JwtTokenService;
import br.com.augustus.backend.domain.service.auth.RefreshTokenService;

class Teste_Autenticacao_Controller extends br.com.augustus.backend.testesintegracao.AbstractIntegrationTest {

    private static final AtomicInteger EMAIL_COUNTER = new AtomicInteger();
    private static final int USER_AGENT_MAX_LENGTH = 512;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private UsuarioCredencialRepository usuarioCredencialRepository;

    @Autowired
    private SessaoUsuarioRepository sessaoUsuarioRepository;

    @Autowired
    private TokenUsuarioRepository tokenUsuarioRepository;

    @Autowired
    private LoginAuditoriaRepository loginAuditoriaRepository;

    @Autowired
    private RefreshTokenService refreshTokenService;

    @Autowired
    private JwtTokenService jwtTokenService;

    @MockitoBean
    private EmailService emailService;

    @BeforeEach
    void setUp() {
        limparTabelasAuth();
        reset(emailService);
    }

    private void limparTabelasAuth() {
        loginAuditoriaRepository.deleteAllInBatch();
        tokenUsuarioRepository.deleteAllInBatch();
        sessaoUsuarioRepository.deleteAllInBatch();
        usuarioCredencialRepository.deleteAllInBatch();
        usuarioRepository.deleteAllInBatch();
    }

    @Nested
    class Register {

        @Test
        void comSucesso_retorna201_criaUsuarioPendente_disparaEmail() throws Exception {
            String email = novoEmail();

            mockMvc.perform(postJson("/auth/register", AuthFixtures.registro(email)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.usuario.email").value(email))
                    .andExpect(jsonPath("$.usuario.status").value("PENDENTE_VERIFICACAO"))
                    .andExpect(jsonPath("$.usuario.emailVerificado").value(false))
                    .andExpect(jsonPath("$.usuario.senhaHash").doesNotExist())
                    .andExpect(jsonPath("$.accessToken").doesNotExist());

            verify(emailService, times(1)).enviarVerificacao(anyString(), anyString());
            var usuario = usuarioRepository.findByEmailNormalizado(email).orElseThrow();
            var credencial = usuarioCredencialRepository.findById(usuario.getId()).orElseThrow();
            org.assertj.core.api.Assertions.assertThat(credencial.getSenhaHash()).startsWith("$2");
        }

        @Test
        void comEmailDuplicado_retorna409() throws Exception {
            String email = novoEmail();
            cadastrar(email);

            mockMvc.perform(postJson("/auth/register", AuthFixtures.registro(email)))
                    .andExpect(status().isConflict())
                    .andExpect(jsonPath("$.detail", containsString("EMAIL_JA_CADASTRADO")));
        }

        @Test
        void validacoesInvalidas_retornam400() throws Exception {
            mockMvc.perform(postJson("/auth/register", Map.of("nome", "A", "email", "email-invalido", "senha", "12345678")))
                    .andExpect(status().isBadRequest());

            mockMvc.perform(postJson("/auth/register", Map.of("nome", "A", "email", novoEmail(), "senha", "123")))
                    .andExpect(status().isBadRequest());
        }

        @Test
        void emailEhCaseInsensitiveENaoCriaDuplicata() throws Exception {
            String email = novoEmail();
            cadastrar(email.toUpperCase());

            mockMvc.perform(postJson("/auth/register", AuthFixtures.registro(email.toLowerCase())))
                    .andExpect(status().isConflict());
        }
    }

    @Nested
    class Login {

        @Test
        void comEmailNaoVerificado_retorna403() throws Exception {
            String email = novoEmail();
            cadastrar(email);

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email)))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.detail", containsString("EMAIL_NAO_VERIFICADO")));
        }

        @Test
        void comUsuarioVerificado_retorna200ComTokens() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.accessToken").isString())
                    .andExpect(jsonPath("$.refreshToken").isString())
                    .andExpect(jsonPath("$.tokenType").value("Bearer"))
                    .andExpect(jsonPath("$.refreshTokenHash").doesNotExist());
        }

        @Test
        void credenciaisInvalidas_retorna401() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email, "senha-errada")))
                    .andExpect(status().isUnauthorized());

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(novoEmail(), "senha-errada")))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        void aposCincoFalhasConsecutivas_retorna423NaTentativaSeguinte() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);

            for (int i = 0; i < 5; i++) {
                mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email, "senha-errada")))
                        .andExpect(status().isUnauthorized());
            }

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email)))
                    .andExpect(status().isLocked());
        }

        @Test
        void loginBemSucedidoZeraContadorFalhasEGravaAuditoria() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email, "senha-errada")))
                    .andExpect(status().isUnauthorized());

            long auditoriasAntes = loginAuditoriaRepository.count();
            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email)))
                    .andExpect(status().isOk());

            var usuario = usuarioRepository.findByEmailNormalizado(email).orElseThrow();
            var credencial = usuarioCredencialRepository.findById(usuario.getId()).orElseThrow();
            org.assertj.core.api.Assertions.assertThat(credencial.getTentativasLoginFalhas()).isZero();
            org.assertj.core.api.Assertions.assertThat(loginAuditoriaRepository.count()).isGreaterThan(auditoriasAntes);
        }

        @Test
        void loginUsaRemoteAddrENaoHeaderForwardedFor() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);

            MvcResult result = mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email))
                            .header("X-Forwarded-For", "203.0.113.10")
                            .with(request -> {
                                request.setRemoteAddr("10.0.0.5");
                                return request;
                            }))
                    .andExpect(status().isOk())
                    .andReturn();

            TokenPair tokens = tokens(result);
            SessaoUsuario sessao = sessaoUsuarioRepository
                    .findByRefreshTokenHashAndRevogadoEmIsNull(refreshTokenService.hashSha256(tokens.refreshToken()))
                    .orElseThrow();
            org.assertj.core.api.Assertions.assertThat(sessao.getIpCriacao()).isEqualTo("10.0.0.5");
            org.assertj.core.api.Assertions.assertThat(loginAuditoriaRepository.findAll().get(0).getIp()).isEqualTo("10.0.0.5");
        }

        @Test
        void loginLimitaUserAgentPersistidoAoTamanhoDoSchema() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);
            String userAgent = "Mozilla/5.0 ".repeat(80);

            MvcResult result = mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email))
                            .header("User-Agent", userAgent))
                    .andExpect(status().isOk())
                    .andReturn();

            TokenPair tokens = tokens(result);
            SessaoUsuario sessao = sessaoUsuarioRepository
                    .findByRefreshTokenHashAndRevogadoEmIsNull(refreshTokenService.hashSha256(tokens.refreshToken()))
                    .orElseThrow();
            String esperado = userAgent.substring(0, USER_AGENT_MAX_LENGTH);

            org.assertj.core.api.Assertions.assertThat(sessao.getUserAgent()).isEqualTo(esperado);
            org.assertj.core.api.Assertions.assertThat(loginAuditoriaRepository.findAll().get(0).getUserAgent()).isEqualTo(esperado);
        }
    }

    @Nested
    class Refresh {

        @Test
        void comTokenValido_retornaNovosTokens_revogaSessaoAntiga() throws Exception {
            String email = novoEmail();
            TokenPair tokens = cadastrarVerificarELogar(email);

            TokenPair novosTokens = refresh(tokens.refreshToken());

            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer(tokens.accessToken())))
                    .andExpect(status().isUnauthorized());
            mockMvc.perform(postJson("/auth/refresh", Map.of("refreshToken", tokens.refreshToken())))
                    .andExpect(status().isUnauthorized());
            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer(novosTokens.accessToken())))
                    .andExpect(status().isOk());
        }

        @Test
        void comTokenInexistenteOuExpirado_retorna401() throws Exception {
            mockMvc.perform(postJson("/auth/refresh", Map.of("refreshToken", "token-inexistente")))
                    .andExpect(status().isUnauthorized());

            String email = novoEmail();
            TokenPair tokens = cadastrarVerificarELogar(email);
            SessaoUsuario sessao = sessaoUsuarioRepository
                    .findByRefreshTokenHashAndRevogadoEmIsNull(refreshTokenService.hashSha256(tokens.refreshToken()))
                    .orElseThrow();
            sessao.setExpiraEm(Instant.now().minusSeconds(1));
            sessaoUsuarioRepository.save(sessao);

            mockMvc.perform(postJson("/auth/refresh", Map.of("refreshToken", tokens.refreshToken())))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    class LogoutEMe {

        @Test
        void meComTokenValidoESemToken() throws Exception {
            String email = novoEmail();
            TokenPair tokens = cadastrarVerificarELogar(email);

            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer(tokens.accessToken())))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.email").value(email));

            mockMvc.perform(get("/auth/me"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        void tokenMalformadoOuExpirado_retorna401() throws Exception {
            String email = novoEmail();
            TokenPair tokens = cadastrarVerificarELogar(email);
            SessaoUsuario sessao = sessaoUsuarioRepository
                    .findByRefreshTokenHashAndRevogadoEmIsNull(refreshTokenService.hashSha256(tokens.refreshToken()))
                    .orElseThrow();
            String expirado = jwtTokenService.gerarAccessToken(sessao.getUsuario().getId(), sessao.getId(),
                    Instant.now().minusSeconds(60), Instant.now().minusSeconds(1));

            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer("malformado")))
                    .andExpect(status().isUnauthorized());
            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer(expirado)))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        void logoutRevogaSessaoCorrenteMasNaoOutraSessao() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);
            TokenPair sessao1 = login(email);
            TokenPair sessao2 = login(email);

            mockMvc.perform(post("/auth/logout").header(AUTHORIZATION, bearer(sessao1.accessToken())))
                    .andExpect(status().isNoContent());

            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer(sessao1.accessToken())))
                    .andExpect(status().isUnauthorized());
            mockMvc.perform(get("/auth/me").header(AUTHORIZATION, bearer(sessao2.accessToken())))
                    .andExpect(status().isOk());
        }
    }

    @Nested
    class VerifyEmail {

        @Test
        void postComTokenValido_marcaVerificadoELoginPassa() throws Exception {
            String email = novoEmail();
            String token = cadastrar(email);

            mockMvc.perform(postJson("/auth/verify-email", Map.of("token", token)))
                    .andExpect(status().isNoContent());

            mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email)))
                    .andExpect(status().isOk());
        }

        @Test
        void postComTokenInvalidoExpiradoOuUsado_retorna400() throws Exception {
            mockMvc.perform(postJson("/auth/verify-email", Map.of("token", "invalido")))
                    .andExpect(status().isBadRequest());

            String emailExpirado = novoEmail();
            String tokenExpirado = cadastrar(emailExpirado);
            TokenUsuario tokenEntity = tokenUsuarioRepository
                    .findByTokenHashAndUsadoEmIsNull(refreshTokenService.hashSha256(tokenExpirado))
                    .orElseThrow();
            tokenEntity.setExpiraEm(Instant.now().minusSeconds(1));
            tokenUsuarioRepository.save(tokenEntity);

            mockMvc.perform(postJson("/auth/verify-email", Map.of("token", tokenExpirado)))
                    .andExpect(status().isBadRequest());

            String emailUsado = novoEmail();
            String tokenUsado = cadastrarEVerificar(emailUsado);
            mockMvc.perform(postJson("/auth/verify-email", Map.of("token", tokenUsado)))
                    .andExpect(status().isBadRequest());
        }

        @Test
        void getRetornaTextoPlainEmSucessoEErro() throws Exception {
            String email = novoEmail();
            String token = cadastrar(email);

            mockMvc.perform(get("/auth/verify-email").param("token", token))
                    .andExpect(status().isOk())
                    .andExpect(content().contentTypeCompatibleWith(MediaType.TEXT_PLAIN))
                    .andExpect(content().string("Email verificado com sucesso. Voce ja pode fazer login."));

            mockMvc.perform(get("/auth/verify-email").param("token", "invalido"))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentTypeCompatibleWith(MediaType.TEXT_PLAIN))
                    .andExpect(content().string("Token invalido, expirado ou ja utilizado."));
        }
    }

    @Nested
    class ResendVerification {

        @Test
        void usuarioPendente_invalidaTokensAntigos_criaNovo_retorna204() throws Exception {
            String email = novoEmail();
            String tokenAntigo = cadastrar(email);
            envelhecerToken(tokenAntigo, Duration.ofMinutes(10));
            reset(emailService);

            mockMvc.perform(postJson("/auth/resend-verification", Map.of("email", email)))
                    .andExpect(status().isNoContent());

            verify(emailService, times(1)).enviarVerificacao(anyString(), anyString());
            String tokenNovo = ultimoTokenEnviado();

            mockMvc.perform(postJson("/auth/verify-email", Map.of("token", tokenAntigo)))
                    .andExpect(status().isBadRequest());
            mockMvc.perform(postJson("/auth/verify-email", Map.of("token", tokenNovo)))
                    .andExpect(status().isNoContent());
        }

        @Test
        void emailJaVerificadoOuInexistente_retorna204SemEnviarEmail() throws Exception {
            String email = novoEmail();
            cadastrarEVerificar(email);
            reset(emailService);

            mockMvc.perform(postJson("/auth/resend-verification", Map.of("email", email)))
                    .andExpect(status().isNoContent());
            mockMvc.perform(postJson("/auth/resend-verification", Map.of("email", novoEmail())))
                    .andExpect(status().isNoContent());

            verify(emailService, never()).enviarVerificacao(anyString(), anyString());
        }

        @Test
        void dentroCooldown_retorna204SemEnviarEmail() throws Exception {
            String email = novoEmail();
            cadastrar(email);
            reset(emailService);

            mockMvc.perform(postJson("/auth/resend-verification", Map.of("email", email)))
                    .andExpect(status().isNoContent());

            verify(emailService, never()).enviarVerificacao(anyString(), anyString());
        }
    }

    private String cadastrarEVerificar(String email) throws Exception {
        String token = cadastrar(email);
        mockMvc.perform(postJson("/auth/verify-email", Map.of("token", token)))
                .andExpect(status().isNoContent());
        return token;
    }

    private TokenPair cadastrarVerificarELogar(String email) throws Exception {
        cadastrarEVerificar(email);
        return login(email);
    }

    private String cadastrar(String email) throws Exception {
        mockMvc.perform(postJson("/auth/register", AuthFixtures.registro(email)))
                .andExpect(status().isCreated());
        return ultimoTokenEnviado();
    }

    private void envelhecerToken(String tokenPlain, Duration idade) {
        TokenUsuario token = tokenUsuarioRepository
                .findByTokenHashAndUsadoEmIsNull(refreshTokenService.hashSha256(tokenPlain))
                .orElseThrow();
        token.setCriadoEm(Instant.now().minus(idade));
        tokenUsuarioRepository.save(token);
    }

    private TokenPair login(String email) throws Exception {
        MvcResult result = mockMvc.perform(postJson("/auth/login", AuthFixtures.login(email)))
                .andExpect(status().isOk())
                .andReturn();
        return tokens(result);
    }

    private TokenPair refresh(String refreshToken) throws Exception {
        MvcResult result = mockMvc.perform(postJson("/auth/refresh", Map.of("refreshToken", refreshToken)))
                .andExpect(status().isOk())
                .andReturn();
        return tokens(result);
    }

    private TokenPair tokens(MvcResult result) throws Exception {
        JsonNode json = objectMapper.readTree(result.getResponse().getContentAsString());
        return new TokenPair(json.get("accessToken").asText(), json.get("refreshToken").asText());
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder postJson(String path, Object body) throws Exception {
        return post(path)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body));
    }

    private String ultimoTokenEnviado() {
        ArgumentCaptor<String> captor = ArgumentCaptor.forClass(String.class);
        verify(emailService, atLeastOnce()).enviarVerificacao(anyString(), captor.capture());
        String link = captor.getAllValues().get(captor.getAllValues().size() - 1);
        return UriComponentsBuilder.fromUriString(link).build().getQueryParams().getFirst("token");
    }

    private String novoEmail() {
        return "usuario%04d@example.com".formatted(EMAIL_COUNTER.incrementAndGet());
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private record TokenPair(String accessToken, String refreshToken) {
    }

}
