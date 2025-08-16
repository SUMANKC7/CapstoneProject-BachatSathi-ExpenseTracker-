import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:intl/intl.dart';

class PartyCard extends StatelessWidget {
  final AddParty party;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PartyCard({
    super.key,
    required this.party,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
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
        leading: _buildAvatar(),
        title: Text(
          party.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _buildAvatar() {
    return Hero(
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
    );
  }

  Widget _buildSubtitle() {
    return Column(
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
    );
  }

  Widget _buildTrailing() {
    return Column(
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
}
