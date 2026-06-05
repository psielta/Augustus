package br.com.augustus.backend.api.exceptionhandler;

import java.time.Instant;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import br.com.augustus.backend.domain.service.exception.CampoInvalidoException;
import br.com.augustus.backend.domain.service.exception.CaptchaException;
import br.com.augustus.backend.domain.service.exception.CategoriaJaExisteException;
import br.com.augustus.backend.domain.service.exception.CredenciaisInvalidasException;
import br.com.augustus.backend.domain.service.exception.EmailJaCadastradoException;
import br.com.augustus.backend.domain.service.exception.EmailNaoVerificadoException;
import br.com.augustus.backend.domain.service.exception.EnvioEmailFalhouException;
import br.com.augustus.backend.domain.service.exception.EntidadeNaoEncontradaException;
import br.com.augustus.backend.domain.service.exception.ErroInternoSistemaException;
import br.com.augustus.backend.domain.service.exception.EstruturaInconsistenteException;
import br.com.augustus.backend.domain.service.exception.NaoAutenticadoException;
import br.com.augustus.backend.domain.service.exception.RefreshTokenInvalidoException;
import br.com.augustus.backend.domain.service.exception.TokenVerificacaoInvalidoException;
import br.com.augustus.backend.domain.service.exception.UsuarioBloqueadoException;
import br.com.augustus.backend.domain.service.exception.ValidacaoException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestControllerAdvice
public class ApiExceptionHandler extends ResponseEntityExceptionHandler {

    @Override
    protected ResponseEntity<Object> handleExceptionInternal(@NonNull Exception ex, @Nullable Object body, @NonNull HttpHeaders headers,
            @NonNull HttpStatusCode statusCode, @NonNull WebRequest request) {
        if (statusCode.is5xxServerError()) {
            log.error("Erro interno: ", ex);
        } else {
            log.debug("Erro cliente [{}]: {} | URI: {}",
                     statusCode.value(),
                     ex.getMessage(),
                     request.getDescription(false));
        }
        return super.handleExceptionInternal(ex, body, headers, statusCode, request);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<Object> handleMethodArgumentTypeMismatchException(MethodArgumentTypeMismatchException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        ProblemDetail problemDetail = createProblem(ex, status);
        problemDetail.setDetail(String.format("Parâmetro inválido [%s: %s] ", ex.getPropertyName(), ex.getValue()));
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(@NonNull MethodArgumentNotValidException ex,
            @NonNull HttpHeaders headers, @NonNull HttpStatusCode status, @NonNull WebRequest request) {
        HttpStatus httpStatus = HttpStatus.BAD_REQUEST;
        log.debug("Validação falhou: {} campos inválidos | URI: {}",
                 ex.getBindingResult().getErrorCount(),
                 request.getDescription(false));
        ProblemDetail problemDetail = createProblem(ex, httpStatus);
        problemDetail.setTitle("Campos inválidos.");
        StringBuilder detailMessage = new StringBuilder("Um ou mais campos são inválidos - ");
        ex.getBindingResult().getFieldErrors().forEach(error ->
            detailMessage.append(String.format("[%s: %s] ", error.getField(), error.getDefaultMessage()))
        );
        problemDetail.setDetail(detailMessage.toString());
        return handleExceptionInternal(ex, problemDetail, headers, httpStatus, request);
    }

    @ExceptionHandler(ValidacaoException.class)
    ResponseEntity<Object> handleNegocioException(ValidacaoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.UNPROCESSABLE_ENTITY;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(CaptchaException.class)
    ResponseEntity<Object> handleCaptchaException(CaptchaException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        log.warn("Captcha inválido: {} | URI: {}", ex.getMessage(), request.getDescription(false));
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(CampoInvalidoException.class)
    ResponseEntity<Object> handleCampoInvalidoException(CampoInvalidoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(EntidadeNaoEncontradaException.class)
    public ResponseEntity<Object> handleEntidadeNaoEncontradaException(EntidadeNaoEncontradaException ex, WebRequest request) {
        HttpStatus status = HttpStatus.NOT_FOUND;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(EmailJaCadastradoException.class)
    public ResponseEntity<Object> handleEmailJaCadastradoException(EmailJaCadastradoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.CONFLICT;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(CategoriaJaExisteException.class)
    public ResponseEntity<Object> handleCategoriaJaExisteException(CategoriaJaExisteException ex, WebRequest request) {
        HttpStatus status = HttpStatus.CONFLICT;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(EmailNaoVerificadoException.class)
    public ResponseEntity<Object> handleEmailNaoVerificadoException(EmailNaoVerificadoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.FORBIDDEN;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(CredenciaisInvalidasException.class)
    public ResponseEntity<Object> handleCredenciaisInvalidasException(CredenciaisInvalidasException ex, WebRequest request) {
        HttpStatus status = HttpStatus.UNAUTHORIZED;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(UsuarioBloqueadoException.class)
    public ResponseEntity<Object> handleUsuarioBloqueadoException(UsuarioBloqueadoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.LOCKED;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(RefreshTokenInvalidoException.class)
    public ResponseEntity<Object> handleRefreshTokenInvalidoException(RefreshTokenInvalidoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.UNAUTHORIZED;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(TokenVerificacaoInvalidoException.class)
    public ResponseEntity<Object> handleTokenVerificacaoInvalidoException(TokenVerificacaoInvalidoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(NaoAutenticadoException.class)
    public ResponseEntity<Object> handleNaoAutenticadoException(NaoAutenticadoException ex, WebRequest request) {
        HttpStatus status = HttpStatus.UNAUTHORIZED;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(EnvioEmailFalhouException.class)
    public ResponseEntity<Object> handleEnvioEmailFalhouException(EnvioEmailFalhouException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_GATEWAY;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(EstruturaInconsistenteException.class)
    ResponseEntity<Object> handleEstruturaInconsistenteException(EstruturaInconsistenteException ex, WebRequest request) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        log.warn("Estrutura inválida: {} | URI: {}", ex.getMessage(), request.getDescription(false));
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    @ExceptionHandler(ErroInternoSistemaException.class)
    ResponseEntity<Object> handleErroInternoSistemaException(ErroInternoSistemaException ex, WebRequest request) {
        return handleGenericException(ex, request);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<Object> handleGenericException(Exception ex, WebRequest request) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        ProblemDetail problemDetail = createProblem(ex, status);
        return handleExceptionInternal(ex, problemDetail, new HttpHeaders(), status, request);
    }

    private static <E extends Exception> ProblemDetail createProblem(E ex, HttpStatus status) {
        ProblemType type = ProblemType.from(ex);
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(status, ex.getMessage());
        problemDetail.setType(type.getURI());
        problemDetail.setTitle(type.getTitulo());
        problemDetail.setProperty("timestamp", Instant.now());
        return problemDetail;
    }

}
