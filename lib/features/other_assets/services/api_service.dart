import 'package:dio/dio.dart';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class AlphaVantageService {
  static const String baseUrl = 'https://www.alphavantage.co/query';
  static const String apiKey =
      'GNRLLUIXO68I2KY8'; // Replace with your actual API key

  final Dio _dio = Dio();

  AlphaVantageService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Future<StockData?> getStockQuote(String symbol) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'function': 'GLOBAL_QUOTE',
          'symbol': symbol,
          'apikey': apiKey,
        },
      );

      if (response.data['Global Quote'] != null) {
        return StockData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching stock data: $e');
      return null;
    }
  }

  Future<CryptoData?> getCryptoData(String fromSymbol, String toSymbol) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'function': 'CURRENCY_EXCHANGE_RATE',
          'from_currency': fromSymbol,
          'to_currency': toSymbol,
          'apikey': apiKey,
        },
      );

      if (response.data['Realtime Currency Exchange Rate'] != null) {
        return CryptoData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching crypto data: $e');
      return null;
    }
  }

  Future<GoldData?> getGoldData() async {
    try {
      // For gold data, you might need a different API or use a commodity symbol
      // This is a placeholder implementation
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      return GoldData.fromJson({});
    } catch (e) {
      print('Error fetching gold data: $e');
      return null;
    }
  }

  Future<CurrencyExchangeData?> getCurrencyExchange(
    String fromCurrency,
    String toCurrency,
  ) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'function': 'CURRENCY_EXCHANGE_RATE',
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          'apikey': apiKey,
        },
      );

      if (response.data['Realtime Currency Exchange Rate'] != null) {
        return CurrencyExchangeData.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching currency data: $e');
      return null;
    }
  }
}
