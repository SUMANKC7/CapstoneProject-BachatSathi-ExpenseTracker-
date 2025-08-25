import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/party_card.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/parties_dialog_utils.dart';

class PartiesList extends StatelessWidget {
  const PartiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        // Debug prints to help identify the issue
        debugPrint('=== PartiesList Debug ===');
        debugPrint('Is Loading: ${provider.isLoading}');
        debugPrint('Parties Count: ${provider.parties.length}');
        debugPrint('Error: ${provider.error}');
        debugPrint('Is Online: ${provider.isOnline}');
        debugPrint('Search Query: ${provider.searchQuery}');
        debugPrint('Selected Filter: ${provider.selectedFilter}');
        
        // Print first few party names for debugging
        if (provider.parties.isNotEmpty) {
          debugPrint('First few parties:');
          for (int i = 0; i < (provider.parties.length > 3 ? 3 : provider.parties.length); i++) {
            debugPrint('  ${i + 1}. ${provider.parties[i].name} (${provider.parties[i].id})');
          }
        }
        debugPrint('========================');

        if (provider.isLoading) {
          return _buildLoadingIndicator();
        }

        // Show error if there's one
        if (provider.error != null && provider.parties.isEmpty) {
          return _buildErrorState(provider);
        }

        if (provider.parties.isEmpty) {
          return _buildEmptyState(provider);
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshData(),
          child: Column(
            children: [
              // Debug info panel (remove this in production)
              if (provider.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'Warning: ${provider.error}',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              // Status indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: provider.isOnline ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: provider.isOnline ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.parties.length} parties',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Parties list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.parties.length,
                  itemBuilder: (context, index) {
                    final party = provider.parties[index];
                    return PartyCard(
                      party: party,
                      onTap: () =>
                          PartiesDialogUtils.showPartyDetails(context, party),
                      onLongPress: () =>
                          PartiesDialogUtils.showPartyOptions(context, party),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.teal),
          const SizedBox(height: 16),
          Text(
            'Loading parties...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PartiesProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error Loading Parties',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              provider.error ?? 'Unknown error occurred',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(PartiesProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No parties found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.isOnline
                ? 'Add a new party to get started'
                : 'No cached data available. Connect to internet.',
            style: TextStyle(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          if (provider.error != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refreshData(),
              child: const Text('Refresh'),
            ),
          ],
        ],
      ),
    );
  }
}