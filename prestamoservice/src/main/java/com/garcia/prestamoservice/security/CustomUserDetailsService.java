package com.garcia.prestamoservice.security;

import com.garcia.prestamoservice.entity.Usuario;
import com.garcia.prestamoservice.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Usuario usuario = usuarioRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado: " + username));
        String role = usuario.getRol() == null || usuario.getRol().isBlank() ? "USER" : usuario.getRol();
        return new User(usuario.getEmail(), usuario.getPassword(), List.of(new SimpleGrantedAuthority("ROLE_" + role)));
    }
}
