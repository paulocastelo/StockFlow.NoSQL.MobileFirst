package com.stockflow.nosql.config;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI stockFlowOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("StockFlow NoSQL API")
                        .version("v1")
                        .description("Mobile-first inventory management API backed by MongoDB."));
    }

    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder()
                .group("stockflow-nosql")
                .pathsToMatch("/**")
                .build();
    }
}
