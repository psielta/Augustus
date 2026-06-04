/*
 * Versão de Homologação/Testes
 */
package br.com.augustus.backend.domain.service.exception;

public abstract class NegocioException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    protected NegocioException(String mensagem) {
        super(mensagem);
    }

}
