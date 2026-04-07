import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/stock_movements_api.dart';
import '../../core/models/product.dart';
import '../../core/models/stock_balance.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/formatters.dart';
import '../movements/new_movement_screen.dart';

class ProductDetailArgs {
  final Product product;
  final String token;

  ProductDetailArgs({
    required this.product,
    required this.token,
  });
}

class ProductDetailScreen extends StatefulWidget {
  final ProductDetailArgs args;
  final AuthService authService;
  final StockMovementsApi stockMovementsApi;

  const ProductDetailScreen({
    super.key,
    required this.args,
    required this.authService,
    required this.stockMovementsApi,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  StockBalance? _balance;
  bool _isLoadingBalance = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _isLoadingBalance = true;
      _errorMessage = null;
    });

    try {
      final balance = await widget.stockMovementsApi.getBalance(
        widget.args.token,
        widget.args.product.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _balance = balance;
        _isLoadingBalance = false;
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
      _isLoadingBalance = false;
    });
  }

  Future<void> _openNewMovement() async {
    final user = await widget.authService.getUser();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushNamed(
      '/movements/new',
      arguments: NewMovementArgs(
        product: widget.args.product,
        token: widget.args.token,
        performedByUserId: user?.id ?? '',
      ),
    );

    await _loadBalance();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.args.product;
    final location = product.location;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewMovement,
        icon: const Icon(Icons.add),
        label: const Text('New Movement'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('SKU: ${product.sku}'),
                  Text('Category: ${product.categoryName}'),
                  Text('Unit price: ${formatCurrency(product.unitPrice)}'),
                  if (location != null && location.trim().isNotEmpty)
                    Text('Location: $location'),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(product.isActive ? 'Active' : 'Inactive'),
                    backgroundColor: product.isActive
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current balance', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_isLoadingBalance)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    )
                  else
                    Text(
                      '${_balance?.currentBalance ?? product.currentBalance} units',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
