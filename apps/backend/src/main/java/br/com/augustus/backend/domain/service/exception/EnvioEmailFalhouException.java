package br.com.augustus.backend.domain.service.exception;

public class EnvioEmailFalhouException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public EnvioEmailFalhouException(Throwable cause) {
        super("ENVIO_EMAIL_FALHOU: nao foi possivel enviar o email de verificacao.", cause);
    }

}
