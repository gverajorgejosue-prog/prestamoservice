package com.garcia.prestamoservice.controller;

import com.garcia.prestamoservice.dto.PrestamoRequest;
import com.garcia.prestamoservice.dto.PrestamoResponse;
import com.garcia.prestamoservice.dto.ResumenResponse;
import com.garcia.prestamoservice.service.PrestamoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/prestamos")
@RequiredArgsConstructor
public class PrestamoController {

    private final PrestamoService prestamoService;

    @GetMapping
    public ResponseEntity<List<PrestamoResponse>> getAll() {
        return ResponseEntity.ok(prestamoService.getAllForCurrentUser());
    }

    @GetMapping("/resumen")
    public ResponseEntity<ResumenResponse> getResumen() {
        return ResponseEntity.ok(prestamoService.getResumen());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PrestamoResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(prestamoService.getByIdForCurrentUser(id));
    }

    @PostMapping
    public ResponseEntity<PrestamoResponse> create(@Valid @RequestBody PrestamoRequest request) {
        PrestamoResponse response = prestamoService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<PrestamoResponse> update(@PathVariable Long id, @Valid @RequestBody PrestamoRequest request) {
        return ResponseEntity.ok(prestamoService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        prestamoService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
