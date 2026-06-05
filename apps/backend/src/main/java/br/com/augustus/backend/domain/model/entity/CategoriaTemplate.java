package br.com.augustus.backend.domain.model.entity;

import java.time.Instant;

import br.com.augustus.backend.domain.model.enumeration.TipoCategoria;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Data
@Entity
@Table(name = "categoria_template")
public class CategoriaTemplate {

    @EqualsAndHashCode.Include
    @Id
    @Column(name = "codigo")
    private String codigo;

    @Column(name = "nome", nullable = false)
    private String nome;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false)
    private TipoCategoria tipo;

    @Column(name = "cor_hex")
    private String corHex;

    @Column(name = "icone")
    private String icone;

    @Column(name = "ordem", nullable = false)
    private Integer ordem;

    @Column(name = "ativo", nullable = false)
    private Boolean ativo;

    @Column(name = "criado_em", nullable = false)
    private Instant criadoEm;

}