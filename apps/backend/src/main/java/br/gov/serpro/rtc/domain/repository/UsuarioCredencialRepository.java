package br.gov.serpro.rtc.domain.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.gov.serpro.rtc.domain.model.entity.UsuarioCredencial;

@Repository
public interface UsuarioCredencialRepository extends JpaRepository<UsuarioCredencial, String> {
}
