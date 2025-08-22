import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserStockHolding> _userHoldings = [];
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
    final holdingsJson = prefs.getString('stock_holdings') ?? '[]';
    final List<dynamic> holdingsList = json.decode(holdingsJson);

    setState(() {
      _userHoldings = holdingsList
          .map((json) => UserStockHolding.fromJson(json))
          .toList();
    });
  }

  Future<void> _saveUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = json.encode(
      _userHoldings.map((holding) => holding.toJson()).toList(),
    );
    await prefs.setString('stock_holdings', holdingsJson);
  }

  void _addHolding() {
    if (_formKey.currentState!.validate()) {
      final holding = UserStockHolding(
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
        SnackBar(content: Text('Stock holding added successfully!')),
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
        title: Text('Add Stock Holding'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(
                  labelText: 'Stock Symbol',
                  hintText: 'e.g., AAPL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a stock symbol';
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

  // Add this method to fix the error
  Widget _buildPortfolioMetric(String title, String value, {Color? color}) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Portfolio'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Market Data', icon: Icon(Icons.trending_up)),
            Tab(text: 'My Holdings', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHoldingDialog,
        tooltip: 'Add Stock Holding',
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
        if (provider.stocks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No stock data available'),
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
                        'Stock Price Chart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildCandlestickChart(provider.stocks),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Stock List
              ...provider.stocks.map((stock) => _buildStockCard(stock)),
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
                Text('No holdings added yet'),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first stock holding',
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
          final currentStock = provider.stocks.firstWhere(
            (stock) => stock.symbol == holding.symbol,
            orElse: () => StockData(
              symbol: holding.symbol,
              price: holding.buyPrice,
              change: 0,
              changePercent: 0,
              timestamp: DateTime.now(),
            ),
          );

          final currentValue = holding.quantity * currentStock.price;
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
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Portfolio Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPortfolioMetric(
                            'Total Value',
                            '\$${totalValue.toStringAsFixed(2)}',
                          ),
                          _buildPortfolioMetric(
                            'Total P&L',
                            '${totalGainLoss >= 0 ? '+' : ''}\$${totalGainLoss.toStringAsFixed(2)}',
                            color: totalGainLoss >= 0
                                ? Colors.green
                                : Colors.red,
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
                (holding) => _buildHoldingCard(holding, provider.stocks),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCandlestickChart(List<StockData> stocks) {
    if (stocks.isEmpty) return Container();

    // Create mock candlestick data based on current stock prices
    final spots = stocks.asMap().entries.map((entry) {
      final index = entry.key;
      final stock = entry.value;
      return FlSpot(index.toDouble(), stock.price);
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
                '\$${value.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < stocks.length) {
                  return Text(
                    stocks[value.toInt()].symbol,
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
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(StockData stock) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stock.isPositive ? Colors.green : Colors.red,
          child: Text(
            stock.symbol[0],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          stock.symbol,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'High: \$${stock.high.toStringAsFixed(2)} | Low: \$${stock.low.toStringAsFixed(2)}',
            ),
            Text('Volume: ${stock.volume}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              stock.mainValue,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: stock.isPositive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stock.changeValue,
                style: TextStyle(
                  color: stock.isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingCard(UserStockHolding holding, List<StockData> stocks) {
    final currentStock = stocks.firstWhere(
      (stock) => stock.symbol == holding.symbol,
      orElse: () => StockData(
        symbol: holding.symbol,
        price: holding.buyPrice,
        change: 0,
        changePercent: 0,
        timestamp: DateTime.now(),
      ),
    );

    final currentValue = holding.quantity * currentStock.price;
    final investedValue = holding.quantity * holding.buyPrice;
    final gainLoss = currentValue - investedValue;
    final gainLossPercent =
        ((currentStock.price - holding.buyPrice) / holding.buyPrice) * 100;

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
                  holding.symbol,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${holding.quantity} shares',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Buy Price: \$${holding.buyPrice.toStringAsFixed(2)}',
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Current Price: \$${currentStock.price.toStringAsFixed(2)}',
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
                    'P&L: ${gainLoss >= 0 ? '+' : ''}\$${gainLoss.toStringAsFixed(2)}',
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

class UserStockHolding {
  final String symbol;
  final double quantity;
  final double buyPrice;
  final DateTime buyDate;

  UserStockHolding({
    required this.symbol,
    required this.quantity,
    required this.buyPrice,
    required this.buyDate,
  });

  factory UserStockHolding.fromJson(Map<String, dynamic> json) {
    return UserStockHolding(
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
