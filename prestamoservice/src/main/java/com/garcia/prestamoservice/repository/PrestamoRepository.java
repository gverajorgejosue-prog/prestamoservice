package com.garcia.prestamoservice.repository;

import com.garcia.prestamoservice.entity.Prestamo;
import com.garcia.prestamoservice.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PrestamoRepository extends JpaRepository<Prestamo, Long> {
    List<Prestamo> findByUsuarioOrderByFechaPrestamoDesc(Usuario usuario);
    Optional<Prestamo> findByIdAndUsuario(Long id, Usuario usuario);
}
