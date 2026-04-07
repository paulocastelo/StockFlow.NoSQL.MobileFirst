package com.stockflow.nosql.infrastructure.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.stockflow.nosql.domain.document.Product;

public interface ProductRepository extends MongoRepository<Product, String> {
    Optional<Product> findBySku(String sku);
    boolean existsBySku(String sku);
    List<Product> findByIsActiveTrue();
}
