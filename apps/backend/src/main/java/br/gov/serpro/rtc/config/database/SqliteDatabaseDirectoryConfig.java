package br.gov.serpro.rtc.config.database;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.flywaydb.core.api.configuration.FluentConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.flyway.FlywayConfigurationCustomizer;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnClass(FluentConfiguration.class)
public class SqliteDatabaseDirectoryConfig {

    @Bean
    FlywayConfigurationCustomizer sqliteDatabaseDirectoryCustomizer(DataSourceProperties dataSourceProperties) {
        return configuration -> criarDiretorioPaiSqlite(dataSourceProperties.getUrl());
    }

    private void criarDiretorioPaiSqlite(String url) {
        if (url == null || !url.startsWith("jdbc:sqlite:file:")) {
            return;
        }
        String pathValue = url.substring("jdbc:sqlite:file:".length());
        int queryIndex = pathValue.indexOf('?');
        if (queryIndex >= 0) {
            pathValue = pathValue.substring(0, queryIndex);
        }
        Path parent = Path.of(pathValue).toAbsolutePath().normalize().getParent();
        if (parent == null) {
            return;
        }
        try {
            Files.createDirectories(parent);
        } catch (IOException ex) {
            throw new IllegalStateException("Nao foi possivel criar o diretorio do banco SQLite: " + parent, ex);
        }
    }

}
