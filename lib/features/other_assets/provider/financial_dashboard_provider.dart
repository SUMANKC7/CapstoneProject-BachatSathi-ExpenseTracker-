import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';
import 'package:expensetrack/features/other_assets/services/api_service.dart';
import 'package:expensetrack/features/other_assets/services/cache_service.dart';
import 'package:expensetrack/features/other_assets/services/financial_data_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialDashboardProvider with ChangeNotifier {
  final AlphaVantageService apiService = AlphaVantageService();
  final FirebaseService firebaseService = FirebaseService();

  List<StockData> _stocks = [];
  List<CryptoData> _cryptos = [];
  List<GoldData> _goldData = [];
  List<CurrencyExchangeData> _currencies = [];

  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  // Default symbols to fetch
  final List<String> _defaultStocks = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA'];
  final List<Map<String, String>> _defaultCrypto = [
    {'from': 'BTC', 'to': 'USD'},
    {'from': 'ETH', 'to': 'USD'},
    {'from': 'ADA', 'to': 'USD'},
  ];
  final List<Map<String, String>> _defaultCurrencies = [
    {'from': 'USD', 'to': 'EUR'},
    {'from': 'USD', 'to': 'GBP'},
    {'from': 'USD', 'to': 'JPY'},
    {'from': 'EUR', 'to': 'GBP'},
  ];

  // Getters
  List<StockData> get stocks => _stocks;
  List<CryptoData> get cryptos => _cryptos;
  List<GoldData> get goldData => _goldData;
  List<CurrencyExchangeData> get currencies => _currencies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void initializeStreams() {
    firebaseService.getStocksStream().listen((stocks) {
      _stocks = stocks;
      notifyListeners();
    });

    firebaseService.getCryptoStream().listen((cryptos) {
      _cryptos = cryptos;
      notifyListeners();
    });

    firebaseService.getGoldStream().listen((goldData) {
      _goldData = goldData;
      notifyListeners();
    });

    firebaseService.getCurrenciesStream().listen((currencies) {
      _currencies = currencies;
      notifyListeners();
    });

    // Initial data fetch
    fetchAllDataIfNeeded();
  }

  Future<void> fetchAllDataIfNeeded() async {
    _setLoading(true);
    _setError(null);

    try {
      // Fetch stocks
      for (String symbol in _defaultStocks) {
        if (await CacheService.shouldFetchData('stock_$symbol')) {
          final stockData = await apiService.getStockQuote(symbol);
          if (stockData != null) {
            await firebaseService.saveData('stocks', symbol, stockData);
            await CacheService.markDataFetched('stock_$symbol');
          }
        }
      }

      // Fetch crypto
      for (var crypto in _defaultCrypto) {
        final key = 'crypto_${crypto['from']}_${crypto['to']}';
        if (await CacheService.shouldFetchData(key)) {
          final cryptoData = await apiService.getCryptoData(
            crypto['from']!,
            crypto['to']!,
          );
          if (cryptoData != null) {
            await firebaseService.saveData(
              'crypto',
              '${crypto['from']}_${crypto['to']}',
              cryptoData,
            );
            await CacheService.markDataFetched(key);
          }
        }
      }

      // Fetch gold
      if (await CacheService.shouldFetchData('gold')) {
        final goldData = await apiService.getGoldData();
        if (goldData != null) {
          await firebaseService.saveData('gold', 'XAU_USD', goldData);
          await CacheService.markDataFetched('gold');
        }
      }

      // Fetch currencies
      for (var currency in _defaultCurrencies) {
        final key = 'currency_${currency['from']}_${currency['to']}';
        if (await CacheService.shouldFetchData(key)) {
          final currencyData = await apiService.getCurrencyExchange(
            currency['from']!,
            currency['to']!,
          );
          if (currencyData != null) {
            await firebaseService.saveData(
              'currencies',
              '${currency['from']}_${currency['to']}',
              currencyData,
            );
            await CacheService.markDataFetched(key);
          }
        }
      }

      _lastRefresh = DateTime.now();
    } catch (e) {
      _setError('Failed to fetch data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forceRefresh() async {
    // Clear cache and force fetch
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('last_fetch_'))
        .toList();
    for (String key in keys) {
      await prefs.remove(key);
    }

    await fetchAllDataIfNeeded();
  }
}
