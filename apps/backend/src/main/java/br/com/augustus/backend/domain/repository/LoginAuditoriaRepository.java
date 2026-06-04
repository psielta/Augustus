package br.com.augustus.backend.domain.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.augustus.backend.domain.model.entity.LoginAuditoria;

@Repository
public interface LoginAuditoriaRepository extends JpaRepository<LoginAuditoria, String> {
}
