package com.stockflow.nosql.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "jwt")
public class JwtConfig {

    private String secret;
    private long expirationHours;

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public long getExpirationHours() {
        return expirationHours;
    }

    public void setExpirationHours(long expirationHours) {
        this.expirationHours = expirationHours;
    }
}
