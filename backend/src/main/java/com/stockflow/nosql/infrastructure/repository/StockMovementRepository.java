package com.stockflow.nosql.infrastructure.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.stockflow.nosql.domain.document.StockMovement;

public interface StockMovementRepository extends MongoRepository<StockMovement, String> {
    List<StockMovement> findByProductIdOrderByOccurredAtUtcDesc(String productId);
}
