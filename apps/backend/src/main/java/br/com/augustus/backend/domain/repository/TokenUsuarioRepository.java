package br.com.augustus.backend.domain.repository;

import java.time.Instant;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.augustus.backend.domain.model.entity.TokenUsuario;
import br.com.augustus.backend.domain.model.enumeration.TipoToken;

@Repository
public interface TokenUsuarioRepository extends JpaRepository<TokenUsuario, String> {

    Optional<TokenUsuario> findByTokenHashAndUsadoEmIsNull(String tokenHash);

    Optional<TokenUsuario> findFirstByUsuario_IdAndTipoOrderByCriadoEmDesc(String usuarioId, TipoToken tipo);

    @Modifying
    @Query("""
        update TokenUsuario t
           set t.usadoEm = :agora
         where t.usuario.id = :usuarioId
           and t.tipo = :tipo
           and t.usadoEm is null
        """)
    int invalidarPendentes(@Param("usuarioId") String usuarioId, @Param("tipo") TipoToken tipo, @Param("agora") Instant agora);

}
