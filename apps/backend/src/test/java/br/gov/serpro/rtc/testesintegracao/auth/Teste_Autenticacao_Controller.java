package br.gov.serpro.rtc.testesintegracao.auth;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
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

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import br.gov.serpro.rtc.config.security.AuthProperties;
import br.gov.serpro.rtc.domain.model.entity.SessaoUsuario;
import br.gov.serpro.rtc.domain.model.entity.TokenUsuario;
import br.gov.serpro.rtc.domain.repository.LoginAuditoriaRepository;
import br.gov.serpro.rtc.domain.repository.SessaoUsuarioRepository;
import br.gov.serpro.rtc.domain.repository.TokenUsuarioRepository;
import br.gov.serpro.rtc.domain.repository.UsuarioCredencialRepository;
import br.gov.serpro.rtc.domain.repository.UsuarioRepository;
import br.gov.serpro.rtc.domain.service.auth.EmailService;
import br.gov.serpro.rtc.domain.service.auth.JwtTokenService;
import br.gov.serpro.rtc.domain.service.auth.RefreshTokenService;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(locations = "classpath:application-testes.yml")
@ActiveProfiles("testes")
class Teste_Autenticacao_Controller {

    private static final AtomicInteger EMAIL_COUNTER = new AtomicInteger();

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

    @Autowired
    private AuthProperties authProperties;

    @MockitoBean
    private EmailService emailService;

    @BeforeEach
    void setUp() {
        limparTabelasAuth();
        reset(emailService);
    }

    @AfterEach
    void resetCooldown() {
        authProperties.getResend().setCooldown(Duration.ZERO);
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
            authProperties.getResend().setCooldown(Duration.ofMinutes(5));
            String email = novoEmail();
            cadastrar(email);
            reset(emailService);

            mockMvc.perform(postJson("/auth/resend-verification", Map.of("email", email)))
                    .andExpect(status().isNoContent());

            verify(emailService, never()).enviarVerificacao(anyString(), anyString());
        }
    }

    @Test
    void endpointCalculadoraContinuaPublico() throws Exception {
        mockMvc.perform(get("/calculadora/dados-abertos/ufs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(28)));
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
