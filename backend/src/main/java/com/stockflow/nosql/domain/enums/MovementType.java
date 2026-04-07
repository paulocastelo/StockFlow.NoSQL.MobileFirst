package com.stockflow.nosql.domain.enums;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum MovementType {
    ENTRY(1),
    EXIT(2);

    private final int value;

    MovementType(int value) {
        this.value = value;
    }

    @JsonValue
    public int getValue() {
        return value;
    }

    @JsonCreator
    public static MovementType fromValue(Object rawValue) {
        if (rawValue instanceof Number number) {
            final int numericValue = number.intValue();
            for (MovementType type : values()) {
                if (type.value == numericValue) {
                    return type;
                }
            }
        }

        if (rawValue instanceof String text) {
            for (MovementType type : values()) {
                if (type.name().equalsIgnoreCase(text.trim())) {
                    return type;
                }
            }

            try {
                return fromValue(Integer.parseInt(text.trim()));
            } catch (NumberFormatException ignored) {
                // handled below
            }
        }

        throw new IllegalArgumentException("Unsupported movement type: " + rawValue);
    }
}
