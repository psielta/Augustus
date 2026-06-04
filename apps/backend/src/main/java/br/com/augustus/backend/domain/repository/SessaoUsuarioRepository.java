package br.com.augustus.backend.domain.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.augustus.backend.domain.model.entity.SessaoUsuario;

@Repository
public interface SessaoUsuarioRepository extends JpaRepository<SessaoUsuario, String> {

    Optional<SessaoUsuario> findByRefreshTokenHashAndRevogadoEmIsNull(String refreshTokenHash);

    Optional<SessaoUsuario> findByIdAndRevogadoEmIsNull(String id);

}
