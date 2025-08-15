import 'package:expensetrack/features/entity/screen/addentity.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PartiesScreen extends StatelessWidget {
  const PartiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchAndFilter(context),
            _buildFilterTabs(context),
            _buildSummaryCards(context),
            Expanded(child: _buildPartiesList(context)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                  Column(
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
                            provider.isOnline
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.isOnline ? 'Online' : 'Offline',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () => provider.refreshData(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () => _showSyncInfo(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (provider.error != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Using cached data',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  context.read<PartiesProvider>().updateSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search parties...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.tune, color: Colors.teal),
              onPressed: () => _showFilterBottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All',
                  provider.selectedFilter == null,
                  () => provider.setFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'To Give',
                  provider.selectedFilter == TransactionStatus.toGive,
                  () => provider.setFilter(TransactionStatus.toGive),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'To Receive',
                  provider.selectedFilter == TransactionStatus.toReceive,
                  () => provider.setFilter(TransactionStatus.toReceive),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Settled',
                  provider.selectedFilter == TransactionStatus.settled,
                  () => provider.setFilter(TransactionStatus.settled),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'To Receive',
                  'Rs. ${provider.totalToReceive.toStringAsFixed(0)}',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'To Give',
                  'Rs. ${provider.totalToGive.toStringAsFixed(0)}',
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesList(BuildContext context) {
    return Consumer<PartiesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
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

        if (provider.parties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
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

        return RefreshIndicator(
          onRefresh: () => provider.refreshData(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.parties.length,
            itemBuilder: (context, index) {
              final party = provider.parties[index];
              return _buildPartyCard(context, party);
            },
          ),
        );
      },
    );
  }

  Widget _buildPartyCard(BuildContext context, AddParty party) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Hero(
          tag: 'avatar_${party.id}',
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [party.avatarColor, party.avatarColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: party.avatarColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                party.avatarText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          party.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMd().format(party.date),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            if (party.phone.isNotEmpty)
              Text(
                party.phone,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              party.openingBalance == 0
                  ? 'Rs. 0'
                  : 'Rs. ${party.openingBalance.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getAmountColor(party.status, party.openingBalance),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(party.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(party.status),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(party.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showPartyDetails(context, party),
        onLongPress: () => _showPartyOptions(context, party),
      ),
    );
  }

  Color _getAmountColor(TransactionStatus status, double amount) {
    if (amount == 0) return Colors.grey.shade600;
    switch (status) {
      case TransactionStatus.toGive:
        return Colors.red;
      case TransactionStatus.toReceive:
        return Colors.green;
      case TransactionStatus.settled:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.toGive:
        return Colors.red;
      case TransactionStatus.toReceive:
        return Colors.green;
      case TransactionStatus.settled:
        return Colors.grey;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.toGive:
        return 'To Give';
      case TransactionStatus.toReceive:
        return 'To Receive';
      case TransactionStatus.settled:
        return 'Settled';
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEntity()),
        );
      },
      backgroundColor: Colors.teal,
      icon: const Icon(Icons.add),
      label: const Text('New Party'),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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

  Widget _buildFilterOption(
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

  void _showPartyDetails(BuildContext context, AddParty party) {
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
              _showPartyOptions(context, party);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Actions', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  void _showPartyOptions(BuildContext context, AddParty party) {
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

  void _confirmDeleteParty(BuildContext context, AddParty party) {
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

  void _sharePartyDetails(AddParty party) {
    // TODO: Implement share functionality
  }

  void _showSyncInfo(BuildContext context) async {
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
