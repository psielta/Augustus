package br.com.augustus.backend.domain.service.exception;

public class EmailNaoVerificadoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public EmailNaoVerificadoException() {
        super("EMAIL_NAO_VERIFICADO: verifique o email antes de fazer login.");
    }

}
