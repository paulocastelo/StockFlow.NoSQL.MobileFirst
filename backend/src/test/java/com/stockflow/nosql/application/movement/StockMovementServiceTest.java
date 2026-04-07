package com.stockflow.nosql.application.movement;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

import com.stockflow.nosql.application.movement.contracts.CreateMovementRequest;
import com.stockflow.nosql.application.movement.contracts.MovementResponse;
import com.stockflow.nosql.domain.document.Product;
import com.stockflow.nosql.domain.document.StockMovement;
import com.stockflow.nosql.domain.enums.MovementType;
import com.stockflow.nosql.infrastructure.repository.ProductRepository;
import com.stockflow.nosql.infrastructure.repository.StockMovementRepository;

@ExtendWith(MockitoExtension.class)
class StockMovementServiceTest {

    @Mock
    private StockMovementRepository stockMovementRepository;

    @Mock
    private ProductRepository productRepository;

    private StockMovementService stockMovementService;

    @BeforeEach
    void setUp() {
        stockMovementService = new StockMovementService(stockMovementRepository, productRepository);
    }

    @Test
    void create_entry_increases_balance() {
        final Product product = createProduct(10);
        when(productRepository.findById("product-1")).thenReturn(Optional.of(product));
        when(stockMovementRepository.save(any(StockMovement.class))).thenAnswer(invocation -> {
            final StockMovement movement = invocation.getArgument(0);
            movement.setId("movement-1");
            return movement;
        });
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        final MovementResponse response = stockMovementService.create(
                new CreateMovementRequest("product-1", MovementType.ENTRY, 5, "Restock", "user-1"),
                "user-1");

        assertEquals(15, product.getCurrentBalance());
        assertEquals(5, response.quantity());
        assertEquals(MovementType.ENTRY, response.type());
    }

    @Test
    void create_exit_decreases_balance() {
        final Product product = createProduct(10);
        when(productRepository.findById("product-1")).thenReturn(Optional.of(product));
        when(stockMovementRepository.save(any(StockMovement.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        stockMovementService.create(
                new CreateMovementRequest("product-1", MovementType.EXIT, 3, "Sale", "user-1"),
                "user-1");

        assertEquals(7, product.getCurrentBalance());
    }

    @Test
    void create_exit_throws_when_insufficient_balance() {
        final Product product = createProduct(2);
        when(productRepository.findById("product-1")).thenReturn(Optional.of(product));

        final ResponseStatusException exception = assertThrows(ResponseStatusException.class, () ->
                stockMovementService.create(
                        new CreateMovementRequest("product-1", MovementType.EXIT, 5, "Sale", "user-1"),
                        "user-1"));

        assertEquals("Insufficient stock balance.", exception.getReason());
    }

    @Test
    void create_exit_with_exact_balance_succeeds() {
        final Product product = createProduct(5);
        when(productRepository.findById("product-1")).thenReturn(Optional.of(product));
        when(stockMovementRepository.save(any(StockMovement.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        stockMovementService.create(
                new CreateMovementRequest("product-1", MovementType.EXIT, 5, "Sale", "user-1"),
                "user-1");

        assertEquals(0, product.getCurrentBalance());
    }

    private Product createProduct(int currentBalance) {
        final Product product = new Product();
        product.setId("product-1");
        product.setName("Test Product");
        product.setCurrentBalance(currentBalance);
        product.setActive(true);
        return product;
    }
}
