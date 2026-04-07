package com.stockflow.nosql.application.product.contracts;

public record ProductResponse(
        String id,
        String name,
        String sku,
        String categoryName,
        double unitPrice,
        boolean isActive,
        int currentBalance,
        String location
) {
}
