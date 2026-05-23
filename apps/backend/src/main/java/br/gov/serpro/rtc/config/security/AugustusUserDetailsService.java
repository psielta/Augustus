package br.gov.serpro.rtc.config.security;

import java.util.List;

import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import br.gov.serpro.rtc.domain.model.enumeration.StatusUsuario;
import br.gov.serpro.rtc.domain.repository.UsuarioCredencialRepository;
import br.gov.serpro.rtc.domain.repository.UsuarioRepository;
import br.gov.serpro.rtc.domain.service.auth.EmailNormalizador;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AugustusUserDetailsService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;
    private final UsuarioCredencialRepository usuarioCredencialRepository;
    private final EmailNormalizador emailNormalizador;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        String emailNormalizado = emailNormalizador.normalizar(username);
        var usuario = usuarioRepository.findByEmailNormalizado(emailNormalizado)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario nao encontrado."));
        var credencial = usuarioCredencialRepository.findById(usuario.getId())
                .orElseThrow(() -> new UsernameNotFoundException("Credencial nao encontrada."));
        boolean enabled = usuario.getStatus() == StatusUsuario.ATIVO && Boolean.TRUE.equals(usuario.getEmailVerificado());

        return new User(
                usuario.getEmailNormalizado(),
                credencial.getSenhaHash(),
                enabled,
                true,
                true,
                true,
                List.of(new SimpleGrantedAuthority("ROLE_" + usuario.getPapelSistema().name())));
    }

}
