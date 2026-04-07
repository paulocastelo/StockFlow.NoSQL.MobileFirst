import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/products_api.dart';
import '../../core/api/stock_movements_api.dart';
import '../../core/models/product.dart';
import '../../core/models/stock_balance.dart';
import '../../core/models/stock_movement.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/formatters.dart';
import 'new_movement_screen.dart';

class MovementsScreen extends StatefulWidget {
  final AuthService authService;
  final ProductsApi productsApi;
  final StockMovementsApi stockMovementsApi;

  const MovementsScreen({
    super.key,
    required this.authService,
    required this.productsApi,
    required this.stockMovementsApi,
  });

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  List<Product> _products = [];
  Product? _selectedProduct;
  List<StockMovement> _movements = [];
  StockBalance? _balance;
  bool _isLoading = true;
  String? _errorMessage;
  String? _token;
  String _performedByUserId = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  List<Product> get _activeProducts {
    return _products.where((product) => product.isActive).toList();
  }

  Future<void> _loadInitialData() async {
    final token = await widget.authService.getToken();
    final user = await widget.authService.getUser();

    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    setState(() {
      _token = token;
      _performedByUserId = user?.id ?? '';
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await widget.productsApi.getAll(token);
      if (!mounted) {
        return;
      }

      Product? nextSelected;
      final activeProducts = products.where((product) => product.isActive).toList();
      if (activeProducts.isNotEmpty) {
        if (_selectedProduct != null) {
          for (final product in activeProducts) {
            if (product.id == _selectedProduct!.id) {
              nextSelected = product;
              break;
            }
          }
        }
        nextSelected ??= activeProducts.first;
      }

      setState(() {
        _products = products;
        _selectedProduct = nextSelected;
      });

      if (nextSelected == null) {
        setState(() {
          _movements = [];
          _balance = null;
          _isLoading = false;
        });
        return;
      }

      await _loadSelectedProductData(showLoading: false);
    } catch (error) {
      await _handleError(error);
    }
  }

  Future<void> _loadSelectedProductData({bool showLoading = true}) async {
    final token = _token;
    final selectedProduct = _selectedProduct;

    if (token == null || selectedProduct == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        widget.stockMovementsApi.getByProduct(token, selectedProduct.id),
        widget.stockMovementsApi.getBalance(token, selectedProduct.id),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _movements = results[0] as List<StockMovement>;
        _balance = results[1] as StockBalance;
        _isLoading = false;
      });
    } catch (error) {
      await _handleError(error);
    }
  }

  Future<void> _handleError(Object error) async {
    if (error is ApiException && error.statusCode == 401) {
      await widget.authService.clearSession();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = error.toString();
      _isLoading = false;
    });
  }

  Future<void> _openNewMovement() async {
    final product = _selectedProduct;
    final token = _token;
    if (product == null || token == null) {
      return;
    }

    await Navigator.of(context).pushNamed(
      '/movements/new',
      arguments: NewMovementArgs(
        product: product,
        token: token,
        performedByUserId: _performedByUserId,
      ),
    );

    await _loadSelectedProductData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Movements')),
      floatingActionButton: _selectedProduct == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openNewMovement,
              icon: const Icon(Icons.add),
              label: const Text('New Movement'),
            ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (_activeProducts.isEmpty)
              const _MovementInfoState(
                title: 'No active products available',
                subtitle: 'Activate products in the web app to register stock movements here.',
              )
            else ...[
              DropdownButtonFormField<String>(
                value: _selectedProduct?.id,
                decoration: const InputDecoration(
                  labelText: 'Product',
                  border: OutlineInputBorder(),
                ),
                items: _activeProducts
                    .map(
                      (product) => DropdownMenuItem<String>(
                        value: product.id,
                        child: Text('${product.name} (${product.sku})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }

                  Product? nextProduct;
                  for (final product in _activeProducts) {
                    if (product.id == value) {
                      nextProduct = product;
                      break;
                    }
                  }

                  setState(() {
                    _selectedProduct = nextProduct;
                  });

                  await _loadSelectedProductData();
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current balance', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        Text(
                          '${_balance?.currentBalance ?? 0} units',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                _MovementInfoState(
                  title: 'Unable to load history',
                  subtitle: _errorMessage!,
                )
              else if (!_isLoading && _movements.isEmpty)
                const _MovementInfoState(
                  title: 'No movement history yet',
                  subtitle: 'Register an entry or exit to see it listed here.',
                )
              else
                ..._movements.map(
                  (movement) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: movement.type == 1
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          movement.type == 1 ? Icons.arrow_downward : Icons.arrow_upward,
                          color: movement.type == 1 ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(movement.type == 1 ? 'Entry' : 'Exit'),
                      subtitle: Text(
                        '${movement.quantity} units\n${movement.reason ?? 'No reason provided.'}\n${formatDateTime(movement.occurredAtUtc)}',
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MovementInfoState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MovementInfoState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
