package com.stockflow.nosql.application.movement.contracts;

import com.stockflow.nosql.domain.enums.MovementType;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateMovementRequest(
        @NotBlank String productId,
        @NotNull MovementType type,
        @Min(1) int quantity,
        String reason,
        String performedByUserId
) {
}
