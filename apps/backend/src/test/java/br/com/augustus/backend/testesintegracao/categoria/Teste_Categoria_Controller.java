package br.com.augustus.backend.testesintegracao.categoria;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.verify;
import static org.springframework.http.HttpHeaders.AUTHORIZATION;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.HashMap;
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

import br.com.augustus.backend.domain.repository.CategoriaRepository;
import br.com.augustus.backend.domain.repository.LoginAuditoriaRepository;
import br.com.augustus.backend.domain.repository.SessaoUsuarioRepository;
import br.com.augustus.backend.domain.repository.TokenUsuarioRepository;
import br.com.augustus.backend.domain.repository.UsuarioCredencialRepository;
import br.com.augustus.backend.domain.repository.UsuarioRepository;
import br.com.augustus.backend.domain.service.auth.EmailService;
import br.com.augustus.backend.testesintegracao.AbstractIntegrationTest;

class Teste_Categoria_Controller extends AbstractIntegrationTest {

    private static final String SENHA_PADRAO = "senha-forte-123";
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
    private CategoriaRepository categoriaRepository;

    @MockitoBean
    private EmailService emailService;

    @BeforeEach
    void setUp() {
        limparTabelas();
        reset(emailService);
    }

    private void limparTabelas() {
        loginAuditoriaRepository.deleteAllInBatch();
        tokenUsuarioRepository.deleteAllInBatch();
        sessaoUsuarioRepository.deleteAllInBatch();
        usuarioCredencialRepository.deleteAllInBatch();
        categoriaRepository.deleteAllInBatch();
        usuarioRepository.deleteAllInBatch();
    }

    @Nested
    class Criar {

        @Test
        void comSucesso_retorna201_persisteParaUsuario() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());

            mockMvc.perform(postJson("/categorias", categoria("Despesas Casa", "DESPESA"), token))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.nome").value("Despesas Casa"))
                    .andExpect(jsonPath("$.tipo").value("DESPESA"))
                    .andExpect(jsonPath("$.ativo").value(true));

            org.assertj.core.api.Assertions.assertThat(categoriaRepository.count()).isEqualTo(1);
        }

        @Test
        void semToken_retorna401() throws Exception {
            mockMvc.perform(postJson("/categorias", categoria("Teste", "DESPESA"), null))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        void duplicado_retorna409() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());
            mockMvc.perform(postJson("/categorias", categoria("Alimentacao", "DESPESA"), token))
                    .andExpect(status().isCreated());

            mockMvc.perform(postJson("/categorias", categoria("alimentacao", "DESPESA"), token))
                    .andExpect(status().isConflict())
                    .andExpect(jsonPath("$.detail", containsString("CATEGORIA_JA_EXISTE")));
        }

        @Test
        void validacoesInvalidas_retornam400() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());

            mockMvc.perform(postJson("/categorias", Map.of("nome", "   ", "tipo", "DESPESA"), token))
                    .andExpect(status().isBadRequest());

            Map<String, Object> semTipo = new HashMap<>();
            semTipo.put("nome", "Ok");
            semTipo.put("tipo", null);
            mockMvc.perform(postJson("/categorias", semTipo, token))
                    .andExpect(status().isBadRequest());

            mockMvc.perform(postJson("/categorias", Map.of("nome", "Ok", "tipo", "TIPO_INEXISTENTE"), token))
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    class Listar {

        @Test
        void retornaApenasCategoriasDoUsuarioChamador() throws Exception {
            String tokenA = cadastrarVerificarELogar(novoEmail());
            String tokenB = cadastrarVerificarELogar(novoEmail());

            mockMvc.perform(postJson("/categorias", categoria("Cat A", "DESPESA"), tokenA))
                    .andExpect(status().isCreated());
            mockMvc.perform(postJson("/categorias", categoria("Cat B", "RECEITA"), tokenB))
                    .andExpect(status().isCreated());

            mockMvc.perform(get("/categorias").header(AUTHORIZATION, bearer(tokenA)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$", hasSize(1)))
                    .andExpect(jsonPath("$[0].nome").value("Cat A"));
        }
    }

    @Nested
    class Buscar {

        @Test
        void idDeOutroUsuario_retorna404() throws Exception {
            String tokenA = cadastrarVerificarELogar(novoEmail());
            String tokenB = cadastrarVerificarELogar(novoEmail());

            MvcResult criada = mockMvc.perform(postJson("/categorias", categoria("Privada", "DESPESA"), tokenA))
                    .andExpect(status().isCreated())
                    .andReturn();
            String id = objectMapper.readTree(criada.getResponse().getContentAsString()).get("id").asText();

            mockMvc.perform(get("/categorias/" + id).header(AUTHORIZATION, bearer(tokenB)))
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.detail", containsString("CATEGORIA_NAO_ENCONTRADA")));
        }
    }

    @Nested
    class Atualizar {

        @Test
        void idDeOutroUsuario_retorna404() throws Exception {
            String tokenA = cadastrarVerificarELogar(novoEmail());
            String tokenB = cadastrarVerificarELogar(novoEmail());

            MvcResult criada = mockMvc.perform(postJson("/categorias", categoria("Original", "DESPESA"), tokenA))
                    .andExpect(status().isCreated())
                    .andReturn();
            String id = objectMapper.readTree(criada.getResponse().getContentAsString()).get("id").asText();

            mockMvc.perform(putJson("/categorias/" + id, categoria("Alterada", "DESPESA"), tokenB))
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    class Excluir {

        @Test
        void propria_retorna204_removeRegistro() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());
            MvcResult criada = mockMvc.perform(postJson("/categorias", categoria("Excluir", "DESPESA"), token))
                    .andExpect(status().isCreated())
                    .andReturn();
            String id = objectMapper.readTree(criada.getResponse().getContentAsString()).get("id").asText();

            mockMvc.perform(delete("/categorias/" + id).header(AUTHORIZATION, bearer(token)))
                    .andExpect(status().isNoContent());

            org.assertj.core.api.Assertions.assertThat(categoriaRepository.findById(id)).isEmpty();
        }

        @Test
        void deOutroUsuario_retorna404_naoRemoveDoOutro() throws Exception {
            String tokenA = cadastrarVerificarELogar(novoEmail());
            String tokenB = cadastrarVerificarELogar(novoEmail());

            MvcResult criada = mockMvc.perform(postJson("/categorias", categoria("Do A", "DESPESA"), tokenA))
                    .andExpect(status().isCreated())
                    .andReturn();
            String id = objectMapper.readTree(criada.getResponse().getContentAsString()).get("id").asText();

            mockMvc.perform(delete("/categorias/" + id).header(AUTHORIZATION, bearer(tokenB)))
                    .andExpect(status().isNotFound());

            org.assertj.core.api.Assertions.assertThat(categoriaRepository.findById(id)).isPresent();
        }
    }

    @Nested
    class Subcategoria {

        @Test
        void filhaComPaiValido_ok() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());
            String paiId = criarCategoria(token, "Pai", "DESPESA");

            mockMvc.perform(postJson("/categorias",
                    Map.of("nome", "Filha", "tipo", "DESPESA", "categoriaPaiId", paiId), token))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$.categoriaPaiId").value(paiId));
        }

        @Test
        void paiTipoDiferente_retorna422() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());
            String paiId = criarCategoria(token, "Pai", "DESPESA");

            mockMvc.perform(postJson("/categorias",
                    Map.of("nome", "Filha", "tipo", "RECEITA", "categoriaPaiId", paiId), token))
                    .andExpect(status().isUnprocessableEntity())
                    .andExpect(jsonPath("$.detail", containsString("CATEGORIA_INVALIDA")));
        }

        @Test
        void excluirPaiComFilha_retorna422() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());
            String paiId = criarCategoria(token, "Pai", "DESPESA");
            mockMvc.perform(postJson("/categorias",
                    Map.of("nome", "Filha", "tipo", "DESPESA", "categoriaPaiId", paiId), token))
                    .andExpect(status().isCreated());

            mockMvc.perform(delete("/categorias/" + paiId).header(AUTHORIZATION, bearer(token)))
                    .andExpect(status().isUnprocessableEntity())
                    .andExpect(jsonPath("$.detail", containsString("CATEGORIA_INVALIDA")));
        }
    }

    @Nested
    class SemearPadrao {

        @Test
        void cria14_idempotente_naoDuplica() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());

            mockMvc.perform(post("/categorias/semear-padrao").header(AUTHORIZATION, bearer(token)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$", hasSize(14)));

            mockMvc.perform(post("/categorias/semear-padrao").header(AUTHORIZATION, bearer(token)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$", hasSize(0)));

            org.assertj.core.api.Assertions.assertThat(categoriaRepository.count()).isEqualTo(14);
        }

        @Test
        void respeitaCategoriasPreExistentesMesmoNomeTipo() throws Exception {
            String token = cadastrarVerificarELogar(novoEmail());
            mockMvc.perform(postJson("/categorias", categoria("Alimentação", "DESPESA"), token))
                    .andExpect(status().isCreated());

            mockMvc.perform(post("/categorias/semear-padrao").header(AUTHORIZATION, bearer(token)))
                    .andExpect(status().isCreated())
                    .andExpect(jsonPath("$", hasSize(13)));

            org.assertj.core.api.Assertions.assertThat(categoriaRepository.count()).isEqualTo(14);
        }
    }

    private String criarCategoria(String token, String nome, String tipo) throws Exception {
        MvcResult result = mockMvc.perform(postJson("/categorias", categoria(nome, tipo), token))
                .andExpect(status().isCreated())
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();
    }

    private Map<String, Object> categoria(String nome, String tipo) {
        return Map.of("nome", nome, "tipo", tipo);
    }

    private Map<String, String> registro(String email) {
        return Map.of(
                "nome", "Usuario Teste",
                "email", email,
                "senha", SENHA_PADRAO);
    }

    private Map<String, String> loginBody(String email) {
        return Map.of(
                "email", email,
                "senha", SENHA_PADRAO);
    }

    private String cadastrarVerificarELogar(String email) throws Exception {
        cadastrar(email);
        verificar(email);
        return login(email).accessToken();
    }

    private void cadastrar(String email) throws Exception {
        mockMvc.perform(postJson("/auth/register", registro(email), null))
                .andExpect(status().isCreated());
    }

    private void verificar(String email) throws Exception {
        String token = ultimoTokenEnviado();
        mockMvc.perform(postJson("/auth/verify-email", Map.of("token", token), null))
                .andExpect(status().isNoContent());
    }

    private TokenPair login(String email) throws Exception {
        MvcResult result = mockMvc.perform(postJson("/auth/login", loginBody(email), null))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode json = objectMapper.readTree(result.getResponse().getContentAsString());
        return new TokenPair(json.get("accessToken").asText(), json.get("refreshToken").asText());
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder postJson(
            String path, Object body, String accessToken) throws Exception {
        var builder = post(path)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body));
        if (accessToken != null) {
            builder.header(AUTHORIZATION, bearer(accessToken));
        }
        return builder;
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder putJson(
            String path, Object body, String accessToken) throws Exception {
        return put(path)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body))
                .header(AUTHORIZATION, bearer(accessToken));
    }

    private String ultimoTokenEnviado() {
        ArgumentCaptor<String> captor = ArgumentCaptor.forClass(String.class);
        verify(emailService, atLeastOnce()).enviarVerificacao(anyString(), captor.capture());
        String link = captor.getAllValues().get(captor.getAllValues().size() - 1);
        return UriComponentsBuilder.fromUriString(link).build().getQueryParams().getFirst("token");
    }

    private String novoEmail() {
        return "categoria%04d@example.com".formatted(EMAIL_COUNTER.incrementAndGet());
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }

    private record TokenPair(String accessToken, String refreshToken) {
    }

}