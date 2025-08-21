import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:expensetrack/features/other_assets/screen/crypto_detail_screen.dart';
import 'package:expensetrack/features/other_assets/screen/currency_exchange_screen.dart';
import 'package:expensetrack/features/other_assets/screen/gold_details_screen.dart';
import 'package:expensetrack/features/other_assets/screen/stock_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  _FinancialDashboardScreenState createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinancialDashboardProvider>().initializeStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<FinancialDashboardProvider>().forceRefresh();
            },
          ),
        ],
      ),
      body: Consumer<FinancialDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.forceRefresh(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.forceRefresh,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.lastRefresh != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Last updated: ${_formatDateTime(provider.lastRefresh!)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),

                  // Stocks Section
                  _buildDashboardCard(
                    context,
                    title: 'Stocks',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                    itemCount: provider.stocks.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailScreen(),
                      ),
                    ),
                    items: provider.stocks.take(3).toList(),
                  ),

                  SizedBox(height: 16),

                  // Cryptocurrency Section
                  _buildDashboardCard(
                    context,
                    title: 'Cryptocurrency',
                    icon: Icons.currency_bitcoin,
                    color: Colors.orange,
                    itemCount: provider.cryptos.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CryptoDetailScreen(),
                      ),
                    ),
                    items: provider.cryptos.take(3).toList(),
                  ),

                  SizedBox(height: 16),

                  // Gold Section
                  _buildDashboardCard(
                    context,
                    title: 'Gold',
                    icon: Icons.local_fire_department,
                    color: Colors.amber,
                    itemCount: provider.goldData.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoldDetailScreen(),
                      ),
                    ),
                    items: provider.goldData.take(1).toList(),
                  ),

                  SizedBox(height: 16),

                  // Currency Exchange Section
                  _buildDashboardCard(
                    context,
                    title: 'Currency Exchange',
                    icon: Icons.currency_exchange,
                    color: Colors.green,
                    itemCount: provider.currencies.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CurrencyExchangeDetailScreen(),
                      ),
                    ),
                    items: provider.currencies.take(3).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required int itemCount,
    required VoidCallback onTap,
    required List<FinancialData> items,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Badge(
                    label: Text(itemCount.toString()),
                    child: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),
                ],
              ),

              if (items.isNotEmpty) ...[
                SizedBox(height: 12),
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.displayName,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.mainValue,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.isPositive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.changeValue,
                            style: TextStyle(
                              color: item.isPositive
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No data available. Pull to refresh.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
