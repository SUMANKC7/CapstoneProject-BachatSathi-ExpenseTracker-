import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class GoldDetailScreen extends StatefulWidget {
  const GoldDetailScreen({super.key});

  @override
  _GoldDetailScreenState createState() => _GoldDetailScreenState();
}

class _GoldDetailScreenState extends State<GoldDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserGoldHolding> _userHoldings = [];
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserHoldings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _buyPriceController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = prefs.getString('gold_holdings') ?? '[]';
    final List<dynamic> holdingsList = json.decode(holdingsJson);

    setState(() {
      _userHoldings = holdingsList
          .map((json) => UserGoldHolding.fromJson(json))
          .toList();
    });
  }

  Future<void> _saveUserHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final holdingsJson = json.encode(
      _userHoldings.map((holding) => holding.toJson()).toList(),
    );
    await prefs.setString('gold_holdings', holdingsJson);
  }

  void _addHolding() {
    if (_formKey.currentState!.validate()) {
      final holding = UserGoldHolding(
        type: _typeController.text,
        weight: double.parse(_weightController.text),
        buyPricePerOz: double.parse(_buyPriceController.text),
        buyDate: DateTime.now(),
      );

      setState(() {
        _userHoldings.add(holding);
      });

      _saveUserHoldings();
      _clearForm();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gold holding added successfully!')),
      );
    }
  }

  void _clearForm() {
    _weightController.clear();
    _buyPriceController.clear();
    _typeController.clear();
  }

  void _showAddHoldingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Gold Holding'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(
                  labelText: 'Gold Type',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                      'Gold Coin',
                      'Gold Bar',
                      'Gold Jewelry',
                      'Gold ETF',
                      'Gold Certificate',
                      'Other',
                    ].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  _typeController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gold type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (oz)',
                  border: OutlineInputBorder(),
                  suffixText: 'oz',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _buyPriceController,
                decoration: InputDecoration(
                  labelText: 'Buy Price per oz',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  suffixText: '/oz',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter buy price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price must be greater than 0';
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

  void _removeHolding(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Gold Holding'),
        content: Text('Are you sure you want to remove this gold holding?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userHoldings.removeAt(index);
              });
              _saveUserHoldings();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gold holding removed')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gold Portfolio'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: [
            Tab(text: 'Market Data', icon: Icon(Icons.local_fire_department)),
            Tab(text: 'My Holdings', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHoldingDialog,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        tooltip: 'Add Gold Holding',
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
        if (provider.goldData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No gold data available'),
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
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.show_chart, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Gold Price Trend (30 Days)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildLineChart(provider.goldData),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Current Gold Price Card
              Card(
                elevation: 4,
                color: Colors.amber.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Current Gold Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        provider.goldData.first.mainValue,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: provider.goldData.first.isPositive
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.goldData.first.changeValue,
                          style: TextStyle(
                            color: provider.goldData.first.isPositive
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Gold Info Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Safe Haven',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Hedge against inflation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.public, color: Colors.blue, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Global Asset',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Recognized worldwide',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
                Text(
                  'No gold holdings added yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first gold holding',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddHoldingDialog,
                  icon: Icon(Icons.add),
                  label: Text('Add Gold Holding'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate total portfolio value
        double totalWeight = 0;
        double totalValue = 0;
        double totalInvested = 0;
        double totalGainLoss = 0;

        final currentGoldPrice = provider.goldData.isNotEmpty
            ? provider.goldData.first.price
            : 2000.0; // Default if no data

        for (var holding in _userHoldings) {
          final currentValue = holding.weight * currentGoldPrice;
          final investedValue = holding.weight * holding.buyPricePerOz;
          totalWeight += holding.weight;
          totalValue += currentValue;
          totalInvested += investedValue;
          totalGainLoss += (currentValue - investedValue);
        }

        final totalGainLossPercent = totalInvested > 0
            ? ((totalValue - totalInvested) / totalInvested) * 100
            : 0.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Portfolio Summary Card
              Card(
                elevation: 4,
                color: Colors.amber.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.amber[800],
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gold Portfolio Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Total Weight',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${totalWeight.toStringAsFixed(3)} oz',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Total Value',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${totalValue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Total P&L',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${totalGainLoss >= 0 ? '+' : ''}\$${totalGainLoss.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: totalGainLoss >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Text(
                                  '${totalGainLossPercent >= 0 ? '+' : ''}${totalGainLossPercent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: totalGainLoss >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Holdings List
              ..._userHoldings.asMap().entries.map(
                (entry) =>
                    _buildHoldingCard(entry.key, entry.value, currentGoldPrice),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart(List<GoldData> goldData) {
    if (goldData.isEmpty) return Container();

    // Create mock historical data for demonstration
    final List<FlSpot> spots = [];
    final currentPrice = goldData.first.price;

    // Generate 30 days of mock historical data
    for (int i = 0; i < 30; i++) {
      final variation = (i * 2) - 30 + (i % 5 * 10) - (i % 3 * 5);
      final price = currentPrice + variation;
      spots.add(FlSpot(i.toDouble(), price));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '${value.toInt()}d',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.amber,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.amber.withOpacity(0.3),
            ),
          ),
        ],
        minY:
            spots
                .map((spot) => spot.y)
                .reduce((min, current) => min < current ? min : current) -
            50,
        maxY:
            spots
                .map((spot) => spot.y)
                .reduce((max, current) => max > current ? max : current) +
            50,
      ),
    );
  }

  Widget _buildHoldingCard(
    int index,
    UserGoldHolding holding,
    double currentPrice,
  ) {
    final currentValue = holding.weight * currentPrice;
    final investedValue = holding.weight * holding.buyPricePerOz;
    final gainLoss = currentValue - investedValue;
    final gainLossPercent =
        ((currentPrice - holding.buyPricePerOz) / holding.buyPricePerOz) * 100;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.type,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Purchased: ${_formatDate(holding.buyDate)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${holding.weight.toStringAsFixed(3)} oz',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeHolding(index),
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buy Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${holding.buyPricePerOz.toStringAsFixed(2)}/oz',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Current Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${currentPrice.toStringAsFixed(2)}/oz',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
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
                            'Invested',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${investedValue.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Current Value',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${currentValue.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: gainLoss >= 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: gainLoss >= 0
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profit & Loss',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${gainLoss >= 0 ? '+' : ''}\$${gainLoss.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: gainLoss >= 0
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${gainLossPercent >= 0 ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: gainLoss >= 0
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class UserGoldHolding {
  final String type;
  final double weight;
  final double buyPricePerOz;
  final DateTime buyDate;

  UserGoldHolding({
    required this.type,
    required this.weight,
    required this.buyPricePerOz,
    required this.buyDate,
  });

  factory UserGoldHolding.fromJson(Map<String, dynamic> json) {
    return UserGoldHolding(
      type: json['type'],
      weight: json['weight'].toDouble(),
      buyPricePerOz: json['buyPricePerOz'].toDouble(),
      buyDate: DateTime.parse(json['buyDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'weight': weight,
      'buyPricePerOz': buyPricePerOz,
      'buyDate': buyDate.toIso8601String(),
    };
  }
}
