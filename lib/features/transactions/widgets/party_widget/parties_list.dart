import 'package:expensetrack/features/transactions/widgets/party_widget/parties_dialog_utils.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/party_card.dart';
import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:provider/provider.dart';

class PartiesList extends StatelessWidget {
  const PartiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingIndicator();
        }

        if (provider.parties.isEmpty) {
          return _buildEmptyState(provider);
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshData(),
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
        ],
      ),
    );
  }
}
