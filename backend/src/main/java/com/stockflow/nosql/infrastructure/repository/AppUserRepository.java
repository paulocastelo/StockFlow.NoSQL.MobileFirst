package com.stockflow.nosql.infrastructure.repository;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.stockflow.nosql.domain.document.AppUser;

public interface AppUserRepository extends MongoRepository<AppUser, String> {
    Optional<AppUser> findByEmail(String email);
    boolean existsByEmail(String email);
}
