import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/api/auth_api.dart';
import 'core/api/products_api.dart';
import 'core/api/stock_movements_api.dart';
import 'core/services/auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/movements/movements_screen.dart';
import 'features/movements/new_movement_screen.dart';
import 'features/products/product_detail_screen.dart';
import 'features/products/products_screen.dart';

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();
  static final AuthApi _authApi = AuthApi(_apiClient);
  static final ProductsApi _productsApi = ProductsApi(_apiClient);
  static final StockMovementsApi _stockMovementsApi = StockMovementsApi(_apiClient);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockFlow NoSQL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<void>(
              builder: (_) => SplashGate(authService: _authService),
            );
          case '/login':
            return MaterialPageRoute<void>(
              builder: (_) => LoginScreen(
                authApi: _authApi,
                authService: _authService,
              ),
            );
          case '/home':
            return MaterialPageRoute<void>(
              builder: (_) => HomeScreen(authService: _authService),
            );
          case '/products':
            return MaterialPageRoute<void>(
              builder: (_) => ProductsScreen(
                authService: _authService,
                productsApi: _productsApi,
              ),
            );
          case '/products/detail':
            final args = settings.arguments as ProductDetailArgs;
            return MaterialPageRoute<void>(
              builder: (_) => ProductDetailScreen(
                args: args,
                authService: _authService,
                stockMovementsApi: _stockMovementsApi,
              ),
            );
          case '/movements':
            return MaterialPageRoute<void>(
              builder: (_) => MovementsScreen(
                authService: _authService,
                productsApi: _productsApi,
                stockMovementsApi: _stockMovementsApi,
              ),
            );
          case '/movements/new':
            final args = settings.arguments as NewMovementArgs;
            return MaterialPageRoute<void>(
              builder: (_) => NewMovementScreen(
                args: args,
                authService: _authService,
                stockMovementsApi: _stockMovementsApi,
              ),
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => LoginScreen(
                authApi: _authApi,
                authService: _authService,
              ),
            );
        }
      },
    );
  }
}

class SplashGate extends StatefulWidget {
  final AuthService authService;

  const SplashGate({super.key, required this.authService});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    _resolveSession();
  }

  Future<void> _resolveSession() async {
    final hasSession = await widget.authService.hasActiveSession();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(hasSession ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
