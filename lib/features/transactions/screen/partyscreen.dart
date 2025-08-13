import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartiesScreen extends StatelessWidget {
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      Text(
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
                          SizedBox(width: 4),
                          Text(
                            provider.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
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
                          icon: Icon(Icons.refresh, color: Colors.white),
                          onPressed: () => provider.refreshData(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.settings, color: Colors.white),
                          onPressed: () => _showSyncInfo(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (provider.error != null)
                Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
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
      padding: EdgeInsets.all(16),
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
                    offset: Offset(0, 4),
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
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
          margin: EdgeInsets.symmetric(horizontal: 16),
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
                SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'To Give',
                  provider.selectedFilter == TransactionStatus.toGive,
                  () => provider.setFilter(TransactionStatus.toGive),
                ),
                SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'To Receive',
                  provider.selectedFilter == TransactionStatus.toReceive,
                  () => provider.setFilter(TransactionStatus.toReceive),
                ),
                SizedBox(width: 8),
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
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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
          margin: EdgeInsets.all(16),
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
              SizedBox(width: 12),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              SizedBox(width: 8),
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
          SizedBox(height: 8),
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
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16),
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
                SizedBox(height: 16),
                Text(
                  'No parties found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
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
          onRefresh: provider.refreshData,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildPartyCard(BuildContext context, Party party) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
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
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                party.avatarText,
                style: TextStyle(
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
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              party.date,
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
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      onPressed: () => _showAddPartyDialog(context),
      backgroundColor: Colors.teal,
      icon: Icon(Icons.add),
      label: Text('New Party'),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 20),
            Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
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

  void _showPartyDetails(BuildContext context, Party party) {
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(party.name, style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', 'Rs. ${party.openingBalance}'),
            _buildDetailRow('Status', _getStatusText(party.status)),
            _buildDetailRow('Date', party.date),
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
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPartyOptions(context, party);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text('Actions', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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

  void _showPartyOptions(BuildContext context, Party party) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
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
            SizedBox(height: 20),
            Text(
              'Party Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit Party'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit functionality coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Party'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteParty(context, party);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.green),
              title: Text('Share Details'),
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

  void _confirmDeleteParty(BuildContext context, Party party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Party'),
        content: Text(
          'Are you sure you want to delete ${party.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sharePartyDetails(Party party) {
    // TODO: Implement share functionality
    // You can use the share_plus package for this
  }

  void _showSyncInfo(BuildContext context) async {
    final provider = context.read<PartiesProvider>();
    final lastSync = await provider.getLastSyncTime();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sync Information'),
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
                SizedBox(width: 8),
                Text(provider.isOnline ? 'Online' : 'Offline'),
              ],
            ),
            SizedBox(height: 12),
            Text('Total Parties: ${provider.parties.length}'),
            SizedBox(height: 8),
            Text(
              'Last Sync: ${lastSync != null ? _formatDateTime(lastSync) : 'Never'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (!provider.isOnline) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
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
              child: Text('Retry Connection'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAddPartyDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => AddPartyDialog());
  }
}

// widgets/add_party_dialog.dart
class AddPartyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddEntityProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Add New Party'),
          content: Form(
            key: provider.formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: provider.nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: provider.phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: provider.emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: provider.openingCtrl,
                    decoration: InputDecoration(
                      labelText: 'Opening Balance',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: provider.dateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => provider.pickDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => provider.pickDate(context),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: provider.addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Transaction Type: '),
                      Switch(
                        value: provider.toReceive,
                        onChanged: provider.toggleReceiveGive,
                        activeColor: Colors.teal,
                      ),
                      Text(provider.toReceive ? 'To Receive' : 'To Give'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.clearForm();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await provider.saveEntity(context);
                if (success) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Add Party', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
