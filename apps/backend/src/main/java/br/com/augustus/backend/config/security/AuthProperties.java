package br.com.augustus.backend.config.security;

import java.time.Duration;
import java.util.Locale;

import org.springframework.boot.context.properties.ConfigurationProperties;

import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@ConfigurationProperties(prefix = "auth")
public class AuthProperties {

    private Jwt jwt = new Jwt();
    private Lockout lockout = new Lockout();
    private Verificacao verificacao = new Verificacao();
    private Mail mail = new Mail();
    private Resend resend = new Resend();

    @PostConstruct
    void validarJwtSecret() {
        String secret = jwt.getSecret();
        if (secret == null || secret.length() < 32) {
            throw new IllegalStateException("auth.jwt.secret deve ter pelo menos 32 caracteres.");
        }
        String lower = secret.toLowerCase(Locale.ROOT);
        if (lower.contains("dev-only") || lower.contains("trocar-em-producao")) {
            throw new IllegalStateException("auth.jwt.secret contem marcador inseguro.");
        }
    }

    @Getter
    @Setter
    public static class Jwt {
        private String secret;
        private Duration accessTtl = Duration.ofMinutes(15);
        private Duration refreshTtl = Duration.ofDays(30);
        private Duration verificacaoTtl = Duration.ofDays(1);
        private String issuer = "augustus-backend";
    }

    @Getter
    @Setter
    public static class Lockout {
        private int maxFalhas = 5;
        private int duracaoMinutos = 15;
    }

    @Getter
    @Setter
    public static class Verificacao {
        private String baseUrl = "http://localhost:8080/api/auth/verify-email";
    }

    @Getter
    @Setter
    public static class Mail {
        private String from;
    }

    @Getter
    @Setter
    public static class Resend {
        private Duration cooldown = Duration.ofMinutes(1);
    }

}
