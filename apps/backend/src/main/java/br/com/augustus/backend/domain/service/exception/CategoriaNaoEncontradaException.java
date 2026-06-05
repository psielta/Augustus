package br.com.augustus.backend.domain.service.exception;

public class CategoriaNaoEncontradaException extends EntidadeNaoEncontradaException {

    private static final long serialVersionUID = 1L;

    public CategoriaNaoEncontradaException() {
        super("CATEGORIA_NAO_ENCONTRADA: categoria nao encontrada.");
    }

}