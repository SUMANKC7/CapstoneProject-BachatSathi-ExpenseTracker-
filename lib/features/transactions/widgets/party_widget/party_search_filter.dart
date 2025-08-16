import 'package:expensetrack/features/transactions/widgets/party_widget/parties_dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:provider/provider.dart';

class PartiesSearchFilter extends StatelessWidget {
  const PartiesSearchFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildSearchField(context)),
          const SizedBox(width: 12),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
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
        onChanged: (value) =>
            context.read<PartiesProvider>().updateSearchQuery(value),
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
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Container(
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
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Implementation moved to PartiesDialogUtils
    PartiesDialogUtils.showFilterBottomSheet(context);
  }
}
