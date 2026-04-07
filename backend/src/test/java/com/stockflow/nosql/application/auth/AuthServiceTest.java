package com.stockflow.nosql.application.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import com.stockflow.nosql.application.auth.contracts.LoginRequest;
import com.stockflow.nosql.application.auth.contracts.RegisterRequest;
import com.stockflow.nosql.domain.document.AppUser;
import com.stockflow.nosql.infrastructure.repository.AppUserRepository;
import com.stockflow.nosql.infrastructure.security.JwtTokenProvider;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AppUserRepository appUserRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(appUserRepository, passwordEncoder, jwtTokenProvider);
    }

    @Test
    void register_throws_when_email_already_exists() {
        when(appUserRepository.existsByEmail("existing@stockflow.local")).thenReturn(true);

        final ResponseStatusException exception = assertThrows(ResponseStatusException.class, () ->
                authService.register(new RegisterRequest("Existing User", "existing@stockflow.local", "Password123!")));

        assertEquals("Email is already registered.", exception.getReason());
    }

    @Test
    void login_throws_when_email_not_found() {
        when(appUserRepository.findByEmail("missing@stockflow.local")).thenReturn(Optional.empty());

        final ResponseStatusException exception = assertThrows(ResponseStatusException.class, () ->
                authService.login(new LoginRequest("missing@stockflow.local", "Password123!")));

        assertEquals("Invalid email or password.", exception.getReason());
    }

    @Test
    void login_throws_when_password_is_wrong() {
        final AppUser user = new AppUser();
        user.setEmail("demo@stockflow.local");
        user.setPasswordHash("encoded-password");
        user.setActive(true);

        when(appUserRepository.findByEmail("demo@stockflow.local")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("WrongPassword", "encoded-password")).thenReturn(false);

        final ResponseStatusException exception = assertThrows(ResponseStatusException.class, () ->
                authService.login(new LoginRequest("demo@stockflow.local", "WrongPassword")));

        assertEquals("Invalid email or password.", exception.getReason());
    }
}
