package br.com.augustus.backend.api.openapi.controller;

import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;
import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON_VALUE;

import java.util.List;

import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;

import br.com.augustus.backend.api.model.input.categoria.CategoriaInput;
import br.com.augustus.backend.api.model.output.categoria.CategoriaOutput;
import br.com.augustus.backend.api.model.output.categoria.CategoriaTemplateOutput;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@Tag(name = "Categorias Augustus", description = "CRUD de categorias financeiras por usuario")
public interface CategoriaControllerOpenApi {

    @Operation(summary = "Criar categoria", description = "Cria uma categoria para o usuario autenticado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Categoria criada", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = CategoriaOutput.class))),
        @ApiResponse(responseCode = "400", description = "Dados invalidos", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "409", description = "Categoria ja existe", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "422", description = "Categoria invalida", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<CategoriaOutput> criar(@Valid CategoriaInput input);

    @Operation(summary = "Listar categorias", description = "Lista categorias do usuario autenticado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista retornada", content = @Content(mediaType = APPLICATION_JSON_VALUE)),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<List<CategoriaOutput>> listar();

    @Operation(summary = "Buscar categoria", description = "Busca uma categoria do usuario autenticado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Categoria encontrada", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = CategoriaOutput.class))),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "404", description = "Categoria nao encontrada", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<CategoriaOutput> buscarPorId(String id);

    @Operation(summary = "Atualizar categoria", description = "Atualiza uma categoria do usuario autenticado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Categoria atualizada", content = @Content(mediaType = APPLICATION_JSON_VALUE,
            schema = @Schema(implementation = CategoriaOutput.class))),
        @ApiResponse(responseCode = "400", description = "Dados invalidos", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "404", description = "Categoria nao encontrada", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "409", description = "Categoria ja existe", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "422", description = "Categoria invalida", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<CategoriaOutput> atualizar(String id, @Valid CategoriaInput input);

    @Operation(summary = "Excluir categoria", description = "Exclui uma categoria do usuario autenticado.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Categoria excluida"),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "404", description = "Categoria nao encontrada", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class))),
        @ApiResponse(responseCode = "422", description = "Categoria invalida", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<Void> excluir(String id);

    @Operation(summary = "Semear categorias padrao", description = "Instancia templates padrao para o usuario (idempotente).")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Categorias criadas", content = @Content(mediaType = APPLICATION_JSON_VALUE)),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<List<CategoriaOutput>> semearPadrao();

    @Operation(summary = "Listar templates", description = "Lista o catalogo read-only de categoria_template.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Templates retornados", content = @Content(mediaType = APPLICATION_JSON_VALUE)),
        @ApiResponse(responseCode = "401", description = "Nao autenticado", content = @Content(mediaType = APPLICATION_PROBLEM_JSON_VALUE,
            schema = @Schema(implementation = ProblemDetail.class)))
    })
    ResponseEntity<List<CategoriaTemplateOutput>> listarTemplates();

}