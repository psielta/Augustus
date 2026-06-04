package br.com.augustus.backend.domain.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.augustus.backend.domain.model.entity.Usuario;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, String> {

    Optional<Usuario> findByEmailNormalizado(String emailNormalizado);

    boolean existsByEmailNormalizado(String emailNormalizado);

}
