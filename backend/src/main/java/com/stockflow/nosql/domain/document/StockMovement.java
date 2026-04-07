package com.stockflow.nosql.domain.document;

import java.time.Instant;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import com.stockflow.nosql.domain.enums.MovementType;

@Document(collection = "stock_movements")
public class StockMovement {

    @Id
    private String id;
    private String productId;
    private MovementType type;
    private int quantity;
    private String reason;
    private String performedByUserId;
    private Instant occurredAtUtc;

    public StockMovement() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public MovementType getType() {
        return type;
    }

    public void setType(MovementType type) {
        this.type = type;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getPerformedByUserId() {
        return performedByUserId;
    }

    public void setPerformedByUserId(String performedByUserId) {
        this.performedByUserId = performedByUserId;
    }

    public Instant getOccurredAtUtc() {
        return occurredAtUtc;
    }

    public void setOccurredAtUtc(Instant occurredAtUtc) {
        this.occurredAtUtc = occurredAtUtc;
    }
}
