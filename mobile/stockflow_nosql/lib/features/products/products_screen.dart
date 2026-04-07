import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/products_api.dart';
import '../../core/models/product.dart';
import '../../core/services/auth_service.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final AuthService authService;
  final ProductsApi productsApi;

  const ProductsScreen({
    super.key,
    required this.authService,
    required this.productsApi,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await widget.authService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    setState(() {
      _token = token;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await widget.productsApi.getAll(token);

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
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

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      return '${product.name} ${product.sku}'.toLowerCase().contains(query);
    }).toList();
  }

  String _productSubtitle(Product product) {
    final details = <String>[
      'SKU: ${product.sku}',
      'Category: ${product.categoryName}',
      'Balance: ${product.currentBalance} units',
    ];

    final location = product.location;
    if (location != null && location.trim().isNotEmpty) {
      details.add('Location: $location');
    }

    return details.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                labelText: 'Search by name or SKU',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _InfoState(
                title: 'Unable to load products',
                subtitle: _errorMessage!,
              )
            else if (_filteredProducts.isEmpty)
              const _InfoState(
                title: 'No products available',
                subtitle: 'Try adjusting your filter or seed the development data in the API.',
              )
            else
              ..._filteredProducts.map(
                (product) => Card(
                  child: ListTile(
                    onTap: _token == null
                        ? null
                        : () async {
                            await Navigator.of(context).pushNamed(
                              '/products/detail',
                              arguments: ProductDetailArgs(
                                product: product,
                                token: _token!,
                              ),
                            );
                            await _loadData();
                          },
                    title: Text(product.name),
                    subtitle: Text(_productSubtitle(product)),
                    trailing: Chip(
                      label: Text(product.isActive ? 'Active' : 'Inactive'),
                      backgroundColor: product.isActive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoState({required this.title, required this.subtitle});

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
