package br.gov.serpro.rtc.domain.service.auth;

public interface EmailService {

    void enviarVerificacao(String emailDestino, String linkVerificacao);

}
