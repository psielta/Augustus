package br.com.augustus.backend.domain.service.exception;

public class CategoriaInvalidaException extends ValidacaoException {

    private static final long serialVersionUID = 1L;

    public CategoriaInvalidaException(String mensagem) {
        super(mensagem);
    }

}