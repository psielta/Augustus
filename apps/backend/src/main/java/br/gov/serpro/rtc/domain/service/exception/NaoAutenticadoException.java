package br.gov.serpro.rtc.domain.service.exception;

public class NaoAutenticadoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public NaoAutenticadoException() {
        super("NAO_AUTENTICADO: autenticacao obrigatoria.");
    }

}
