package br.gov.serpro.rtc.domain.service.auth;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.UriComponentsBuilder;

import br.gov.serpro.rtc.api.model.input.auth.LoginInput;
import br.gov.serpro.rtc.api.model.input.auth.ReenviarVerificacaoInput;
import br.gov.serpro.rtc.api.model.input.auth.RefreshInput;
import br.gov.serpro.rtc.api.model.input.auth.RegistrarUsuarioInput;
import br.gov.serpro.rtc.api.model.input.auth.VerificarEmailInput;
import br.gov.serpro.rtc.api.model.output.auth.RegistroOutput;
import br.gov.serpro.rtc.api.model.output.auth.TokenPairOutput;
import br.gov.serpro.rtc.api.model.output.auth.UsuarioOutput;
import br.gov.serpro.rtc.config.security.AuthProperties;
import br.gov.serpro.rtc.domain.model.entity.LoginAuditoria;
import br.gov.serpro.rtc.domain.model.entity.SessaoUsuario;
import br.gov.serpro.rtc.domain.model.entity.TokenUsuario;
import br.gov.serpro.rtc.domain.model.entity.Usuario;
import br.gov.serpro.rtc.domain.model.entity.UsuarioCredencial;
import br.gov.serpro.rtc.domain.model.enumeration.MotivoRevogacaoSessao;
import br.gov.serpro.rtc.domain.model.enumeration.PapelSistema;
import br.gov.serpro.rtc.domain.model.enumeration.StatusUsuario;
import br.gov.serpro.rtc.domain.model.enumeration.TipoToken;
import br.gov.serpro.rtc.domain.repository.LoginAuditoriaRepository;
import br.gov.serpro.rtc.domain.repository.SessaoUsuarioRepository;
import br.gov.serpro.rtc.domain.repository.TokenUsuarioRepository;
import br.gov.serpro.rtc.domain.repository.UsuarioCredencialRepository;
import br.gov.serpro.rtc.domain.repository.UsuarioRepository;
import br.gov.serpro.rtc.domain.service.exception.CredenciaisInvalidasException;
import br.gov.serpro.rtc.domain.service.exception.EmailJaCadastradoException;
import br.gov.serpro.rtc.domain.service.exception.EmailNaoVerificadoException;
import br.gov.serpro.rtc.domain.service.exception.NaoAutenticadoException;
import br.gov.serpro.rtc.domain.service.exception.RefreshTokenInvalidoException;
import br.gov.serpro.rtc.domain.service.exception.TokenVerificacaoInvalidoException;
import br.gov.serpro.rtc.domain.service.exception.UsuarioBloqueadoException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class AutenticacaoService {

    private static final String ALGORITMO_BCRYPT = "BCRYPT";

    private final UsuarioRepository usuarioRepository;
    private final UsuarioCredencialRepository usuarioCredencialRepository;
    private final SessaoUsuarioRepository sessaoUsuarioRepository;
    private final TokenUsuarioRepository tokenUsuarioRepository;
    private final LoginAuditoriaRepository loginAuditoriaRepository;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenService refreshTokenService;
    private final JwtTokenService jwtTokenService;
    private final EmailService emailService;
    private final EmailNormalizador emailNormalizador;
    private final AuthProperties authProperties;

    @Transactional
    public RegistroOutput registrar(RegistrarUsuarioInput input) {
        Instant agora = Instant.now();
        String email = input.getEmail().trim();
        String emailNormalizado = emailNormalizador.normalizar(email);

        if (usuarioRepository.existsByEmailNormalizado(emailNormalizado)) {
            throw new EmailJaCadastradoException();
        }

        Usuario usuario = new Usuario();
        usuario.setId(UUID.randomUUID().toString());
        usuario.setNome(input.getNome().trim());
        usuario.setEmail(email);
        usuario.setEmailNormalizado(emailNormalizado);
        usuario.setStatus(StatusUsuario.PENDENTE_VERIFICACAO);
        usuario.setPapelSistema(PapelSistema.USUARIO);
        usuario.setEmailVerificado(false);
        usuario.setMoedaPadrao("BRL");
        usuario.setTimezone("America/Sao_Paulo");
        usuario.setLocale("pt-BR");
        usuario.setCriadoEm(agora);
        usuario.setAtualizadoEm(agora);
        usuarioRepository.save(usuario);

        UsuarioCredencial credencial = new UsuarioCredencial();
        credencial.setUsuarioId(usuario.getId());
        credencial.setSenhaHash(passwordEncoder.encode(input.getSenha()));
        credencial.setAlgoritmoHash(ALGORITMO_BCRYPT);
        credencial.setSenhaAlteradaEm(agora);
        credencial.setDeveAlterarSenha(false);
        credencial.setTentativasLoginFalhas(0);
        credencial.setCriadoEm(agora);
        credencial.setAtualizadoEm(agora);
        usuarioCredencialRepository.save(credencial);

        String tokenPlain = criarTokenVerificacao(usuario, agora);
        emailService.enviarVerificacao(usuario.getEmail(), criarLinkVerificacao(tokenPlain));

        return RegistroOutput.builder()
                .usuario(toUsuarioOutput(usuario))
                .mensagem("Cadastro criado. Verifique seu email para liberar o login.")
                .build();
    }

    @Transactional(noRollbackFor = {
            CredenciaisInvalidasException.class,
            EmailNaoVerificadoException.class,
            UsuarioBloqueadoException.class
    })
    public TokenPairOutput login(LoginInput input, String userAgent, String ip) {
        Instant agora = Instant.now();
        String emailNormalizado = emailNormalizador.normalizar(input.getEmail());
        Usuario usuario = usuarioRepository.findByEmailNormalizado(emailNormalizado).orElse(null);
        UsuarioCredencial credencial = usuario == null ? null : usuarioCredencialRepository.findById(usuario.getId()).orElse(null);

        if (usuario == null || credencial == null) {
            auditar(null, emailNormalizado, false, "CREDENCIAIS_INVALIDAS", ip, userAgent, agora);
            throw new CredenciaisInvalidasException();
        }

        if (credencial.getBloqueadoAte() != null && credencial.getBloqueadoAte().isAfter(agora)) {
            auditar(usuario, emailNormalizado, false, "USUARIO_BLOQUEADO", ip, userAgent, agora);
            throw new UsuarioBloqueadoException();
        }

        if (!passwordEncoder.matches(input.getSenha(), credencial.getSenhaHash())) {
            registrarFalhaSenha(usuario, credencial, agora);
            auditar(usuario, emailNormalizado, false, "CREDENCIAIS_INVALIDAS", ip, userAgent, agora);
            throw new CredenciaisInvalidasException();
        }

        if (!Boolean.TRUE.equals(usuario.getEmailVerificado())) {
            auditar(usuario, emailNormalizado, false, "EMAIL_NAO_VERIFICADO", ip, userAgent, agora);
            throw new EmailNaoVerificadoException();
        }

        credencial.setTentativasLoginFalhas(0);
        credencial.setBloqueadoAte(null);
        credencial.setAtualizadoEm(agora);
        usuarioCredencialRepository.save(credencial);

        usuario.setStatus(StatusUsuario.ATIVO);
        usuario.setUltimoLoginEm(agora);
        usuario.setAtualizadoEm(agora);
        usuarioRepository.save(usuario);

        auditar(usuario, emailNormalizado, true, null, ip, userAgent, agora);
        return criarTokenPair(usuario, userAgent, ip, agora);
    }

    @Transactional(noRollbackFor = RefreshTokenInvalidoException.class)
    public TokenPairOutput refresh(RefreshInput input, String userAgent, String ip) {
        Instant agora = Instant.now();
        String refreshTokenHash = refreshTokenService.hashSha256(input.getRefreshToken());
        SessaoUsuario sessaoAntiga = sessaoUsuarioRepository.findByRefreshTokenHashAndRevogadoEmIsNull(refreshTokenHash)
                .orElseThrow(RefreshTokenInvalidoException::new);

        if (!sessaoAntiga.getExpiraEm().isAfter(agora)) {
            sessaoAntiga.setRevogadoEm(agora);
            sessaoAntiga.setMotivoRevogacao(MotivoRevogacaoSessao.EXPIRADO_AUTO);
            sessaoUsuarioRepository.save(sessaoAntiga);
            throw new RefreshTokenInvalidoException();
        }

        sessaoAntiga.setUltimoUsoEm(agora);
        sessaoAntiga.setRevogadoEm(agora);
        sessaoAntiga.setMotivoRevogacao(MotivoRevogacaoSessao.ROTACAO);
        sessaoUsuarioRepository.save(sessaoAntiga);

        return criarTokenPair(sessaoAntiga.getUsuario(), userAgent, ip, agora);
    }

    @Transactional
    public void logout(String usuarioId, String sessaoId) {
        Instant agora = Instant.now();
        SessaoUsuario sessao = sessaoUsuarioRepository.findByIdAndRevogadoEmIsNull(sessaoId)
                .orElseThrow(NaoAutenticadoException::new);
        if (!sessao.getUsuario().getId().equals(usuarioId)) {
            throw new NaoAutenticadoException();
        }
        sessao.setRevogadoEm(agora);
        sessao.setMotivoRevogacao(MotivoRevogacaoSessao.LOGOUT);
        sessao.setUltimoUsoEm(agora);
        sessaoUsuarioRepository.save(sessao);
    }

    @Transactional(readOnly = true)
    public UsuarioOutput me(Usuario usuario) {
        return toUsuarioOutput(usuario);
    }

    @Transactional
    public void verificarEmail(VerificarEmailInput input) {
        verificarEmail(input.getToken());
    }

    @Transactional
    public void verificarEmail(String tokenPlain) {
        Instant agora = Instant.now();
        String tokenHash = refreshTokenService.hashSha256(tokenPlain);
        TokenUsuario token = tokenUsuarioRepository.findByTokenHashAndUsadoEmIsNull(tokenHash)
                .filter(t -> t.getTipo() == TipoToken.VERIFICACAO_EMAIL)
                .filter(t -> t.getExpiraEm().isAfter(agora))
                .orElseThrow(TokenVerificacaoInvalidoException::new);

        Usuario usuario = token.getUsuario();
        usuario.setEmailVerificado(true);
        usuario.setStatus(StatusUsuario.ATIVO);
        usuario.setAtualizadoEm(agora);
        token.setUsadoEm(agora);
        usuarioRepository.save(usuario);
        tokenUsuarioRepository.save(token);
    }

    @Transactional
    public void reenviarVerificacao(ReenviarVerificacaoInput input) {
        Instant agora = Instant.now();
        String emailNormalizado = emailNormalizador.normalizar(input.getEmail());
        usuarioRepository.findByEmailNormalizado(emailNormalizado)
                .filter(usuario -> !Boolean.TRUE.equals(usuario.getEmailVerificado()))
                .ifPresent(usuario -> reenviarVerificacao(usuario, agora));
    }

    private void reenviarVerificacao(Usuario usuario, Instant agora) {
        Duration cooldown = authProperties.getResend().getCooldown();
        boolean dentroCooldown = tokenUsuarioRepository
                .findFirstByUsuario_IdAndTipoOrderByCriadoEmDesc(usuario.getId(), TipoToken.VERIFICACAO_EMAIL)
                .map(TokenUsuario::getCriadoEm)
                .map(criadoEm -> criadoEm.plus(cooldown).isAfter(agora))
                .orElse(false);
        if (dentroCooldown) {
            log.info("Reenvio de verificacao ignorado por cooldown para usuario {}", usuario.getId());
            return;
        }

        tokenUsuarioRepository.invalidarPendentes(usuario.getId(), TipoToken.VERIFICACAO_EMAIL, agora);
        String tokenPlain = criarTokenVerificacao(usuario, agora);
        emailService.enviarVerificacao(usuario.getEmail(), criarLinkVerificacao(tokenPlain));
    }

    private void registrarFalhaSenha(Usuario usuario, UsuarioCredencial credencial, Instant agora) {
        int falhas = credencial.getTentativasLoginFalhas() + 1;
        credencial.setTentativasLoginFalhas(falhas);
        credencial.setAtualizadoEm(agora);
        if (falhas >= authProperties.getLockout().getMaxFalhas()) {
            credencial.setBloqueadoAte(agora.plus(Duration.ofMinutes(authProperties.getLockout().getDuracaoMinutos())));
            usuario.setStatus(StatusUsuario.BLOQUEADO);
            usuario.setAtualizadoEm(agora);
            usuarioRepository.save(usuario);
        }
        usuarioCredencialRepository.save(credencial);
    }

    private TokenPairOutput criarTokenPair(Usuario usuario, String userAgent, String ip, Instant agora) {
        String refreshTokenPlain = refreshTokenService.gerarTokenPlain();
        SessaoUsuario sessao = new SessaoUsuario();
        sessao.setId(UUID.randomUUID().toString());
        sessao.setUsuario(usuario);
        sessao.setRefreshTokenHash(refreshTokenService.hashSha256(refreshTokenPlain));
        sessao.setUserAgent(userAgent);
        sessao.setIpCriacao(ip);
        sessao.setCriadoEm(agora);
        sessao.setUltimoUsoEm(agora);
        sessao.setExpiraEm(agora.plus(authProperties.getJwt().getRefreshTtl()));
        sessaoUsuarioRepository.save(sessao);

        Instant accessExpiraEm = agora.plus(authProperties.getJwt().getAccessTtl());
        String accessToken = jwtTokenService.gerarAccessToken(usuario.getId(), sessao.getId(), agora, accessExpiraEm);

        return TokenPairOutput.builder()
                .accessToken(accessToken)
                .refreshToken(refreshTokenPlain)
                .accessTokenExpiraEm(accessExpiraEm)
                .refreshTokenExpiraEm(sessao.getExpiraEm())
                .tokenType("Bearer")
                .build();
    }

    private String criarTokenVerificacao(Usuario usuario, Instant agora) {
        String tokenPlain = refreshTokenService.gerarTokenPlain();
        TokenUsuario token = new TokenUsuario();
        token.setId(UUID.randomUUID().toString());
        token.setUsuario(usuario);
        token.setTipo(TipoToken.VERIFICACAO_EMAIL);
        token.setTokenHash(refreshTokenService.hashSha256(tokenPlain));
        token.setDestinoEmail(usuario.getEmail());
        token.setCriadoEm(agora);
        token.setExpiraEm(agora.plus(authProperties.getJwt().getVerificacaoTtl()));
        tokenUsuarioRepository.save(token);
        return tokenPlain;
    }

    private String criarLinkVerificacao(String tokenPlain) {
        return UriComponentsBuilder.fromUriString(authProperties.getVerificacao().getBaseUrl())
                .queryParam("token", tokenPlain)
                .build()
                .toUriString();
    }

    private void auditar(Usuario usuario, String emailInformado, boolean sucesso, String motivo, String ip, String userAgent, Instant agora) {
        LoginAuditoria auditoria = new LoginAuditoria();
        auditoria.setId(UUID.randomUUID().toString());
        auditoria.setUsuario(usuario);
        auditoria.setEmailInformado(emailInformado);
        auditoria.setSucesso(sucesso);
        auditoria.setMotivo(motivo);
        auditoria.setIp(ip);
        auditoria.setUserAgent(userAgent);
        auditoria.setCriadoEm(agora);
        loginAuditoriaRepository.save(auditoria);
    }

    private UsuarioOutput toUsuarioOutput(Usuario usuario) {
        return UsuarioOutput.builder()
                .id(usuario.getId())
                .nome(usuario.getNome())
                .email(usuario.getEmail())
                .status(usuario.getStatus())
                .papelSistema(usuario.getPapelSistema())
                .emailVerificado(usuario.getEmailVerificado())
                .criadoEm(usuario.getCriadoEm())
                .build();
    }

}
