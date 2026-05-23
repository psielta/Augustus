package br.gov.serpro.rtc.domain.service.exception;

public class TokenVerificacaoInvalidoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public TokenVerificacaoInvalidoException() {
        super("TOKEN_VERIFICACAO_INVALIDO: token invalido, expirado ou ja utilizado.");
    }

}
