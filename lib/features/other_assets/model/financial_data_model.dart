import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FinancialData {
  DateTime get timestamp;
  Map<String, dynamic> toFirestore();
  String get displayName;
  String get mainValue;
  String get changeValue;
  bool get isPositive;
}

class StockData extends FinancialData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  @override
  final DateTime timestamp;
  final double high;
  final double low;
  final int volume;

  StockData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.timestamp,
    this.high = 0.0,
    this.low = 0.0,
    this.volume = 0,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    final quote = json['Global Quote'] ?? {};
    return StockData(
      symbol: quote['01. symbol'] ?? '',
      price: double.tryParse(quote['05. price'] ?? '0') ?? 0.0,
      change: double.tryParse(quote['09. change'] ?? '0') ?? 0.0,
      changePercent:
          double.tryParse(
            quote['10. change percent']?.replaceAll('%', '') ?? '0',
          ) ??
          0.0,
      high: double.tryParse(quote['03. high'] ?? '0') ?? 0.0,
      low: double.tryParse(quote['04. low'] ?? '0') ?? 0.0,
      volume: int.tryParse(quote['06. volume'] ?? '0') ?? 0,
      timestamp: DateTime.now(),
    );
  }

  factory StockData.fromFirestore(Map<String, dynamic> data) {
    return StockData(
      symbol: data['symbol'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      change: (data['change'] ?? 0).toDouble(),
      changePercent: (data['changePercent'] ?? 0).toDouble(),
      high: (data['high'] ?? 0).toDouble(),
      low: (data['low'] ?? 0).toDouble(),
      volume: data['volume'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'symbol': symbol,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'high': high,
      'low': low,
      'volume': volume,
      'timestamp': Timestamp.fromDate(timestamp),
      'lastFetchDate': Timestamp.fromDate(DateTime.now()),
    };
  }

  @override
  String get displayName => symbol;
  @override
  String get mainValue => '\$${price.toStringAsFixed(2)}';
  @override
  String get changeValue =>
      '${change >= 0 ? '+' : ''}\$${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)';
  @override
  bool get isPositive => change >= 0;
}

class CryptoData extends FinancialData {
  final String symbol;
  final String targetCurrency;
  final double price;
  final double change24h;
  @override
  final DateTime timestamp;

  CryptoData({
    required this.symbol,
    required this.targetCurrency,
    required this.price,
    required this.change24h,
    required this.timestamp,
  });

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    final realTimeData = json['Realtime Currency Exchange Rate'] ?? {};
    return CryptoData(
      symbol: realTimeData['1. From_Currency Code'] ?? '',
      targetCurrency: realTimeData['3. To_Currency Code'] ?? '',
      price: double.tryParse(realTimeData['5. Exchange Rate'] ?? '0') ?? 0.0,
      change24h: 0.0, // Alpha Vantage doesn't provide 24h change for crypto
      timestamp: DateTime.now(),
    );
  }

  factory CryptoData.fromFirestore(Map<String, dynamic> data) {
    return CryptoData(
      symbol: data['symbol'] ?? '',
      targetCurrency: data['targetCurrency'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      change24h: (data['change24h'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'symbol': symbol,
      'targetCurrency': targetCurrency,
      'price': price,
      'change24h': change24h,
      'timestamp': Timestamp.fromDate(timestamp),
      'lastFetchDate': Timestamp.fromDate(DateTime.now()),
    };
  }

  @override
  String get displayName => '$symbol/$targetCurrency';
  @override
  String get mainValue => '\$${price.toStringAsFixed(4)}';
  @override
  String get changeValue =>
      '24h: ${change24h >= 0 ? '+' : ''}${change24h.toStringAsFixed(2)}%';
  @override
  bool get isPositive => change24h >= 0;
}

class GoldData extends FinancialData {
  final double price;
  final double change;
  final double changePercent;
  @override
  final DateTime timestamp;
  final String currency;

  GoldData({
    required this.price,
    required this.change,
    required this.changePercent,
    required this.timestamp,
    this.currency = 'USD',
  });

  factory GoldData.fromJson(Map<String, dynamic> json) {
    // Alpha Vantage doesn't have dedicated gold endpoint, using commodity or custom logic
    return GoldData(
      price: 2000.0, // Placeholder - you might need different API for gold
      change: 15.50,
      changePercent: 0.78,
      timestamp: DateTime.now(),
    );
  }

  factory GoldData.fromFirestore(Map<String, dynamic> data) {
    return GoldData(
      price: (data['price'] ?? 0).toDouble(),
      change: (data['change'] ?? 0).toDouble(),
      changePercent: (data['changePercent'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'currency': currency,
      'timestamp': Timestamp.fromDate(timestamp),
      'lastFetchDate': Timestamp.fromDate(DateTime.now()),
    };
  }

  @override
  String get displayName => 'Gold (XAU/$currency)';
  @override
  String get mainValue => '\$${price.toStringAsFixed(2)}/oz';
  @override
  String get changeValue =>
      '${change >= 0 ? '+' : ''}\$${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)';
  @override
  bool get isPositive => change >= 0;
}

class CurrencyExchangeData extends FinancialData {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double change;
  @override
  final DateTime timestamp;

  CurrencyExchangeData({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.change,
    required this.timestamp,
  });

  factory CurrencyExchangeData.fromJson(Map<String, dynamic> json) {
    final realTimeData = json['Realtime Currency Exchange Rate'] ?? {};
    return CurrencyExchangeData(
      fromCurrency: realTimeData['1. From_Currency Code'] ?? '',
      toCurrency: realTimeData['3. To_Currency Code'] ?? '',
      rate: double.tryParse(realTimeData['5. Exchange Rate'] ?? '0') ?? 0.0,
      change: 0.0, // Calculate from previous data if needed
      timestamp: DateTime.now(),
    );
  }

  factory CurrencyExchangeData.fromFirestore(Map<String, dynamic> data) {
    return CurrencyExchangeData(
      fromCurrency: data['fromCurrency'] ?? '',
      toCurrency: data['toCurrency'] ?? '',
      rate: (data['rate'] ?? 0).toDouble(),
      change: (data['change'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'change': change,
      'timestamp': Timestamp.fromDate(timestamp),
      'lastFetchDate': Timestamp.fromDate(DateTime.now()),
    };
  }

  @override
  String get displayName => '$fromCurrency/$toCurrency';
  @override
  String get mainValue => rate.toStringAsFixed(4);
  @override
  String get changeValue =>
      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(4)}';
  @override
  bool get isPositive => change >= 0;
}
