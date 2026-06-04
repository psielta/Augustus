package br.com.augustus.backend.domain.service.exception;

public class CredenciaisInvalidasException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public CredenciaisInvalidasException() {
        super("CREDENCIAIS_INVALIDAS: email ou senha invalidos.");
    }

}
