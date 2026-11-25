package com.garcia.prestamoservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResumenResponse {
    private BigDecimal capitalPrestado;
    private BigDecimal totalPorCobrar;
    private BigDecimal gananciaEsperada;
    private Long cantidadPendientes;
    private Long cantidadCobrados;
}
