package br.com.augustus.backend.domain.service.auth;

public interface EmailService {

    void enviarVerificacao(String emailDestino, String linkVerificacao);

}
