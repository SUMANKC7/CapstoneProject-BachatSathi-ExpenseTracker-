import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:expensetrack/features/other_assets/services/cache_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddDataDialog extends StatefulWidget {
  const AddDataDialog({super.key});

  @override
  State<AddDataDialog> createState() => _AddDataDialogState();
}

class _AddDataDialogState extends State<AddDataDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _stockController = TextEditingController();
  final _cryptoFromController = TextEditingController();
  final _cryptoToController = TextEditingController(text: 'USD');
  final _currencyFromController = TextEditingController();
  final _currencyToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stockController.dispose();
    _cryptoFromController.dispose();
    _cryptoToController.dispose();
    _currencyFromController.dispose();
    _currencyToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Add Financial Data',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Stock', icon: Icon(Icons.trending_up)),
                Tab(text: 'Crypto', icon: Icon(Icons.currency_bitcoin)),
                Tab(text: 'Currency', icon: Icon(Icons.currency_exchange)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStockTab(),
                  _buildCryptoTab(),
                  _buildCurrencyTab(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _handleAdd, child: const Text('Add')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTab() {
    return Column(
      children: [
        TextField(
          controller: _stockController,
          decoration: const InputDecoration(
            labelText: 'Stock Symbol',
            hintText: 'e.g., AAPL, GOOGL',
            prefixIcon: Icon(Icons.trending_up),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        const Text(
          'Popular stocks: AAPL, GOOGL, MSFT, AMZN, TSLA, NFLX, META',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCryptoTab() {
    return Column(
      children: [
        TextField(
          controller: _cryptoFromController,
          decoration: const InputDecoration(
            labelText: 'Cryptocurrency',
            hintText: 'e.g., BTC, ETH',
            prefixIcon: Icon(Icons.currency_bitcoin),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cryptoToController,
          decoration: const InputDecoration(
            labelText: 'Target Currency',
            hintText: 'e.g., USD, EUR',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        const Text(
          'Popular crypto: BTC, ETH, ADA, DOT, LINK, UNI, MATIC',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCurrencyTab() {
    return Column(
      children: [
        TextField(
          controller: _currencyFromController,
          decoration: const InputDecoration(
            labelText: 'From Currency',
            hintText: 'e.g., USD, EUR',
            prefixIcon: Icon(Icons.currency_exchange),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _currencyToController,
          decoration: const InputDecoration(
            labelText: 'To Currency',
            hintText: 'e.g., EUR, GBP',
            prefixIcon: Icon(Icons.currency_exchange),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        const Text(
          'Popular currencies: USD, EUR, GBP, JPY, CHF, CAD, AUD',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _handleAdd() async {
    final provider = context.read<FinancialDashboardProvider>();

    switch (_tabController.index) {
      case 0: // Stock
        if (_stockController.text.isNotEmpty) {
          final stockData = await provider.apiService.getStockQuote(
            _stockController.text.toUpperCase(),
          );
          if (stockData != null) {
            await provider.firebaseService.saveData(
              'stocks',
              _stockController.text.toUpperCase(),
              stockData,
            );
            await CacheService.markDataFetched(
              'stock_${_stockController.text.toUpperCase()}',
            );
          }
        }
        break;
      case 1: // Crypto
        if (_cryptoFromController.text.isNotEmpty &&
            _cryptoToController.text.isNotEmpty) {
          final cryptoData = await provider.apiService.getCryptoData(
            _cryptoFromController.text.toUpperCase(),
            _cryptoToController.text.toUpperCase(),
          );
          if (cryptoData != null) {
            await provider.firebaseService.saveData(
              'crypto',
              '${_cryptoFromController.text.toUpperCase()}_${_cryptoToController.text.toUpperCase()}',
              cryptoData,
            );
            await CacheService.markDataFetched(
              'crypto_${_cryptoFromController.text.toUpperCase()}_${_cryptoToController.text.toUpperCase()}',
            );
          }
        }
        break;
      case 2: // Currency
        if (_currencyFromController.text.isNotEmpty &&
            _currencyToController.text.isNotEmpty) {
          final currencyData = await provider.apiService.getCurrencyExchange(
            _currencyFromController.text.toUpperCase(),
            _currencyToController.text.toUpperCase(),
          );
          if (currencyData != null) {
            await provider.firebaseService.saveData(
              'currencies',
              '${_currencyFromController.text.toUpperCase()}_${_currencyToController.text.toUpperCase()}',
              currencyData,
            );
            await CacheService.markDataFetched(
              'currency_${_currencyFromController.text.toUpperCase()}_${_currencyToController.text.toUpperCase()}',
            );
          }
        }
        break;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

// Additional utility classes
class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}

// Error handling and logging
class AppLogger {
  static void logError(String message, dynamic error, StackTrace? stackTrace) {
    print('ERROR: $message');
    print('Details: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }

  static void logInfo(String message) {
    print('INFO: $message');
  }
}
