import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class CurrencyExchangeDetailScreen extends StatefulWidget {
  const CurrencyExchangeDetailScreen({super.key});

  @override
  _CurrencyExchangeDetailScreenState createState() =>
      _CurrencyExchangeDetailScreenState();
}

class _CurrencyExchangeDetailScreenState
    extends State<CurrencyExchangeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserCurrencyHolding> _userHoldings = [];
  final _formKey = GlobalKey<FormState>();
  final _fromCurrencyController = TextEditingController();
  final _toCurrencyController = TextEditingController();
  final _amountController = TextEditingController();
  final _exchangeRateController = TextEditingController();

  // Popular currencies list
  final List<String> _popularCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'SEK',
    'NZD',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserHoldings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromCurrencyController.dispose();
    _toCurrencyController.dispose();
    _amountController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = prefs.getString('currency_holdings') ?? '[]';
    final List<dynamic> holdingsList = json.decode(holdingsJson);

    setState(() {
      _userHoldings = holdingsList
          .map((json) => UserCurrencyHolding.fromJson(json))
          .toList();
    });
  }

  Future<void> _saveUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = json.encode(
      _userHoldings.map((holding) => holding.toJson()).toList(),
    );
    await prefs.setString('currency_holdings', holdingsJson);
  }

  void _addHolding() {
    if (_formKey.currentState!.validate()) {
      final holding = UserCurrencyHolding(
        fromCurrency: _fromCurrencyController.text.toUpperCase(),
        toCurrency: _toCurrencyController.text.toUpperCase(),
        amount: double.parse(_amountController.text),
        exchangeRateAtPurchase: double.parse(_exchangeRateController.text),
        purchaseDate: DateTime.now(),
      );

      setState(() {
        _userHoldings.add(holding);
      });

      _saveUserHoldings();
      _clearForm();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Currency holding added successfully!')),
      );
    }
  }

  void _clearForm() {
    _fromCurrencyController.clear();
    _toCurrencyController.clear();
    _amountController.clear();
    _exchangeRateController.clear();
  }

  void _showAddHoldingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Currency Holding'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _fromCurrencyController.text.isNotEmpty
                          ? _fromCurrencyController.text
                          : null,
                      decoration: InputDecoration(
                        labelText: 'From Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _popularCurrencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _fromCurrencyController.text = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select currency';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _toCurrencyController.text.isNotEmpty
                          ? _toCurrencyController.text
                          : null,
                      decoration: InputDecoration(
                        labelText: 'To Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _popularCurrencies.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _toCurrencyController.text = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select currency';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _exchangeRateController,
                decoration: InputDecoration(
                  labelText: 'Exchange Rate at Purchase',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter exchange rate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid rate';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addHolding, child: Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Exchange'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Exchange Rates', icon: Icon(Icons.currency_exchange)),
            Tab(text: 'My Holdings', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHoldingDialog,
        backgroundColor: Colors.green,
        tooltip: 'Add Currency Holding',
        child: Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildExchangeRatesTab(), _buildMyHoldingsTab()],
      ),
    );
  }

  Widget _buildExchangeRatesTab() {
    return Consumer<FinancialDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.currencies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.currency_exchange, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No currency data available'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.forceRefresh(),
                  child: Text('Refresh Data'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Chart Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exchange Rate Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildLineChart(provider.currencies),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Currency Exchange Cards
              ...provider.currencies.map(
                (currency) => _buildCurrencyCard(currency),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyHoldingsTab() {
    return Consumer<FinancialDashboardProvider>(
      builder: (context, provider, child) {
        if (_userHoldings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('No currency holdings added yet'),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first currency holding',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Portfolio Summary Card
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Currency Portfolio Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${_userHoldings.length} currency pairs tracked',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Holdings List
              ..._userHoldings.map(
                (holding) => _buildHoldingCard(holding, provider.currencies),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart(List<CurrencyExchangeData> currencies) {
    if (currencies.isEmpty) return Container();

    final spots = currencies.asMap().entries.map((entry) {
      final index = entry.key;
      final currency = entry.value;
      return FlSpot(index.toDouble(), currency.rate);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(2),
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < currencies.length) {
                  return Text(
                    currencies[value.toInt()].displayName,
                    style: TextStyle(fontSize: 8),
                  );
                }
                return Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(CurrencyExchangeData currency) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: currency.isPositive ? Colors.green : Colors.red,
          child: Text(
            currency.fromCurrency[0],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          currency.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Exchange Rate'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currency.mainValue,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: currency.isPositive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                currency.changeValue,
                style: TextStyle(
                  color: currency.isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingCard(
    UserCurrencyHolding holding,
    List<CurrencyExchangeData> currencies,
  ) {
    final currentCurrency = currencies.firstWhere(
      (currency) =>
          currency.fromCurrency == holding.fromCurrency &&
          currency.toCurrency == holding.toCurrency,
      orElse: () => CurrencyExchangeData(
        fromCurrency: holding.fromCurrency,
        toCurrency: holding.toCurrency,
        rate: holding.exchangeRateAtPurchase,
        change: 0,
        timestamp: DateTime.now(),
      ),
    );

    final currentValue = holding.amount * currentCurrency.rate;
    final originalValue = holding.amount * holding.exchangeRateAtPurchase;
    final gainLoss = currentValue - originalValue;
    final gainLossPercent =
        ((currentCurrency.rate - holding.exchangeRateAtPurchase) /
            holding.exchangeRateAtPurchase) *
        100;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${holding.fromCurrency}/${holding.toCurrency}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${holding.amount.toStringAsFixed(2)} ${holding.fromCurrency}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase Rate: ${holding.exchangeRateAtPurchase.toStringAsFixed(4)}',
                    ),
                    Text(
                      'Current Rate: ${currentCurrency.rate.toStringAsFixed(4)}',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Original: ${originalValue.toStringAsFixed(2)} ${holding.toCurrency}',
                    ),
                    Text(
                      'Current: ${currentValue.toStringAsFixed(2)} ${holding.toCurrency}',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: gainLoss >= 0
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'P&L: ${gainLoss >= 0 ? '+' : ''}${gainLoss.toStringAsFixed(2)} ${holding.toCurrency}',
                    style: TextStyle(
                      color: gainLoss >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${gainLossPercent >= 0 ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: gainLoss >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCurrencyHolding {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double exchangeRateAtPurchase;
  final DateTime purchaseDate;

  UserCurrencyHolding({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.exchangeRateAtPurchase,
    required this.purchaseDate,
  });

  factory UserCurrencyHolding.fromJson(Map<String, dynamic> json) {
    return UserCurrencyHolding(
      fromCurrency: json['fromCurrency'],
      toCurrency: json['toCurrency'],
      amount: json['amount'].toDouble(),
      exchangeRateAtPurchase: json['exchangeRateAtPurchase'].toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'amount': amount,
      'exchangeRateAtPurchase': exchangeRateAtPurchase,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }
}
