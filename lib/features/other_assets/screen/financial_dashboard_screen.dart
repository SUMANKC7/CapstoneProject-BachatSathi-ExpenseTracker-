import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';
import 'package:expensetrack/features/other_assets/provider/financial_dashboard_provider.dart';
import 'package:expensetrack/features/other_assets/widgets/add_data_dialog.dart';
import 'package:expensetrack/features/other_assets/widgets/financial_card.dart';
import 'package:expensetrack/features/other_assets/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  State<FinancialDashboardScreen> createState() =>
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
      backgroundColor: Colors.grey[50],
      body: Consumer<FinancialDashboardProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Financial Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: provider.isLoading
                        ? null
                        : provider.forceRefresh,
                  ),
                ],
              ),

              if (provider.isLoading)
                const SliverToBoxAdapter(child: LinearProgressIndicator()),

              if (provider.error != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Last refresh info
              if (provider.lastRefresh != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Last updated: ${_formatDateTime(provider.lastRefresh!)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Stocks Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Stocks',
                  icon: Icons.trending_up,
                  color: Colors.green.shade600,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final stock = provider.stocks[index];
                    return FinancialCard<StockData>(
                      data: stock,
                      icon: Icons.trending_up,
                      color: Colors.green.shade600,
                      onTap: () => _showDetailDialog(context, stock),
                    );
                  }, childCount: provider.stocks.length),
                ),
              ),

              // Crypto Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Cryptocurrency',
                  icon: Icons.currency_bitcoin,
                  color: Colors.orange.shade600,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final crypto = provider.cryptos[index];
                    return FinancialCard<CryptoData>(
                      data: crypto,
                      icon: Icons.currency_bitcoin,
                      color: Colors.orange.shade600,
                      onTap: () => _showDetailDialog(context, crypto),
                    );
                  }, childCount: provider.cryptos.length),
                ),
              ),

              // Gold Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Gold',
                  icon: Icons.monetization_on,
                  color: Colors.amber.shade700,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final gold = provider.goldData[index];
                    return FinancialCard<GoldData>(
                      data: gold,
                      icon: Icons.monetization_on,
                      color: Colors.amber.shade700,
                      onTap: () => _showDetailDialog(context, gold),
                    );
                  }, childCount: provider.goldData.length),
                ),
              ),

              // Currency Exchange Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Currency Exchange',
                  icon: Icons.currency_exchange,
                  color: Colors.blue.shade600,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final currency = provider.currencies[index];
                    return FinancialCard<CurrencyExchangeData>(
                      data: currency,
                      icon: Icons.currency_exchange,
                      color: Colors.blue.shade600,
                      onTap: () => _showDetailDialog(context, currency),
                    );
                  }, childCount: provider.currencies.length),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<FinancialDashboardProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: provider.isLoading
                ? null
                : () => _showAddDataDialog(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 800) return 4;
    if (width > 600) return 3;
    return 2;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDetailDialog(BuildContext context, FinancialData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Current Value', data.mainValue),
            const SizedBox(height: 8),
            _buildDetailRow('Change', data.changeValue),
            const SizedBox(height: 8),
            _buildDetailRow('Last Updated', _formatDateTime(data.timestamp)),
            if (data is StockData) ...[
              const SizedBox(height: 8),
              _buildDetailRow('High', '\${data.high.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildDetailRow('Low', '\${data.low.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildDetailRow('Volume', data.volume.toString()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }

  void _showAddDataDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddDataDialog());
  }
}
