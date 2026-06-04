package br.com.augustus.backend.testesintegracao.auth;

import java.util.Map;

final class AuthFixtures {

    static final String SENHA_PADRAO = "senha-forte-123";

    private AuthFixtures() {
    }

    static Map<String, String> registro(String email) {
        return Map.of(
                "nome", "Usuario Teste",
                "email", email,
                "senha", SENHA_PADRAO);
    }

    static Map<String, String> login(String email) {
        return Map.of(
                "email", email,
                "senha", SENHA_PADRAO);
    }

    static Map<String, String> login(String email, String senha) {
        return Map.of(
                "email", email,
                "senha", senha);
    }

}
