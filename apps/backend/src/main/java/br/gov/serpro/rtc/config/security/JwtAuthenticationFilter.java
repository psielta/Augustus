package br.gov.serpro.rtc.config.security;

import java.io.IOException;
import java.time.Instant;
import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import br.gov.serpro.rtc.domain.model.entity.SessaoUsuario;
import br.gov.serpro.rtc.domain.repository.SessaoUsuarioRepository;
import br.gov.serpro.rtc.domain.service.auth.JwtTokenService;
import br.gov.serpro.rtc.domain.service.auth.JwtTokenService.DadosToken;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenService jwtTokenService;
    private final SessaoUsuarioRepository sessaoUsuarioRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String authorization = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String token = authorization.substring("Bearer ".length()).trim();
            DadosToken dados = jwtTokenService.validar(token);
            sessaoUsuarioRepository.findByIdAndRevogadoEmIsNull(dados.sid())
                    .filter(sessao -> sessao.getExpiraEm().isAfter(Instant.now()))
                    .filter(sessao -> sessao.getUsuario().getId().equals(dados.usuarioId()))
                    .ifPresent(this::autenticar);
        } catch (JwtException | IllegalArgumentException ex) {
            SecurityContextHolder.clearContext();
            log.debug("JWT invalido: {}", ex.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    private void autenticar(SessaoUsuario sessao) {
        String papel = sessao.getUsuario().getPapelSistema().name();
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                sessao.getUsuario().getId(),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_" + papel)));
        authentication.setDetails(sessao.getId());
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

}
