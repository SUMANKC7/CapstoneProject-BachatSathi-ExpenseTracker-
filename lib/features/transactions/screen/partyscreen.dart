// parties_screen.dart
import 'package:expensetrack/features/entity/screen/addentity.dart';
import 'package:expensetrack/features/transactions/widgets/debug_panel.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/parties_header.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/parties_list.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/party_filter_tabs.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/party_search_filter.dart';
import 'package:expensetrack/features/transactions/widgets/party_widget/party_summary_cards.dart';
import 'package:flutter/material.dart';

class PartiesScreen extends StatelessWidget {
  const PartiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: const [
            PartiesHeader(),
            // DebugPanel(),
            PartiesSearchFilter(),
            PartiesFilterTabs(),
            PartiesSummaryCards(),
            Expanded(child: PartiesList()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
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
}
