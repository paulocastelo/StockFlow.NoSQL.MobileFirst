package com.stockflow.nosql.application.movement;

import java.time.Instant;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.stockflow.nosql.application.movement.contracts.BalanceResponse;
import com.stockflow.nosql.application.movement.contracts.CreateMovementRequest;
import com.stockflow.nosql.application.movement.contracts.MovementResponse;
import com.stockflow.nosql.domain.document.Product;
import com.stockflow.nosql.domain.document.StockMovement;
import com.stockflow.nosql.domain.enums.MovementType;
import com.stockflow.nosql.infrastructure.repository.ProductRepository;
import com.stockflow.nosql.infrastructure.repository.StockMovementRepository;

@Service
public class StockMovementService {

    private final StockMovementRepository stockMovementRepository;
    private final ProductRepository productRepository;

    public StockMovementService(
            StockMovementRepository stockMovementRepository,
            ProductRepository productRepository) {
        this.stockMovementRepository = stockMovementRepository;
        this.productRepository = productRepository;
    }

    public MovementResponse create(CreateMovementRequest request, String performedByUserId) {
        if (request.quantity() <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Quantity must be greater than zero.");
        }

        final Product product = productRepository.findById(request.productId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found."));

        if (request.type() == MovementType.EXIT && product.getCurrentBalance() < request.quantity()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Insufficient stock balance.");
        }

        final StockMovement movement = new StockMovement();
        movement.setProductId(product.getId());
        movement.setType(request.type());
        movement.setQuantity(request.quantity());
        movement.setReason(request.reason());
        movement.setPerformedByUserId(resolvePerformedByUserId(request, performedByUserId));
        movement.setOccurredAtUtc(Instant.now());

        if (request.type() == MovementType.ENTRY) {
            product.setCurrentBalance(product.getCurrentBalance() + request.quantity());
        } else {
            product.setCurrentBalance(product.getCurrentBalance() - request.quantity());
        }

        final StockMovement savedMovement = stockMovementRepository.save(movement);
        productRepository.save(product);

        return toResponse(savedMovement);
    }

    public List<MovementResponse> findByProductId(String productId) {
        ensureProductExists(productId);
        return stockMovementRepository.findByProductIdOrderByOccurredAtUtcDesc(productId).stream()
                .map(this::toResponse)
                .toList();
    }

    public BalanceResponse getBalance(String productId) {
        final Product product = ensureProductExists(productId);
        return new BalanceResponse(productId, product.getCurrentBalance());
    }

    private Product ensureProductExists(String productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found."));
    }

    private String resolvePerformedByUserId(CreateMovementRequest request, String performedByUserId) {
        if (performedByUserId != null && !performedByUserId.isBlank()) {
            return performedByUserId;
        }
        return request.performedByUserId();
    }

    private MovementResponse toResponse(StockMovement movement) {
        return new MovementResponse(
                movement.getId(),
                movement.getProductId(),
                movement.getType(),
                movement.getQuantity(),
                movement.getReason(),
                movement.getPerformedByUserId(),
                movement.getOccurredAtUtc().toString());
    }
}
