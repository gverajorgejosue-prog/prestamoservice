package com.garcia.prestamoservice.dto;

import com.garcia.prestamoservice.entity.Prestamo;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PrestamoResponse {

    private Long id;
    private String cliente;
    private String dni;
    private BigDecimal monto;
    private BigDecimal interes;
    private BigDecimal totalCobrar;
    private LocalDate fechaPrestamo;
    private LocalDate fechaVencimiento;
    private Boolean pagado;

    public static PrestamoResponse from(Prestamo prestamo) {
        BigDecimal monto = prestamo.getMonto();
        BigDecimal interes = prestamo.getInteres() == null ? BigDecimal.ZERO : prestamo.getInteres();
        BigDecimal totalCobrar = monto.add(monto.multiply(interes.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP)))
                .setScale(2, RoundingMode.HALF_UP);
        return new PrestamoResponse(
                prestamo.getId(),
                prestamo.getCliente(),
                prestamo.getDni(),
                monto,
                interes.setScale(2, RoundingMode.HALF_UP),
                totalCobrar,
                prestamo.getFechaPrestamo(),
                prestamo.getFechaVencimiento(),
                Boolean.TRUE.equals(prestamo.getPagado())
        );
    }
}
