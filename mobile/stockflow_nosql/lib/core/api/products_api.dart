import 'api_client.dart';
import '../models/product.dart';

class ProductsApi {
  final ApiClient _client;

  ProductsApi(this._client);

  Future<List<Product>> getAll(String token) async {
    final data = await _client.get('/api/products', token: token);
    return (data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
