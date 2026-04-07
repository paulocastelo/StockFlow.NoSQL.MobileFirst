package com.stockflow.nosql.application.auth;

import java.time.Instant;
import java.util.Locale;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.stockflow.nosql.application.auth.contracts.AuthResponse;
import com.stockflow.nosql.application.auth.contracts.LoginRequest;
import com.stockflow.nosql.application.auth.contracts.RegisterRequest;
import com.stockflow.nosql.application.auth.contracts.UserProfileResponse;
import com.stockflow.nosql.domain.document.AppUser;
import com.stockflow.nosql.infrastructure.repository.AppUserRepository;
import com.stockflow.nosql.infrastructure.security.JwtTokenProvider;

@Service
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(
            AppUserRepository appUserRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider jwtTokenProvider) {
        this.appUserRepository = appUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public UserProfileResponse register(RegisterRequest request) {
        final String normalizedEmail = normalizeEmail(request.email());
        if (appUserRepository.existsByEmail(normalizedEmail)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email is already registered.");
        }

        final AppUser user = new AppUser();
        user.setFullName(request.fullName().trim());
        user.setEmail(normalizedEmail);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setActive(true);
        user.setCreatedAtUtc(Instant.now());

        final AppUser savedUser = appUserRepository.save(user);
        return toUserProfile(savedUser);
    }

    public AuthResponse login(LoginRequest request) {
        final String normalizedEmail = normalizeEmail(request.email());
        final AppUser user = appUserRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password."));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password.");
        }

        if (!user.isActive()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User account is inactive.");
        }

        final String token = jwtTokenProvider.generateToken(user);
        return new AuthResponse(token, jwtTokenProvider.getExpiresAt(token).toString(), toUserProfile(user));
    }

    private UserProfileResponse toUserProfile(AppUser user) {
        return new UserProfileResponse(user.getId(), user.getFullName(), user.getEmail(), user.isActive());
    }

    private String normalizeEmail(String email) {
        return email == null ? "" : email.trim().toLowerCase(Locale.ROOT);
    }
}
