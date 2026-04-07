import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/stock_movements_api.dart';
import '../../core/models/product.dart';
import '../../core/services/auth_service.dart';

class NewMovementArgs {
  final Product product;
  final String token;
  final String performedByUserId;

  NewMovementArgs({
    required this.product,
    required this.token,
    required this.performedByUserId,
  });
}

class NewMovementScreen extends StatefulWidget {
  final NewMovementArgs args;
  final AuthService authService;
  final StockMovementsApi stockMovementsApi;

  const NewMovementScreen({
    super.key,
    required this.args,
    required this.authService,
    required this.stockMovementsApi,
  });

  @override
  State<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends State<NewMovementScreen> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _reasonController = TextEditingController();

  int _typeValue = 1;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() {
        _errorMessage = 'Quantity must be a positive integer.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.stockMovementsApi.create(
        widget.args.token,
        productId: widget.args.product.id,
        type: _typeValue,
        quantity: quantity,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        performedByUserId: widget.args.performedByUserId.isEmpty
            ? null
            : widget.args.performedByUserId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movement recorded successfully.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await widget.authService.clearSession();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Movement'),
            Text(
              widget.args.product.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.args.product.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(widget.args.product.sku),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _typeValue,
              decoration: const InputDecoration(
                labelText: 'Movement type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Entry (1)')),
                DropdownMenuItem(value: 2, child: Text('Exit (2)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _typeValue = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSubmitting ? null : _save,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
