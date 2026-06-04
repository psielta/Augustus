/*
 * Versão de Homologação/Testes
 */
package br.com.augustus.backend.domain.service.exception;

public class CampoInvalidoException extends NegocioException {

    private static final long serialVersionUID = 2582687430572466747L;

    public CampoInvalidoException(String msg) {
        super(msg);
    }

}