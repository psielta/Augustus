package br.com.augustus.backend.domain.service.exception;

public class CategoriaJaExisteException extends NegocioException {

    private static final long serialVersionUID = 1L;

    public CategoriaJaExisteException() {
        super("CATEGORIA_JA_EXISTE: ja existe categoria com esse nome e tipo.");
    }

}