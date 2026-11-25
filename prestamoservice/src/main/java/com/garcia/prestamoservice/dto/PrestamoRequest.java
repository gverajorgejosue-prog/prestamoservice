package com.garcia.prestamoservice.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PrestamoRequest {

    @NotBlank(message = "El cliente es obligatorio")
    @Size(max = 100, message = "El cliente no puede superar los 100 caracteres")
    private String cliente;

    @NotBlank(message = "El DNI es obligatorio")
    @Pattern(regexp = "\\d{8}", message = "El DNI debe tener exactamente 8 dígitos")
    private String dni;

    @NotNull(message = "El monto es obligatorio")
    @DecimalMin(value = "0.01", message = "El monto debe ser mayor a 0")
    @Digits(integer = 8, fraction = 2, message = "El monto debe tener máximo 8 enteros y 2 decimales")
    private BigDecimal monto;

    @NotNull(message = "El interés es obligatorio")
    @DecimalMin(value = "0.00", message = "El interés no puede ser negativo")
    @Digits(integer = 3, fraction = 2, message = "El interés debe tener máximo 3 enteros y 2 decimales")
    private BigDecimal interes;

    @NotNull(message = "La fecha de vencimiento es obligatoria")
    private LocalDate fechaVencimiento;

    private Boolean pagado;
}
