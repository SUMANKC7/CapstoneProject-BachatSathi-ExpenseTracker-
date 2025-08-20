// import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';
// import 'package:expensetrack/features/other_assets/services/api_service.dart';
// import 'package:expensetrack/features/other_assets/services/financial_data_services.dart';
// import 'package:flutter/material.dart';

// class FinancialProvider with ChangeNotifier {
//   final AlphaVantageService _apiService = AlphaVantageService();
//   final FirebaseService _firebaseService = FirebaseService();

//   List<StockData> _stocks = [];
//   List<CryptoData> _cryptos = [];
//   List<CurrencyExchange> _currencies = [];

//   bool _isLoading = false;
//   String? _error;

//   // Getters
//   List<StockData> get stocks => _stocks;
//   List<CryptoData> get cryptos => _cryptos;
//   List<CurrencyExchange> get currencies => _currencies;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   void setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void setError(String? error) {
//     _error = error;
//     notifyListeners();
//   }

//   // Fetch and save stock data
//   Future<void> fetchStockData(String symbol) async {
//     setLoading(true);
//     setError(null);

//     try {
//       final stockData = await _apiService.getStockQuote(symbol);
//       if (stockData != null) {
//         await _firebaseService.saveStockData(stockData);
//       } else {
//         setError('Failed to fetch stock data for $symbol');
//       }
//     } catch (e) {
//       setError('Error: $e');
//     } finally {
//       setLoading(false);
//     }
//   }

//   // Fetch and save crypto data
//   Future<void> fetchCryptoData(String fromSymbol, String toSymbol) async {
//     setLoading(true);
//     setError(null);

//     try {
//       final cryptoData = await _apiService.getCryptoData(fromSymbol, toSymbol);
//       if (cryptoData != null) {
//         await _firebaseService.saveCryptoData(cryptoData);
//       } else {
//         setError('Failed to fetch crypto data');
//       }
//     } catch (e) {
//       setError('Error: $e');
//     } finally {
//       setLoading(false);
//     }
//   }

//   // Fetch and save currency exchange data
//   Future<void> fetchCurrencyData(String fromCurrency, String toCurrency) async {
//     setLoading(true);
//     setError(null);

//     try {
//       final currencyData = await _apiService.getCurrencyExchange(fromCurrency, toCurrency);
//       if (currencyData != null) {
//         await _firebaseService.saveCurrencyExchange(currencyData);
//       } else {
//         setError('Failed to fetch currency data');
//       }
//     } catch (e) {
//       setError('Error: $e');
//     } finally {
//       setLoading(false);
//     }
//   }

//   // Listen to Firebase streams
//   void initializeStreams() {
//     _firebaseService.getStocksStream().listen((stocks) {
//       _stocks = stocks;
//       notifyListeners();
//     });

//     _firebaseService.getCryptoStream().listen((cryptos) {
//       _cryptos = cryptos;
//       notifyListeners();
//     });

//     _firebaseService.getCurrenciesStream().listen((currencies) {
//       _currencies = currencies;
//       notifyListeners();
//     });
//   }
// }
