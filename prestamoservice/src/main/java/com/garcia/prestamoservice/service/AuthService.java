package com.garcia.prestamoservice.service;

import com.garcia.prestamoservice.dto.AuthResponse;
import com.garcia.prestamoservice.dto.LoginRequest;
import com.garcia.prestamoservice.dto.RegisterRequest;
import com.garcia.prestamoservice.entity.Usuario;
import com.garcia.prestamoservice.exception.ApiException;
import com.garcia.prestamoservice.repository.UsuarioRepository;
import com.garcia.prestamoservice.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        if (usuarioRepository.existsByEmail(request.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "El email ya está registrado");
        }

        Usuario usuario = Usuario.builder()
                .nombre(request.getNombre())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .rol("USER")
                .build();
        Usuario saved = usuarioRepository.save(usuario);

        UserDetails userDetails = new User(saved.getEmail(), saved.getPassword(), List.of());
        String token = jwtService.generateToken(userDetails);
        return new AuthResponse(token, saved.getEmail(), saved.getNombre());
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        Usuario usuario = usuarioRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Credenciales inválidas"));
        UserDetails userDetails = new User(usuario.getEmail(), usuario.getPassword(), List.of());
        String token = jwtService.generateToken(userDetails);
        return new AuthResponse(token, usuario.getEmail(), usuario.getNombre());
    }
}
