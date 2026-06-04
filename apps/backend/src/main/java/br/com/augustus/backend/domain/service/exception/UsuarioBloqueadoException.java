package br.com.augustus.backend.domain.service.exception;

public class UsuarioBloqueadoException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public UsuarioBloqueadoException() {
        super("USUARIO_BLOQUEADO: muitas tentativas invalidas. Tente novamente mais tarde.");
    }

}
