package com.stockflow.nosql.config;

import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.stockflow.nosql.domain.document.AppUser;
import com.stockflow.nosql.domain.document.Product;
import com.stockflow.nosql.domain.document.StockMovement;
import com.stockflow.nosql.domain.enums.MovementType;
import com.stockflow.nosql.infrastructure.repository.AppUserRepository;
import com.stockflow.nosql.infrastructure.repository.ProductRepository;
import com.stockflow.nosql.infrastructure.repository.StockMovementRepository;

@Component
@Profile("dev")
public class DevelopmentDataSeeder implements CommandLineRunner {

    private final AppUserRepository appUserRepository;
    private final ProductRepository productRepository;
    private final StockMovementRepository stockMovementRepository;
    private final PasswordEncoder passwordEncoder;

    public DevelopmentDataSeeder(
            AppUserRepository appUserRepository,
            ProductRepository productRepository,
            StockMovementRepository stockMovementRepository,
            PasswordEncoder passwordEncoder) {
        this.appUserRepository = appUserRepository;
        this.productRepository = productRepository;
        this.stockMovementRepository = stockMovementRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (appUserRepository.count() > 0 || productRepository.count() > 0) {
            return;
        }

        final AppUser demoUser = new AppUser();
        demoUser.setFullName("Demo Operator");
        demoUser.setEmail("demo@stockflow.local");
        demoUser.setPasswordHash(passwordEncoder.encode("Password123!"));
        demoUser.setActive(true);
        demoUser.setCreatedAtUtc(Instant.now());
        final AppUser savedUser = appUserRepository.save(demoUser);

        final List<Product> products = new ArrayList<>();
        products.add(createProduct("Bluetooth Headset", "ELEC-1001", "Electronics", 129.90, "Warehouse A / Shelf 1"));
        products.add(createProduct("Wireless Mouse", "ELEC-1002", "Electronics", 89.50, "Warehouse A / Shelf 2"));
        products.add(createProduct("Printer Paper A4", "OFF-2001", "Office Supplies", 24.90, "Warehouse B / Rack 4"));
        products.add(createProduct("Whiteboard Marker Set", "OFF-2002", "Office Supplies", 19.90, "Warehouse B / Rack 1"));
        products.add(createProduct("Surface Cleaner", "CLN-3001", "Cleaning", 14.75, "Warehouse C / Zone 3"));

        final List<Product> savedProducts = productRepository.saveAll(products);
        final Map<String, Product> bySku = new LinkedHashMap<>();
        for (Product product : savedProducts) {
            bySku.put(product.getSku(), product);
        }

        final List<StockMovement> movements = new ArrayList<>();
        movements.add(applyMovement(bySku.get("ELEC-1001"), MovementType.ENTRY, 25, "Initial stock", savedUser.getId(), 10));
        movements.add(applyMovement(bySku.get("ELEC-1001"), MovementType.EXIT, 4, "Store transfer", savedUser.getId(), 9));
        movements.add(applyMovement(bySku.get("ELEC-1002"), MovementType.ENTRY, 40, "Initial stock", savedUser.getId(), 8));
        movements.add(applyMovement(bySku.get("ELEC-1002"), MovementType.EXIT, 7, "Online orders", savedUser.getId(), 7));
        movements.add(applyMovement(bySku.get("OFF-2001"), MovementType.ENTRY, 100, "Initial stock", savedUser.getId(), 6));
        movements.add(applyMovement(bySku.get("OFF-2001"), MovementType.EXIT, 12, "Office replenishment", savedUser.getId(), 5));
        movements.add(applyMovement(bySku.get("OFF-2002"), MovementType.ENTRY, 30, "Initial stock", savedUser.getId(), 4));
        movements.add(applyMovement(bySku.get("OFF-2002"), MovementType.EXIT, 5, "Usage", savedUser.getId(), 3));
        movements.add(applyMovement(bySku.get("CLN-3001"), MovementType.ENTRY, 60, "Initial stock", savedUser.getId(), 2));
        movements.add(applyMovement(bySku.get("CLN-3001"), MovementType.EXIT, 10, "Janitorial refill", savedUser.getId(), 1));

        stockMovementRepository.saveAll(movements);
        productRepository.saveAll(savedProducts);
    }

    private Product createProduct(String name, String sku, String categoryName, double unitPrice, String location) {
        final Product product = new Product();
        product.setName(name);
        product.setSku(sku);
        product.setCategoryName(categoryName);
        product.setUnitPrice(unitPrice);
        product.setActive(true);
        product.setCurrentBalance(0);
        product.setLocation(location);
        product.setCreatedAtUtc(Instant.now());
        return product;
    }

    private StockMovement applyMovement(
            Product product,
            MovementType type,
            int quantity,
            String reason,
            String performedByUserId,
            long hoursAgo) {
        if (type == MovementType.ENTRY) {
            product.setCurrentBalance(product.getCurrentBalance() + quantity);
        } else {
            product.setCurrentBalance(product.getCurrentBalance() - quantity);
        }

        final StockMovement movement = new StockMovement();
        movement.setProductId(product.getId());
        movement.setType(type);
        movement.setQuantity(quantity);
        movement.setReason(reason);
        movement.setPerformedByUserId(performedByUserId);
        movement.setOccurredAtUtc(Instant.now().minusSeconds(hoursAgo * 3600));
        return movement;
    }
}
