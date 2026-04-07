# Especificação Técnica — StockFlow.NoSQL.MobileFirst

Este documento é a especificação de implementação completa para o backend Spring Boot e o app Flutter de `StockFlow.NoSQL.MobileFirst`.
Deve ser usada como referência por outro agente ou desenvolvedor que irá implementar o projeto do zero.

Não altere nenhum arquivo fora das pastas `backend/` e `mobile/`.

---

## 1. Contexto

`StockFlow.NoSQL.MobileFirst` resolve o mesmo domínio de gestão de estoque que `StockFlow.Core`, mas com uma stack completamente diferente:

- `StockFlow.Core`: ASP.NET Core + PostgreSQL (relacional) + React + Flutter
- `StockFlow.NoSQL.MobileFirst`: Spring Boot + MongoDB (documento) + Flutter

O objetivo não é reproduzir todos os recursos — é demonstrar que o mesmo problema pode ser resolvido com uma abordagem arquitetural diferente, e que as razões e os trade-offs são compreendidos.

---

## 2. Stack e versões

| Componente | Tecnologia | Versão mínima |
|------------|-----------|---------------|
| Backend | Spring Boot | 3.3.x |
| Linguagem | Java | 21 |
| Banco de dados | MongoDB | 7.x |
| ORM/ODM | Spring Data MongoDB | incluído no Spring Boot |
| Auth | JWT (jjwt) | 0.12.x |
| API Docs | Springdoc OpenAPI | 2.x |
| Testes | JUnit 5 + Mockito | incluído no Spring Boot |
| Mobile | Flutter | 3.x |
| Build | Maven | 3.9.x |

---

## 3. Estrutura de pastas esperada

```
backend/
  pom.xml
  src/
    main/
      java/
        com/stockflow/nosql/
          StockFlowNoSqlApplication.java
          config/
            SecurityConfig.java
            JwtConfig.java
            OpenApiConfig.java
          domain/
            document/
              Product.java
              StockMovement.java
              AppUser.java
            enums/
              MovementType.java
          application/
            auth/
              AuthService.java
              contracts/
                LoginRequest.java
                RegisterRequest.java
                AuthResponse.java
                UserProfileResponse.java
            product/
              ProductService.java
              contracts/
                ProductResponse.java
            movement/
              StockMovementService.java
              contracts/
                CreateMovementRequest.java
                MovementResponse.java
                BalanceResponse.java
          infrastructure/
            repository/
              ProductRepository.java
              StockMovementRepository.java
              AppUserRepository.java
            security/
              JwtTokenProvider.java
              JwtAuthenticationFilter.java
          api/
            AuthController.java
            ProductController.java
            StockMovementController.java
            HealthController.java
      resources/
        application.yml
        application-dev.yml
    test/
      java/
        com/stockflow/nosql/
          application/
            movement/
              StockMovementServiceTest.java
            auth/
              AuthServiceTest.java

mobile/
  stockflow_nosql/
    lib/
      main.dart
      app.dart
      core/
        api/
          api_client.dart
          auth_api.dart
          products_api.dart
          stock_movements_api.dart
        models/
          auth_response.dart
          user_profile.dart
          product.dart
          stock_movement.dart
          stock_balance.dart
        services/
          auth_service.dart
        constants.dart
        utils/
          formatters.dart
      features/
        auth/
          login_screen.dart
        home/
          home_screen.dart
        products/
          products_screen.dart
          product_detail_screen.dart
        movements/
          new_movement_screen.dart
    pubspec.yaml
    README.md
```

---

## 4. Backend — documentos MongoDB

### 4.1 Collection `products`

```java
@Document(collection = "products")
public class Product {
    @Id
    private String id;
    private String name;
    private String sku;           // único
    private String categoryName;  // string direto — sem collection separada
    private double unitPrice;
    private boolean isActive;
    private int currentBalance;   // mantido em sync a cada movimento
    private String location;      // ex.: "Warehouse A", "Zone B" (opcional)
    private Instant createdAtUtc;
}
```

### 4.2 Collection `stock_movements`

```java
@Document(collection = "stock_movements")
public class StockMovement {
    @Id
    private String id;
    private String productId;
    private MovementType type;    // ENTRY(1), EXIT(2)
    private int quantity;
    private String reason;
    private String performedByUserId;
    private Instant occurredAtUtc;
}
```

### 4.3 Collection `users`

```java
@Document(collection = "users")
public class AppUser {
    @Id
    private String id;
    private String fullName;
    private String email;         // único
    private String passwordHash;
    private boolean isActive;
    private Instant createdAtUtc;
}
```

### 4.4 Enum `MovementType`

```java
public enum MovementType {
    ENTRY(1),
    EXIT(2);

    private final int value;
    MovementType(int value) { this.value = value; }
    public int getValue() { return value; }
}
```

---

## 5. Backend — configuração (`application.yml`)

```yaml
spring:
  application:
    name: stockflow-nosql
  data:
    mongodb:
      uri: ${MONGODB_URI:mongodb://localhost:27017/stockflow_nosql}

server:
  port: ${PORT:8080}

jwt:
  secret: ${JWT_SECRET:CHANGE_THIS_DEVELOPMENT_KEY_BEFORE_PRODUCTION_USE_12345}
  expiration-hours: 8

springdoc:
  swagger-ui:
    path: /swagger-ui.html
```

`application-dev.yml` deve sobrescrever apenas o URI do MongoDB para desenvolvimento local:

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/stockflow_nosql
```

---

## 6. Backend — repositórios

### `ProductRepository`

```java
public interface ProductRepository extends MongoRepository<Product, String> {
    Optional<Product> findBySku(String sku);
    boolean existsBySku(String sku);
    List<Product> findByIsActiveTrue();
}
```

### `StockMovementRepository`

```java
public interface StockMovementRepository extends MongoRepository<StockMovement, String> {
    List<StockMovement> findByProductIdOrderByOccurredAtUtcDesc(String productId);
}
```

### `AppUserRepository`

```java
public interface AppUserRepository extends MongoRepository<AppUser, String> {
    Optional<AppUser> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

---

## 7. Backend — camada de aplicação

### 7.1 `AuthService`

Responsabilidades:
- `register(RegisterRequest)` — valida e-mail único, faz hash da senha com BCrypt, persiste o usuário, retorna `UserProfileResponse`
- `login(LoginRequest)` — busca usuário por e-mail, valida senha com BCrypt, gera JWT, retorna `AuthResponse`

`AuthResponse`:
```java
public record AuthResponse(String accessToken, String expiresAtUtc, UserProfileResponse user) {}
```

`UserProfileResponse`:
```java
public record UserProfileResponse(String id, String fullName, String email, boolean isActive) {}
```

### 7.2 `ProductService`

Responsabilidades:
- `findAll()` — retorna todos os produtos com `currentBalance`
- `findById(String id)` — retorna produto por id, lança `404` se não encontrar

`ProductResponse`:
```java
public record ProductResponse(
    String id, String name, String sku, String categoryName,
    double unitPrice, boolean isActive, int currentBalance, String location
) {}
```

### 7.3 `StockMovementService`

Responsabilidades:
- `create(CreateMovementRequest, String performedByUserId)` — regra de negócio central:
  1. Busca o produto por `productId`, lança `404` se não existir
  2. Se `type == EXIT`: valida que `product.currentBalance >= request.quantity`, lança `400` com mensagem `"Insufficient stock balance."` se não
  3. Cria o documento `StockMovement`
  4. Atualiza `product.currentBalance` atomicamente:
     - ENTRY: `currentBalance += quantity`
     - EXIT: `currentBalance -= quantity`
  5. Persiste o movimento e salva o produto atualizado
  6. Retorna `MovementResponse`
- `findByProductId(String productId)` — retorna lista de movimentações ordenadas por data decrescente
- `getBalance(String productId)` — retorna `BalanceResponse` com `currentBalance` do produto

`CreateMovementRequest`:
```java
public record CreateMovementRequest(
    String productId,
    MovementType type,
    int quantity,
    String reason,
    String performedByUserId
) {}
```

`MovementResponse`:
```java
public record MovementResponse(
    String id, String productId, MovementType type,
    int quantity, String reason, String performedByUserId, String occurredAtUtc
) {}
```

`BalanceResponse`:
```java
public record BalanceResponse(String productId, int currentBalance) {}
```

---

## 8. Backend — controllers

### `HealthController`

```
GET /health → 200 OK, body: { "status": "ok" }
```

Público (sem autenticação).

### `AuthController`

```
POST /api/auth/register → 201 Created → UserProfileResponse
POST /api/auth/login    → 200 OK      → AuthResponse
```

Público (sem autenticação).

### `ProductController`

```
GET /api/products      → 200 OK → List<ProductResponse>   [autenticado]
GET /api/products/{id} → 200 OK → ProductResponse         [autenticado]
```

### `StockMovementController`

```
POST /api/stock-movements                              → 201 Created → MovementResponse  [autenticado]
GET  /api/stock-movements/product/{productId}          → 200 OK      → List<MovementResponse> [autenticado]
GET  /api/stock-movements/product/{productId}/balance  → 200 OK      → BalanceResponse   [autenticado]
```

---

## 9. Backend — segurança JWT

### `JwtTokenProvider`

Responsabilidades:
- `generateToken(AppUser user)` — gera JWT com subject = `user.email`, claim `userId` = `user.id`, expiração configurável
- `validateToken(String token)` — valida assinatura e expiração
- `getEmailFromToken(String token)` — extrai o subject

Biblioteca: `io.jsonwebtoken:jjwt-api:0.12.x` + `jjwt-impl` + `jjwt-jackson`

### `JwtAuthenticationFilter`

Intercepta requisições, extrai o token do header `Authorization: Bearer <token>`, valida e seta o `SecurityContext`.

### `SecurityConfig`

- endpoints públicos: `POST /api/auth/**`, `GET /health`, `GET /swagger-ui/**`, `GET /v3/api-docs/**`
- todos os demais requerem autenticação
- stateless (sem sessão)
- CORS liberado para `localhost` em desenvolvimento

---

## 10. Backend — testes

### `StockMovementServiceTest`

Cobrir com JUnit 5 + Mockito:

1. `create_entry_increases_balance` — dado produto com balance 10, entrada de 5, balance deve ser 15
2. `create_exit_decreases_balance` — dado produto com balance 10, saída de 3, balance deve ser 7
3. `create_exit_throws_when_insufficient_balance` — dado produto com balance 2, saída de 5, deve lançar exceção com mensagem `"Insufficient stock balance."`
4. `create_exit_with_exact_balance_succeeds` — dado produto com balance 5, saída de 5, deve suceder com balance 0

### `AuthServiceTest`

1. `register_throws_when_email_already_exists`
2. `login_throws_when_email_not_found`
3. `login_throws_when_password_is_wrong`

---

## 11. Backend — seed de dados de desenvolvimento

Criar uma classe `DevelopmentDataSeeder` que é executada apenas quando o perfil `dev` está ativo e o banco está vazio.

Deve inserir:
- 1 usuário: `demo@stockflow.local` / `Password123!`
- 3 categorias (como `categoryName` nos produtos): `Electronics`, `Office Supplies`, `Cleaning`
- 5 produtos com `currentBalance` inicial entre 10 e 100
- 10 movimentações distribuídas entre os produtos

---

## 12. Backend — `pom.xml` (dependências principais)

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-mongodb</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-api</artifactId>
        <version>0.12.6</version>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-impl</artifactId>
        <version>0.12.6</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt-jackson</artifactId>
        <version>0.12.6</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.springdoc</groupId>
        <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        <version>2.5.0</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

---

## 13. Mobile Flutter — escopo

O app Flutter deste projeto é **idêntico em comportamento** ao app de `StockFlow.Core/mobile`, com as seguintes diferenças:

- aponta para a API Spring Boot (porta 8080 por padrão)
- os modelos refletem os response bodies desta API (sem `categoryId` — usa `categoryName` direto)
- não há tela de registro de usuário (apenas login)
- estrutura de pastas e padrões de código devem seguir exatamente o mesmo modelo de `StockFlow.Core/mobile/stockflow_mobile`

### Diferenças nos modelos

`Product` (sem `categoryId`, com `categoryName` e `location`):
```dart
class Product {
  final String id;
  final String name;
  final String sku;
  final String categoryName;
  final double unitPrice;
  final bool isActive;
  final int currentBalance;
  final String? location;
  ...
}
```

`StockMovement` (sem `performedByUserId` no response — simplificado):
```dart
class StockMovement {
  final String id;
  final String productId;
  final int type;
  final int quantity;
  final String? reason;
  final String occurredAtUtc;
  ...
}
```

### URL base

`lib/core/constants.dart`:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8080'; // emulador Android
```

### Dependências (`pubspec.yaml`)

Idênticas ao `StockFlow.Core/mobile/stockflow_mobile/pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0
  intl: ^0.19.0
```

### Referência de implementação

Para todos os detalhes de estrutura, padrões de código, tratamento de erros, navegação e telas, seguir integralmente a especificação em:

`StockFlow.Core/docs/planning/auditoria.md` — seções 3 a 14

As únicas adaptações necessárias são:
1. URL base apontando para porta 8080
2. Modelos `Product` e `StockMovement` ajustados conforme acima
3. Sem tela de registro (`LoginScreen` apenas, sem link para registro)
4. `ProductDetailScreen` exibe `categoryName` diretamente (sem resolver via lista de categorias)

---

## 14. Critério de conclusão

A implementação está concluída quando:

1. `mvn clean test` passa sem erros
2. API sobe localmente com `mvn spring-boot:run`
3. Swagger acessível em `http://localhost:8080/swagger-ui.html`
4. Fluxo completo funciona via Swagger: register → login → listar produtos → registrar movimento → consultar saldo
5. `flutter analyze` passa sem warnings no app mobile
6. App mobile conecta à API local e cobre todos os fluxos do MVP
7. GitHub Actions CI valida build e testes do backend

---

## 15. Comparação arquitetural — ponto-chave para o portfolio

O README final do repositório deve incluir uma seção explicando as diferenças arquiteturais em relação ao `StockFlow.Core`. Os pontos principais a documentar:

| Decisão | StockFlow.Core | StockFlow.NoSQL.MobileFirst | Razão |
|---------|---------------|----------------------------|-------|
| Balance | calculado via SUM no banco | armazenado no documento | leitura mais rápida no mobile |
| Categorias | tabela normalizada | string embutida no produto | evita joins desnecessários |
| Histórico | tabela separada, join na consulta | collection separada, indexada | MongoDB favorece collections separadas para histórico |
| API design | CRUD completo | focado nos fluxos do operador | o mobile não precisa de gestão completa |
| Stack | .NET / C# | Java / Spring Boot | demonstra versatilidade de stack |
