import 'package:expensetrack/features/transactions/widgets/party_widget/parties_dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:provider/provider.dart';

class PartiesHeader extends StatelessWidget {
  const PartiesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTitleSection(provider),
                  _buildActionButtons(provider, context),
                ],
              ),
              if (provider.error != null) _buildErrorIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleSection(PartiesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parties',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          children: [
            Icon(
              provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              provider.isOnline ? 'Online' : 'Offline',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(PartiesProvider provider, BuildContext context) {
    return Row(
      children: [
        _buildIconButton(
          icon: Icons.refresh,
          onPressed: () => provider.refreshData(),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.settings,
          onPressed: () => _showSyncInfo(context),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Using cached data',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  void _showSyncInfo(BuildContext context) {
    // Implementation moved to separate utility class
    PartiesDialogUtils.showSyncInfo(context);
  }
}
