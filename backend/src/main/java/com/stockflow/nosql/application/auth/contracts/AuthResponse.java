package com.stockflow.nosql.application.auth.contracts;

public record AuthResponse(
        String accessToken,
        String expiresAtUtc,
        UserProfileResponse user
) {
}
