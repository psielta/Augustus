package br.com.augustus.backend.domain.service.exception;

public class EmailJaCadastradoException extends NegocioException {

    private static final long serialVersionUID = 1L;

    public EmailJaCadastradoException() {
        super("EMAIL_JA_CADASTRADO: email ja cadastrado.");
    }

}
