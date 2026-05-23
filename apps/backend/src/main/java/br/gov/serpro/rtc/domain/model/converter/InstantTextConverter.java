package br.gov.serpro.rtc.domain.model.converter;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class InstantTextConverter implements AttributeConverter<Instant, String> {

    @Override
    public String convertToDatabaseColumn(Instant attribute) {
        return attribute == null ? null : DateTimeFormatter.ISO_INSTANT.format(attribute);
    }

    @Override
    public Instant convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) {
            return null;
        }
        try {
            return Instant.parse(dbData);
        } catch (RuntimeException ex) {
            return LocalDateTime.parse(dbData, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                    .toInstant(ZoneOffset.UTC);
        }
    }

}
