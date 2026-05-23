package br.gov.serpro.rtc.config.security;

import static org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON_VALUE;

import java.io.IOException;
import java.time.Instant;
import java.net.URI;

import org.springframework.boot.actuate.autoconfigure.security.servlet.EndpointRequest;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
@EnableConfigurationProperties(AuthProperties.class)
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final ObjectMapper objectMapper;

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .formLogin(AbstractHttpConfigurer::disable)
                .logout(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .exceptionHandling(exceptions -> exceptions
                        .authenticationEntryPoint((request, response, ex) ->
                                escreverProblem(response, HttpStatus.UNAUTHORIZED, "Nao autenticado", "Autenticacao obrigatoria."))
                        .accessDeniedHandler((request, response, ex) ->
                                escreverProblem(response, HttpStatus.FORBIDDEN, "Acesso negado", "Acesso negado.")))
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(EndpointRequest.toAnyEndpoint()).permitAll()
                        .requestMatchers("/calculadora/**", "/dados-abertos/**", "/versao/**").permitAll()
                        .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/api-docs/**", "/v3/api-docs/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/auth/register", "/auth/login", "/auth/refresh",
                                "/auth/verify-email", "/auth/resend-verification").permitAll()
                        .requestMatchers(HttpMethod.GET, "/auth/verify-email").permitAll()
                        .requestMatchers("/auth/me", "/auth/logout").authenticated()
                        .anyRequest().permitAll())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    private void escreverProblem(jakarta.servlet.http.HttpServletResponse response, HttpStatus status, String title,
            String detail) throws IOException {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(status, detail);
        problemDetail.setType(URI.create("about:blank"));
        problemDetail.setTitle(title);
        problemDetail.setProperty("timestamp", Instant.now());

        response.setStatus(status.value());
        response.setContentType(APPLICATION_PROBLEM_JSON_VALUE);
        objectMapper.writeValue(response.getOutputStream(), problemDetail);
    }

}
