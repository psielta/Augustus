package br.com.augustus.backend.domain.service.auth;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import br.com.augustus.backend.domain.model.entity.Usuario;
import br.com.augustus.backend.domain.repository.UsuarioRepository;
import br.com.augustus.backend.domain.service.exception.NaoAutenticadoException;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class AutenticadoUsuarioResolver {

    private final UsuarioRepository usuarioRepository;

    public String usuarioIdAtual() {
        Authentication authentication = authentication();
        Object principal = authentication.getPrincipal();
        if (principal instanceof String usuarioId) {
            return usuarioId;
        }
        throw new NaoAutenticadoException();
    }

    public Usuario usuarioAtual() {
        return usuarioRepository.findById(usuarioIdAtual()).orElseThrow(NaoAutenticadoException::new);
    }

    public String sessaoIdAtual() {
        Authentication authentication = authentication();
        Object details = authentication.getDetails();
        if (details instanceof String sid) {
            return sid;
        }
        throw new NaoAutenticadoException();
    }

    private Authentication authentication() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new NaoAutenticadoException();
        }
        return authentication;
    }

}
