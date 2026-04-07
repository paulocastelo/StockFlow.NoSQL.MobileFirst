package com.stockflow.nosql.application.auth.contracts;

public record UserProfileResponse(
        String id,
        String fullName,
        String email,
        boolean isActive
) {
}
