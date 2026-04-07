import 'api_client.dart';
import '../models/stock_balance.dart';
import '../models/stock_movement.dart';

class StockMovementsApi {
  final ApiClient _client;

  StockMovementsApi(this._client);

  Future<List<StockMovement>> getByProduct(String token, String productId) async {
    final data = await _client.get(
      '/api/stock-movements/product/$productId',
      token: token,
    );

    return (data as List)
        .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StockBalance> getBalance(String token, String productId) async {
    final data = await _client.get(
      '/api/stock-movements/product/$productId/balance',
      token: token,
    );

    return StockBalance.fromJson(data as Map<String, dynamic>);
  }

  Future<void> create(
    String token, {
    required String productId,
    required int type,
    required int quantity,
    String? reason,
    String? performedByUserId,
  }) async {
    await _client.post('/api/stock-movements', token: token, body: {
      'productId': productId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'performedByUserId': performedByUserId,
    });
  }
}
