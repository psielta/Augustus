package br.com.augustus.backend.domain.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.augustus.backend.domain.model.entity.CategoriaTemplate;

public interface CategoriaTemplateRepository extends JpaRepository<CategoriaTemplate, String> {

    List<CategoriaTemplate> findByAtivoTrueOrderByTipoAscOrdemAsc();

}