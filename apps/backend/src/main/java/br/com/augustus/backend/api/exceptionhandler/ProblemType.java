package br.com.augustus.backend.api.exceptionhandler;

import java.net.URI;
import java.util.stream.Stream;

import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import br.com.augustus.backend.api.util.HttpUtils;
import br.com.augustus.backend.domain.service.exception.CampoInvalidoException;
import br.com.augustus.backend.domain.service.exception.CaptchaException;
import br.com.augustus.backend.domain.service.exception.CategoriaInvalidaException;
import br.com.augustus.backend.domain.service.exception.CategoriaJaExisteException;
import br.com.augustus.backend.domain.service.exception.CategoriaNaoEncontradaException;
import br.com.augustus.backend.domain.service.exception.CredenciaisInvalidasException;
import br.com.augustus.backend.domain.service.exception.EmailJaCadastradoException;
import br.com.augustus.backend.domain.service.exception.EmailNaoVerificadoException;
import br.com.augustus.backend.domain.service.exception.EnvioEmailFalhouException;
import br.com.augustus.backend.domain.service.exception.ErroInternoSistemaException;
import br.com.augustus.backend.domain.service.exception.EstruturaInconsistenteException;
import br.com.augustus.backend.domain.service.exception.EntidadeNaoEncontradaException;
import br.com.augustus.backend.domain.service.exception.NaoAutenticadoException;
import br.com.augustus.backend.domain.service.exception.NegocioException;
import br.com.augustus.backend.domain.service.exception.RefreshTokenInvalidoException;
import br.com.augustus.backend.domain.service.exception.TokenVerificacaoInvalidoException;
import br.com.augustus.backend.domain.service.exception.UsuarioBloqueadoException;
import br.com.augustus.backend.domain.service.exception.ValidacaoException;
import lombok.Getter;
import lombok.NonNull;

@Getter
public enum ProblemType {

    CAMPO_INVALIDO(CampoInvalidoException.class,
            "Campo inválido", "campo-invalido"),

    CATEGORIA_NAO_ENCONTRADA(CategoriaNaoEncontradaException.class, "Categoria nao encontrada", "categoria-nao-encontrada"),

    CATEGORIA_JA_EXISTE(CategoriaJaExisteException.class, "Categoria ja existe", "categoria-ja-existe"),

    CATEGORIA_INVALIDA(CategoriaInvalidaException.class, "Categoria invalida", "categoria-invalida"),

    EMAIL_JA_CADASTRADO(EmailJaCadastradoException.class, "Email ja cadastrado", "email-ja-cadastrado"),

    EMAIL_NAO_VERIFICADO(EmailNaoVerificadoException.class, "Email nao verificado", "email-nao-verificado"),

    CREDENCIAIS_INVALIDAS(CredenciaisInvalidasException.class, "Credenciais invalidas", "credenciais-invalidas"),

    USUARIO_BLOQUEADO(UsuarioBloqueadoException.class, "Usuario bloqueado", "usuario-bloqueado"),

    REFRESH_TOKEN_INVALIDO(RefreshTokenInvalidoException.class, "Refresh token invalido", "refresh-token-invalido"),

    TOKEN_VERIFICACAO_INVALIDO(TokenVerificacaoInvalidoException.class, "Token de verificacao invalido", "token-verificacao-invalido"),

    NAO_AUTENTICADO(NaoAutenticadoException.class, "Nao autenticado", "nao-autenticado"),

    ENVIO_EMAIL_FALHOU(EnvioEmailFalhouException.class, "Falha no envio de email", "envio-email-falhou"),

    ERRO_NEGOCIO(NegocioException.class, "Violação de regra de negócio", "erro-negocio"),

    ERRO_CAPTCHA(CaptchaException.class, "Erro de Captcha", "erro-captcha"),

    ENTIDADE_NAO_ENCONTRADA(EntidadeNaoEncontradaException.class, "Entidade não encontrada", "entidade-nao-encontrada"),

    ESTRUTURA_INCONSISTENTE(EstruturaInconsistenteException.class, "Estrutura inconsistente", "estrutura-inconsistente"),

    ERRO_INTERNO_SISTEMA(ErroInternoSistemaException.class, "Erro interno do sistema", "erro-interno-de-sistema"),

    VALIDACAO(ValidacaoException.class, "Erro de validação", "validacao"),

    METHOD_ARGUMENT_TYPE_MISMATCH(MethodArgumentTypeMismatchException.class, "Tipo de argumento inválido", "tipo-argumento-invalido"),

    ERRO_SISTEMA(Exception.class, "Erro de sistema não previsto", "erro-de-sistema-nao-previsto");

    private final Class<? extends Exception> classeErro;
    private final String titulo;
    private final String path;

    private ProblemType(Class<? extends Exception> classeErro, String titulo, String path) {
        this.classeErro = classeErro;
        this.titulo = titulo;
        this.path = path;
    }

    public URI getURI() {
        return URI.create(String.format("%s/errors/%s", HttpUtils.getBaseURL(), path));
    }

    public static <E extends Exception> ProblemType from(@NonNull final E e) {
        Class<? extends Exception> classeErro = e.getClass();
        return Stream.of(values()).filter(t -> t.getClasseErro().equals(classeErro)).findFirst().orElse(ERRO_SISTEMA);
    }

}
