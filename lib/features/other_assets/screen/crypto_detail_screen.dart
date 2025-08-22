import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class CryptoDetailScreen extends StatefulWidget {
  const CryptoDetailScreen({super.key});

  @override
  _CryptoDetailScreenState createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserCryptoHolding> _userHoldings = [];
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserHoldings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = prefs.getString('crypto_holdings') ?? '[]';
    final List<dynamic> holdingsList = json.decode(holdingsJson);

    setState(() {
      _userHoldings = holdingsList
          .map((json) => UserCryptoHolding.fromJson(json))
          .toList();
    });
  }

  Future<void> _saveUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = json.encode(
      _userHoldings.map((holding) => holding.toJson()).toList(),
    );
    await prefs.setString('crypto_holdings', holdingsJson);
  }

  void _addHolding() {
    if (_formKey.currentState!.validate()) {
      final holding = UserCryptoHolding(
        symbol: _symbolController.text.toUpperCase(),
        quantity: double.parse(_quantityController.text),
        buyPrice: double.parse(_buyPriceController.text),
        buyDate: DateTime.now(),
      );

      setState(() {
        _userHoldings.add(holding);
      });

      _saveUserHoldings();
      _clearForm();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Crypto holding added successfully!')),
      );
    }
  }

  void _clearForm() {
    _symbolController.clear();
    _quantityController.clear();
    _buyPriceController.clear();
  }

  void _showAddHoldingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Crypto Holding'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(
                  labelText: 'Crypto Symbol',
                  hintText: 'e.g., BTC',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a crypto symbol';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _buyPriceController,
                decoration: InputDecoration(
                  labelText: 'Buy Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter buy price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
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
        title: Text('Crypto Portfolio'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Market Data', icon: Icon(Icons.currency_bitcoin)),
            Tab(text: 'My Holdings', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHoldingDialog,
        tooltip: 'Add Crypto Holding',
        child: Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMarketDataTab(), _buildMyHoldingsTab()],
      ),
    );
  }

  Widget _buildMarketDataTab() {
    return Consumer<FinancialDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.cryptos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.currency_bitcoin, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No crypto data available'),
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
                        'Crypto Price Chart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildCandlestickChart(provider.cryptos),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Crypto List
              ...provider.cryptos.map((crypto) => _buildCryptoCard(crypto)),
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
                Text('No crypto holdings added yet'),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first crypto holding',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Calculate total portfolio value
        double totalValue = 0;
        double totalGainLoss = 0;

        for (var holding in _userHoldings) {
          final currentCrypto = provider.cryptos.firstWhere(
            (crypto) => crypto.symbol == holding.symbol,
            orElse: () => CryptoData(
              symbol: holding.symbol,
              targetCurrency: 'USD',
              price: holding.buyPrice,
              change24h: 0,
              timestamp: DateTime.now(),
            ),
          );

          final currentValue = holding.quantity * currentCrypto.price;
          final investedValue = holding.quantity * holding.buyPrice;
          totalValue += currentValue;
          totalGainLoss += (currentValue - investedValue);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Portfolio Summary Card
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Crypto Portfolio Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 20,
                        runSpacing: 16,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Total Value',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '\$${totalValue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Total P&L',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${totalGainLoss >= 0 ? '+' : ''}\$${totalGainLoss.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: totalGainLoss >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Holdings List
              ..._userHoldings.map(
                (holding) => _buildHoldingCard(holding, provider.cryptos),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCandlestickChart(List<CryptoData> cryptos) {
    if (cryptos.isEmpty) return Container();

    final spots = cryptos.asMap().entries.map((entry) {
      final index = entry.key;
      final crypto = entry.value;
      return FlSpot(index.toDouble(), crypto.price);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 80,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < cryptos.length) {
                  return Text(
                    cryptos[value.toInt()].symbol,
                    style: TextStyle(fontSize: 10),
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
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(CryptoData crypto) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: crypto.isPositive ? Colors.green : Colors.red,
          child: Text(
            crypto.symbol.substring(0, crypto.symbol.length > 2 ? 2 : 1),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          crypto.displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Target: ${crypto.targetCurrency}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              crypto.mainValue,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: crypto.isPositive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                crypto.changeValue,
                style: TextStyle(
                  color: crypto.isPositive ? Colors.green : Colors.red,
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
    UserCryptoHolding holding,
    List<CryptoData> cryptos,
  ) {
    final currentCrypto = cryptos.firstWhere(
      (crypto) => crypto.symbol == holding.symbol,
      orElse: () => CryptoData(
        symbol: holding.symbol,
        targetCurrency: 'USD',
        price: holding.buyPrice,
        change24h: 0,
        timestamp: DateTime.now(),
      ),
    );

    final currentValue = holding.quantity * currentCrypto.price;
    final investedValue = holding.quantity * holding.buyPrice;
    final gainLoss = currentValue - investedValue;
    final gainLossPercent =
        ((currentCrypto.price - holding.buyPrice) / holding.buyPrice) * 100;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with symbol and quantity
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    holding.symbol,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${holding.quantity.toStringAsFixed(8)} coins',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Price information row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Buy Price: \$${holding.buyPrice.toStringAsFixed(4)}',
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Current Price: \$${currentCrypto.price.toStringAsFixed(4)}',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Invested: \$${investedValue.toStringAsFixed(2)}',
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Current: \$${currentValue.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // P&L section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: gainLoss >= 0
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'P&L: ${gainLoss >= 0 ? '+' : ''}\$${gainLoss.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: gainLoss >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${gainLossPercent >= 0 ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: gainLoss >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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

class UserCryptoHolding {
  final String symbol;
  final double quantity;
  final double buyPrice;
  final DateTime buyDate;

  UserCryptoHolding({
    required this.symbol,
    required this.quantity,
    required this.buyPrice,
    required this.buyDate,
  });

  factory UserCryptoHolding.fromJson(Map<String, dynamic> json) {
    return UserCryptoHolding(
      symbol: json['symbol'],
      quantity: json['quantity'].toDouble(),
      buyPrice: json['buyPrice'].toDouble(),
      buyDate: DateTime.parse(json['buyDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'buyDate': buyDate.toIso8601String(),
    };
  }
}
