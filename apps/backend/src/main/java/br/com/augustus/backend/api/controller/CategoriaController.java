package br.com.augustus.backend.api.controller;

import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.augustus.backend.api.model.input.categoria.CategoriaInput;
import br.com.augustus.backend.api.model.output.categoria.CategoriaOutput;
import br.com.augustus.backend.api.model.output.categoria.CategoriaTemplateOutput;
import br.com.augustus.backend.api.openapi.controller.CategoriaControllerOpenApi;
import br.com.augustus.backend.domain.service.auth.AutenticadoUsuarioResolver;
import br.com.augustus.backend.domain.service.categoria.CategoriaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/categorias", produces = APPLICATION_JSON_VALUE)
public class CategoriaController implements CategoriaControllerOpenApi {

    private final CategoriaService categoriaService;
    private final AutenticadoUsuarioResolver autenticadoUsuarioResolver;

    @Override
    @PostMapping(consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<CategoriaOutput> criar(@RequestBody @Valid CategoriaInput input) {
        String usuarioId = autenticadoUsuarioResolver.usuarioIdAtual();
        return ResponseEntity.status(HttpStatus.CREATED).body(categoriaService.criar(usuarioId, input));
    }

    @Override
    @GetMapping
    public ResponseEntity<List<CategoriaOutput>> listar() {
        String usuarioId = autenticadoUsuarioResolver.usuarioIdAtual();
        return ResponseEntity.ok(categoriaService.listar(usuarioId));
    }

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<CategoriaOutput> buscarPorId(@PathVariable String id) {
        String usuarioId = autenticadoUsuarioResolver.usuarioIdAtual();
        return ResponseEntity.ok(categoriaService.buscarPorId(usuarioId, id));
    }

    @Override
    @PutMapping(value = "/{id}", consumes = APPLICATION_JSON_VALUE)
    public ResponseEntity<CategoriaOutput> atualizar(@PathVariable String id, @RequestBody @Valid CategoriaInput input) {
        String usuarioId = autenticadoUsuarioResolver.usuarioIdAtual();
        return ResponseEntity.ok(categoriaService.atualizar(usuarioId, id, input));
    }

    @Override
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable String id) {
        String usuarioId = autenticadoUsuarioResolver.usuarioIdAtual();
        categoriaService.excluir(usuarioId, id);
        return ResponseEntity.noContent().build();
    }

    @Override
    @PostMapping("/semear-padrao")
    public ResponseEntity<List<CategoriaOutput>> semearPadrao() {
        String usuarioId = autenticadoUsuarioResolver.usuarioIdAtual();
        return ResponseEntity.status(HttpStatus.CREATED).body(categoriaService.semearPadrao(usuarioId));
    }

    @Override
    @GetMapping("/templates")
    public ResponseEntity<List<CategoriaTemplateOutput>> listarTemplates() {
        return ResponseEntity.ok(categoriaService.listarTemplates());
    }

}