package com.stockflow.nosql.application.movement.contracts;

import com.stockflow.nosql.domain.enums.MovementType;

public record MovementResponse(
        String id,
        String productId,
        MovementType type,
        int quantity,
        String reason,
        String performedByUserId,
        String occurredAtUtc
) {
}
