import 'api_client.dart';
import '../models/category.dart';

class CategoriesApi {
  final ApiClient _client;

  CategoriesApi(this._client);

  Future<List<Category>> getAll(String token) async {
    final data = await _client.get('/api/categories', token: token);
    return (data as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
