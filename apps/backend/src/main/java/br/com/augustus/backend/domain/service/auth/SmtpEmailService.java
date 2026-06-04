package br.com.augustus.backend.domain.service.auth;

import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import br.com.augustus.backend.config.security.AuthProperties;
import br.com.augustus.backend.domain.service.exception.EnvioEmailFalhouException;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class SmtpEmailService implements EmailService {

    private final JavaMailSender javaMailSender;
    private final AuthProperties authProperties;

    @Override
    public void enviarVerificacao(String emailDestino, String linkVerificacao) {
        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
            String from = authProperties.getMail().getFrom();
            if (StringUtils.hasText(from)) {
                helper.setFrom(from);
            }
            helper.setTo(emailDestino);
            helper.setSubject("Verifique seu email no Augustus");
            helper.setText("""
                    Ola,

                    Para concluir seu cadastro no Augustus - Controlador de financas pessoais, acesse o link abaixo:

                    %s

                    Se voce nao solicitou este cadastro, ignore esta mensagem.
                    """.formatted(linkVerificacao), false);

            javaMailSender.send(message);
            log.info("Email de verificacao enviado para {} via {}", emailDestino, smtpAlvo());
        } catch (MessagingException | MailException ex) {
            log.warn("Falha ao enviar email de verificacao para {} via {}", emailDestino, smtpAlvo());
            throw new EnvioEmailFalhouException(ex);
        }
    }

    private String smtpAlvo() {
        if (javaMailSender instanceof JavaMailSenderImpl impl) {
            return "%s:%s usuario=%s".formatted(impl.getHost(), impl.getPort(), impl.getUsername());
        }
        return javaMailSender.getClass().getSimpleName();
    }

}
