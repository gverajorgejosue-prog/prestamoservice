package com.garcia.prestamoservice.service;

import com.garcia.prestamoservice.dto.PrestamoRequest;
import com.garcia.prestamoservice.dto.PrestamoResponse;
import com.garcia.prestamoservice.dto.ResumenResponse;
import com.garcia.prestamoservice.entity.Prestamo;
import com.garcia.prestamoservice.entity.Usuario;
import com.garcia.prestamoservice.exception.ApiException;
import com.garcia.prestamoservice.repository.PrestamoRepository;
import com.garcia.prestamoservice.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PrestamoService {

    private final PrestamoRepository prestamoRepository;
    private final UsuarioRepository usuarioRepository;

    public List<PrestamoResponse> getAllForCurrentUser() {
        Usuario usuario = getCurrentUser();
        return prestamoRepository.findByUsuarioOrderByFechaPrestamoDesc(usuario)
                .stream()
                .map(PrestamoResponse::from)
                .toList();
    }

    public PrestamoResponse getByIdForCurrentUser(Long id) {
        Usuario usuario = getCurrentUser();
        Prestamo prestamo = prestamoRepository.findByIdAndUsuario(id, usuario)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Préstamo no encontrado"));
        return PrestamoResponse.from(prestamo);
    }

    @Transactional
    public PrestamoResponse create(PrestamoRequest request) {
        Usuario usuario = getCurrentUser();
        Prestamo prestamo = Prestamo.builder()
                .cliente(request.getCliente())
                .dni(request.getDni())
                .monto(request.getMonto())
                .interes(request.getInteres())
                .fechaPrestamo(LocalDate.now())
                .fechaVencimiento(request.getFechaVencimiento())
                .pagado(Boolean.TRUE.equals(request.getPagado()))
                .usuario(usuario)
                .build();
        Prestamo saved = prestamoRepository.save(prestamo);
        return PrestamoResponse.from(saved);
    }

    @Transactional
    public PrestamoResponse update(Long id, PrestamoRequest request) {
        Usuario usuario = getCurrentUser();
        Prestamo prestamo = prestamoRepository.findByIdAndUsuario(id, usuario)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Préstamo no encontrado"));

        prestamo.setCliente(request.getCliente());
        prestamo.setDni(request.getDni());
        prestamo.setMonto(request.getMonto());
        prestamo.setInteres(request.getInteres());
        prestamo.setFechaVencimiento(request.getFechaVencimiento());
        if (request.getPagado() != null) {
            prestamo.setPagado(request.getPagado());
        }

        Prestamo saved = prestamoRepository.save(prestamo);
        return PrestamoResponse.from(saved);
    }

    @Transactional
    public void delete(Long id) {
        Usuario usuario = getCurrentUser();
        Prestamo prestamo = prestamoRepository.findByIdAndUsuario(id, usuario)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Préstamo no encontrado"));
        prestamoRepository.delete(prestamo);
    }

    public ResumenResponse getResumen() {
        Usuario usuario = getCurrentUser();
        List<Prestamo> prestamos = prestamoRepository.findByUsuarioOrderByFechaPrestamoDesc(usuario);

        BigDecimal capitalPrestado = BigDecimal.ZERO;
        BigDecimal totalPorCobrar = BigDecimal.ZERO;
        BigDecimal gananciaEsperada = BigDecimal.ZERO;
        long pendientes = 0;
        long cobrados = 0;

        for (Prestamo p : prestamos) {
            BigDecimal monto = p.getMonto() == null ? BigDecimal.ZERO : p.getMonto();
            BigDecimal interes = p.getInteres() == null ? BigDecimal.ZERO : p.getInteres();
            BigDecimal total = monto.add(monto.multiply(interes.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)))
                    .setScale(2, RoundingMode.HALF_UP);
            BigDecimal ganancia = total.subtract(monto).setScale(2, RoundingMode.HALF_UP);

            capitalPrestado = capitalPrestado.add(monto);
            totalPorCobrar = totalPorCobrar.add(total);
            gananciaEsperada = gananciaEsperada.add(ganancia);

            if (Boolean.TRUE.equals(p.getPagado())) {
                cobrados++;
            } else {
                pendientes++;
            }
        }

        return ResumenResponse.builder()
                .capitalPrestado(capitalPrestado.setScale(2, RoundingMode.HALF_UP))
                .totalPorCobrar(totalPorCobrar.setScale(2, RoundingMode.HALF_UP))
                .gananciaEsperada(gananciaEsperada.setScale(2, RoundingMode.HALF_UP))
                .cantidadPendientes(pendientes)
                .cantidadCobrados(cobrados)
                .build();
    }

    private Usuario getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Usuario no autenticado"));
    }
}
