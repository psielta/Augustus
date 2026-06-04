package br.com.augustus.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;

@SpringBootApplication(exclude = UserDetailsServiceAutoConfiguration.class)
public class AugustusBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(AugustusBackendApplication.class, args);
    }
}
