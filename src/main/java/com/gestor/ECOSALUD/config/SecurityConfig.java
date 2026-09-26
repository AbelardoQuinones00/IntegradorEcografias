package com.gestor.ECOSALUD.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Configuracion de seguridad TEMPORAL.
 * <p>
 * Al incluir spring-boot-starter-security, Spring Security bloquea por defecto
 * todas las rutas detras de un login autogenerado. Mientras se termina el
 * modulo real de Usuarios / Roles / Permisos (administracion/*.html), esta
 * clase deja todo el sitio abierto para poder navegar y revisar las 25 vistas.
 * <p>
 * IMPORTANTE: reemplazar esta configuracion antes de pasar a produccion.
 */
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
            .csrf(csrf -> csrf.disable())
            .headers(headers -> headers.frameOptions(frame -> frame.disable()));
        return http.build();
    }
}
