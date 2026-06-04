package br.com.augustus.backend.domain.service.auth;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.stereotype.Service;

import br.com.augustus.backend.config.security.AuthProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

@Service
public class JwtTokenService {

    private final AuthProperties authProperties;
    private final SecretKey key;

    public JwtTokenService(AuthProperties authProperties) {
        this.authProperties = authProperties;
        this.key = Keys.hmacShaKeyFor(authProperties.getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
    }

    public String gerarAccessToken(String usuarioId, String sessaoId, Instant emitidoEm, Instant expiraEm) {
        return Jwts.builder()
                .subject(usuarioId)
                .issuer(authProperties.getJwt().getIssuer())
                .issuedAt(Date.from(emitidoEm))
                .expiration(Date.from(expiraEm))
                .claim("sid", sessaoId)
                .signWith(key, Jwts.SIG.HS256)
                .compact();
    }

    public DadosToken validar(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(key)
                .requireIssuer(authProperties.getJwt().getIssuer())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return new DadosToken(claims.getSubject(), claims.get("sid", String.class), claims.getExpiration().toInstant());
    }

    public record DadosToken(String usuarioId, String sid, Instant expiraEm) {
    }

}
