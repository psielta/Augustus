package br.com.augustus.backend.domain.service.auth;

import java.util.Locale;

import org.springframework.stereotype.Component;

@Component
public class EmailNormalizador {

    public String normalizar(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }

}
