package com.stockflow.nosql.api;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.stockflow.nosql.application.movement.StockMovementService;
import com.stockflow.nosql.application.movement.contracts.BalanceResponse;
import com.stockflow.nosql.application.movement.contracts.CreateMovementRequest;
import com.stockflow.nosql.application.movement.contracts.MovementResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/stock-movements")
public class StockMovementController {

    private final StockMovementService stockMovementService;

    public StockMovementController(StockMovementService stockMovementService) {
        this.stockMovementService = stockMovementService;
    }

    @PostMapping
    public ResponseEntity<MovementResponse> create(
            @Valid @RequestBody CreateMovementRequest request,
            HttpServletRequest httpRequest) {
        final String authenticatedUserId = (String) httpRequest.getAttribute("authenticatedUserId");
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(stockMovementService.create(request, authenticatedUserId));
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<MovementResponse>> findByProductId(@PathVariable String productId) {
        return ResponseEntity.ok(stockMovementService.findByProductId(productId));
    }

    @GetMapping("/product/{productId}/balance")
    public ResponseEntity<BalanceResponse> getBalance(@PathVariable String productId) {
        return ResponseEntity.ok(stockMovementService.getBalance(productId));
    }
}
