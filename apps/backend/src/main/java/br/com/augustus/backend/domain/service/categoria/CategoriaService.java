package br.com.augustus.backend.domain.service.categoria;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.augustus.backend.api.model.input.categoria.CategoriaInput;
import br.com.augustus.backend.api.model.output.categoria.CategoriaOutput;
import br.com.augustus.backend.api.model.output.categoria.CategoriaTemplateOutput;
import br.com.augustus.backend.domain.model.entity.Categoria;
import br.com.augustus.backend.domain.model.entity.CategoriaTemplate;
import br.com.augustus.backend.domain.model.enumeration.TipoCategoria;
import br.com.augustus.backend.domain.repository.CategoriaRepository;
import br.com.augustus.backend.domain.repository.CategoriaTemplateRepository;
import br.com.augustus.backend.domain.repository.UsuarioRepository;
import br.com.augustus.backend.domain.service.exception.CategoriaInvalidaException;
import br.com.augustus.backend.domain.service.exception.CategoriaJaExisteException;
import br.com.augustus.backend.domain.service.exception.CategoriaNaoEncontradaException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoriaService {

    private final ConcurrentHashMap<String, Object> semearPadraoLocks = new ConcurrentHashMap<>();

    private final CategoriaRepository categoriaRepository;
    private final CategoriaTemplateRepository categoriaTemplateRepository;
    private final UsuarioRepository usuarioRepository;

    @Transactional(readOnly = true)
    public List<CategoriaOutput> listar(String usuarioId) {
        return categoriaRepository.findByUsuario_IdOrderByTipoAscOrdemAscNomeAsc(usuarioId).stream()
                .map(this::toOutput)
                .toList();
    }

    @Transactional(readOnly = true)
    public CategoriaOutput buscarPorId(String usuarioId, String id) {
        return toOutput(buscarEntidade(usuarioId, id));
    }

    @Transactional
    public CategoriaOutput criar(String usuarioId, CategoriaInput input) {
        String nome = normalizarNome(input.getNome());
        validarDuplicado(usuarioId, input.getTipo(), nome, null);
        validarPai(usuarioId, input.getCategoriaPaiId(), input.getTipo(), null);

        Instant agora = Instant.now();
        Categoria categoria = new Categoria();
        categoria.setId(UUID.randomUUID().toString());
        categoria.setUsuario(usuarioRepository.getReferenceById(usuarioId));
        categoria.setNome(nome);
        categoria.setTipo(input.getTipo());
        categoria.setCategoriaPaiId(input.getCategoriaPaiId());
        categoria.setCorHex(normalizarCorHex(input.getCorHex()));
        categoria.setIcone(input.getIcone());
        categoria.setOrdem(input.getOrdem() != null ? input.getOrdem() : 0);
        categoria.setCriadaPorTemplate(false);
        categoria.setTemplateCodigo(null);
        categoria.setAtivo(input.getAtivo() != null ? input.getAtivo() : true);
        categoria.setCriadoEm(agora);
        categoria.setAtualizadoEm(agora);

        return toOutput(categoriaRepository.save(categoria));
    }

    @Transactional
    public CategoriaOutput atualizar(String usuarioId, String id, CategoriaInput input) {
        Categoria categoria = buscarEntidade(usuarioId, id);
        String nome = normalizarNome(input.getNome());
        validarDuplicado(usuarioId, input.getTipo(), nome, id);
        validarPai(usuarioId, input.getCategoriaPaiId(), input.getTipo(), id);

        categoria.setNome(nome);
        categoria.setTipo(input.getTipo());
        categoria.setCategoriaPaiId(input.getCategoriaPaiId());
        categoria.setCorHex(normalizarCorHex(input.getCorHex()));
        categoria.setIcone(input.getIcone());
        if (input.getOrdem() != null) {
            categoria.setOrdem(input.getOrdem());
        }
        if (input.getAtivo() != null) {
            categoria.setAtivo(input.getAtivo());
        }
        categoria.setAtualizadoEm(Instant.now());

        return toOutput(categoriaRepository.save(categoria));
    }

    @Transactional
    public void excluir(String usuarioId, String id) {
        buscarEntidade(usuarioId, id);
        if (categoriaRepository.existsByUsuario_IdAndCategoriaPaiId(usuarioId, id)) {
            throw new CategoriaInvalidaException(
                    "CATEGORIA_INVALIDA: remova as subcategorias antes de excluir esta categoria.");
        }
        categoriaRepository.deleteById(id);
    }

    @Transactional
    public List<CategoriaOutput> semearPadrao(String usuarioId) {
        Object lock = semearPadraoLocks.computeIfAbsent(usuarioId, ignored -> new Object());
        synchronized (lock) {
            return semearPadraoInterno(usuarioId);
        }
    }

    private List<CategoriaOutput> semearPadraoInterno(String usuarioId) {
        List<CategoriaTemplate> templates = categoriaTemplateRepository.findByAtivoTrueOrderByTipoAscOrdemAsc();
        Instant agora = Instant.now();
        List<CategoriaOutput> criadas = new ArrayList<>();

        for (CategoriaTemplate template : templates) {
            if (templateJaInstanciado(usuarioId, template)) {
                continue;
            }
            try {
                Categoria categoria = montarCategoriaDeTemplate(usuarioId, template, agora);
                criadas.add(toOutput(categoriaRepository.save(categoria)));
            } catch (DataIntegrityViolationException ex) {
                log.warn(
                        "Semear padrao ignorou template {} para usuario {} (ja existe): {}",
                        template.getCodigo(),
                        usuarioId,
                        ex.getMostSpecificCause().getMessage());
            }
        }

        return criadas;
    }

    private boolean templateJaInstanciado(String usuarioId, CategoriaTemplate template) {
        if (categoriaRepository.existsByUsuario_IdAndTemplateCodigo(usuarioId, template.getCodigo())) {
            return true;
        }
        String nome = normalizarNome(template.getNome());
        return categoriaRepository.existsByUsuario_IdAndTipoAndNomeIgnoreCase(
                usuarioId, template.getTipo(), nome);
    }

    private Categoria montarCategoriaDeTemplate(String usuarioId, CategoriaTemplate template, Instant agora) {
        Categoria categoria = new Categoria();
        categoria.setId(UUID.randomUUID().toString());
        categoria.setUsuario(usuarioRepository.getReferenceById(usuarioId));
        categoria.setNome(template.getNome());
        categoria.setTipo(template.getTipo());
        categoria.setCorHex(template.getCorHex());
        categoria.setIcone(template.getIcone());
        categoria.setOrdem(template.getOrdem());
        categoria.setCriadaPorTemplate(true);
        categoria.setTemplateCodigo(template.getCodigo());
        categoria.setAtivo(true);
        categoria.setCriadoEm(agora);
        categoria.setAtualizadoEm(agora);
        return categoria;
    }

    @Transactional(readOnly = true)
    public List<CategoriaTemplateOutput> listarTemplates() {
        return categoriaTemplateRepository.findByAtivoTrueOrderByTipoAscOrdemAsc().stream()
                .map(this::toTemplateOutput)
                .toList();
    }

    private Categoria buscarEntidade(String usuarioId, String id) {
        return categoriaRepository.findByIdAndUsuario_Id(id, usuarioId)
                .orElseThrow(CategoriaNaoEncontradaException::new);
    }

    private void validarDuplicado(String usuarioId, TipoCategoria tipo, String nome, String idExcluir) {
        boolean duplicado = idExcluir == null
                ? categoriaRepository.existsByUsuario_IdAndTipoAndNomeIgnoreCase(usuarioId, tipo, nome)
                : categoriaRepository.existsByUsuario_IdAndTipoAndNomeIgnoreCaseAndIdNot(usuarioId, tipo, nome, idExcluir);
        if (duplicado) {
            throw new CategoriaJaExisteException();
        }
    }

    private void validarPai(String usuarioId, String categoriaPaiId, TipoCategoria tipo, String idAtual) {
        if (categoriaPaiId == null || categoriaPaiId.isBlank()) {
            return;
        }
        if (idAtual != null && categoriaPaiId.equals(idAtual)) {
            throw new CategoriaInvalidaException(
                    "CATEGORIA_INVALIDA: uma categoria nao pode ser pai de si mesma.");
        }
        Categoria pai = categoriaRepository.findByIdAndUsuario_Id(categoriaPaiId, usuarioId)
                .orElseThrow(() -> new CategoriaInvalidaException(
                        "CATEGORIA_INVALIDA: categoria pai nao encontrada."));
        if (pai.getTipo() != tipo) {
            throw new CategoriaInvalidaException(
                    "CATEGORIA_INVALIDA: categoria pai deve ter o mesmo tipo.");
        }
        if (pai.getCategoriaPaiId() != null) {
            throw new CategoriaInvalidaException(
                    "CATEGORIA_INVALIDA: hierarquia limitada a dois niveis.");
        }
    }

    private String normalizarNome(String nome) {
        return nome == null ? "" : nome.trim();
    }

    private String normalizarCorHex(String corHex) {
        if (corHex == null || corHex.isBlank()) {
            return null;
        }
        String valor = corHex.trim();
        return valor.startsWith("#") ? valor : "#" + valor;
    }

    private CategoriaOutput toOutput(Categoria categoria) {
        return CategoriaOutput.builder()
                .id(categoria.getId())
                .nome(categoria.getNome())
                .tipo(categoria.getTipo())
                .categoriaPaiId(categoria.getCategoriaPaiId())
                .corHex(categoria.getCorHex())
                .icone(categoria.getIcone())
                .ordem(categoria.getOrdem())
                .ativo(categoria.getAtivo())
                .criadaPorTemplate(categoria.getCriadaPorTemplate())
                .templateCodigo(categoria.getTemplateCodigo())
                .criadoEm(categoria.getCriadoEm())
                .atualizadoEm(categoria.getAtualizadoEm())
                .build();
    }

    private CategoriaTemplateOutput toTemplateOutput(CategoriaTemplate template) {
        return CategoriaTemplateOutput.builder()
                .codigo(template.getCodigo())
                .nome(template.getNome())
                .tipo(template.getTipo())
                .corHex(template.getCorHex())
                .icone(template.getIcone())
                .ordem(template.getOrdem())
                .build();
    }

}