package br.gov.serpro.rtc.domain.service.exception;

public class RefreshTokenInvalidoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public RefreshTokenInvalidoException() {
        super("REFRESH_TOKEN_INVALIDO: refresh token invalido, revogado ou expirado.");
    }

}
