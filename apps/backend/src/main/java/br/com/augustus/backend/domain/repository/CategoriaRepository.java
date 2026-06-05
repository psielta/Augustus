package br.com.augustus.backend.domain.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import br.com.augustus.backend.domain.model.entity.Categoria;
import br.com.augustus.backend.domain.model.enumeration.TipoCategoria;

public interface CategoriaRepository extends JpaRepository<Categoria, String> {

    List<Categoria> findByUsuario_IdOrderByTipoAscOrdemAscNomeAsc(String usuarioId);

    Optional<Categoria> findByIdAndUsuario_Id(String id, String usuarioId);

    boolean existsByUsuario_IdAndTipoAndNomeIgnoreCase(String usuarioId, TipoCategoria tipo, String nome);

    boolean existsByUsuario_IdAndTipoAndNomeIgnoreCaseAndIdNot(String usuarioId, TipoCategoria tipo, String nome, String id);

    boolean existsByUsuario_IdAndCategoriaPaiId(String usuarioId, String categoriaPaiId);

    boolean existsByUsuario_IdAndTemplateCodigo(String usuarioId, String templateCodigo);

}