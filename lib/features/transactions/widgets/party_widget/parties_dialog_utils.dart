import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:provider/provider.dart';

class PartiesDialogUtils {
  // -------------------- SYNC INFO DIALOG --------------------
  static void showSyncInfo(BuildContext context) async {
    final provider = context.read<PartiesProvider>();
    final lastSync = await provider.getLastSyncTime();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(provider.isOnline ? 'Online' : 'Offline'),
              ],
            ),
            const SizedBox(height: 12),
            Text('Total Parties: ${provider.parties.length}'),
            const SizedBox(height: 8),
            Text(
              'Last Sync: ${lastSync != null ? _formatDateTime(lastSync) : 'Never'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (!provider.isOnline) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'You are currently offline. Data shown may not be the latest.',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!provider.isOnline)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.refreshData();
              },
              child: const Text('Retry Connection'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // -------------------- FILTER BOTTOM SHEET --------------------
  static void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Consumer<PartiesProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildFilterOption(
                      context,
                      'All Parties',
                      provider.selectedFilter == null,
                      () {
                        provider.setFilter(null);
                        Navigator.pop(context);
                      },
                    ),
                    _buildFilterOption(
                      context,
                      'To Give',
                      provider.selectedFilter == TransactionStatus.toGive,
                      () {
                        provider.setFilter(TransactionStatus.toGive);
                        Navigator.pop(context);
                      },
                    ),
                    _buildFilterOption(
                      context,
                      'To Receive',
                      provider.selectedFilter == TransactionStatus.toReceive,
                      () {
                        provider.setFilter(TransactionStatus.toReceive);
                        Navigator.pop(context);
                      },
                    ),
                    _buildFilterOption(
                      context,
                      'Settled',
                      provider.selectedFilter == TransactionStatus.settled,
                      () {
                        provider.setFilter(TransactionStatus.settled);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildFilterOption(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      leading: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onTap(),
        activeColor: Colors.teal,
      ),
      onTap: onTap,
    );
  }

  // -------------------- PARTY DETAILS DIALOG --------------------
  static void showPartyDetails(BuildContext context, AddParty party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    party.avatarColor,
                    party.avatarColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  party.avatarText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(party.name, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', 'Rs. ${party.openingBalance}'),
            _buildDetailRow('Status', _getStatusText(party.status)),
            _buildDetailRow('Date', DateFormat.yMMMd().format(party.date)),
            if (party.phone.isNotEmpty) _buildDetailRow('Phone', party.phone),
            if (party.email.isNotEmpty) _buildDetailRow('Email', party.email),
            if (party.address.isNotEmpty)
              _buildDetailRow('Address', party.address),
            _buildDetailRow(
              'Type',
              party.isCreditInfoSelected ? 'Credit' : 'Debit',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showPartyOptions(context, party);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Actions', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }

  // -------------------- PARTY OPTIONS SHEET --------------------
  static void showPartyOptions(BuildContext context, AddParty party) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Party Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Party'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit functionality coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Party'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteParty(context, party);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Share Details'),
              onTap: () {
                Navigator.pop(context);
                _sharePartyDetails(party);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _confirmDeleteParty(BuildContext context, AddParty party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Party'),
        content: Text(
          'Are you sure you want to delete ${party.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<PartiesProvider>().deleteParty(party.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${party.name} deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete party: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // -------------------- SHARE (TODO) --------------------
  static void _sharePartyDetails(AddParty party) {
    // TODO: Implement share functionality
  }

  // -------------------- HELPERS --------------------
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.toGive:
        return 'To Give';
      case TransactionStatus.toReceive:
        return 'To Receive';
      case TransactionStatus.settled:
        return 'Settled';
    }
  }
}
