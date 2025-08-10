import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/transactions/widgets/add_transaction_bottomsheet.dart';
import 'package:expensetrack/features/transactions/widgets/filter_widget.dart';
import 'package:expensetrack/features/transactions/widgets/summary_widget.dart';
import 'package:expensetrack/features/transactions/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Use the same collection name as your provider (case-sensitive).
    final Stream<QuerySnapshot> txStream = FirebaseFirestore.instance
        .collection('Transactions') // <-- make sure this matches your provider
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        centerTitle: true,
        title: const Text(
          "Transactions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleText(title: "Filters"),
                  Wrap(
                    direction: Axis.horizontal,
                    runSpacing: 10,
                    spacing: 13,
                    children: [
                      _filterChip(context, "Last 7 days"),
                      _filterChip(context, "This month"),
                      _filterChip(context, "Last month"),
                      _filterChip(context, "Custom"),
                    ],
                  ),
                  const TitleText(title: "Summary"),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Summary(
                        title: 'Income',
                        amount: '\$2,500', // TODO: Calculate from Firebase
                        size: size.width * 0.855 / 2.0,
                      ),
                      Summary(
                        title: "Expenses",
                        amount: "\$1,200", // TODO: Calculate from Firebase
                        size: size.width * 0.855 / 2.0,
                      ),
                    ],
                  ),
                  Summary(
                    title: "Balance",
                    amount: "\$1,300", // TODO: Calculate from Firebase
                    size: size.width * 0.9,
                  ),
                  const TitleText(title: "Transactions"),

                  // StreamBuilder with robust parsing
                  StreamBuilder<QuerySnapshot>(
                    stream: txStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text("Error: ${snapshot.error}"),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No transactions found"),
                        );
                      }

                      // Use a ListView inside Column: shrinkWrap and disable its own scrolling
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};

                          // Determine expense/income (support both field names)
                          bool isExpense;
                          if (data.containsKey('expense') &&
                              data['expense'] is bool) {
                            isExpense = data['expense'] as bool;
                          } else if (data.containsKey('income') &&
                              data['income'] is bool) {
                            // if only 'income' exists, invert it to get expense
                            isExpense = !(data['income'] as bool);
                          } else {
                            // default
                            isExpense = true;
                          }
                          final isIncome = !isExpense;

                          // Title
                          final title =
                              (data['title']?.toString() ?? 'Untitled')
                                  .toString();

                          // Category (optional)
                          final category = data['category']?.toString() ?? '';

                          // Date: support Timestamp or ISO string; fallback = ""
                          String dateText = '';
                          if (data['date'] is Timestamp) {
                            final dt = (data['date'] as Timestamp).toDate();
                            dateText = DateFormat.yMMMd().format(dt);
                          } else if (data['date'] is String) {
                            final parsed = DateTime.tryParse(data['date']);
                            if (parsed != null)
                              dateText = DateFormat.yMMMd().format(parsed);
                          }

                          // Subtitle: combine category and date if both present
                          final subtitle = [
                            if (category.isNotEmpty) category,
                            if (dateText.isNotEmpty) dateText,
                          ].join(' • ');

                          // Amount: support num or string
                          double amount = 0.0;
                          final amtRaw = data['amount'];
                          if (amtRaw is num) {
                            amount = amtRaw.toDouble();
                          } else if (amtRaw is String) {
                            amount = double.tryParse(amtRaw) ?? 0.0;
                          }

                          // Icon & color
                          final icon = isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded;
                          final amountColor = isIncome
                              ? AppColors.green
                              : AppColors.expenseColor;
                          final costText = isIncome
                              ? "+\$${amount.toStringAsFixed(2)}"
                              : "-\$${amount.toStringAsFixed(2)}";

                          return TransactionsWidgets(
                            icon: icon,
                            title: title,
                            subtitle: subtitle,
                            cost: costText,
                            amountColor: amountColor,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Add Income Button
          Positioned(
            bottom: 20,
            left: 20,
            child: IncomeExpenseAdd(
              buttoncolor: AppColors.addIncome,
              buttonicon: Icons.wallet,
              title: "Add Income",
              onbuttonPressed: () {
                _openBottomSheet(context, 'Income Name', 0);
              },
            ),
          ),

          /// Add Expense Button
          Positioned(
            bottom: 20,
            right: 20,
            child: IncomeExpenseAdd(
              buttoncolor: AppColors.addExpensee,
              buttonicon: Icons.wallet,
              title: "Add Expense",
              onbuttonPressed: () {
                _openBottomSheet(context, 'Expense Name', 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for filter chips
  Widget _filterChip(BuildContext context, String label) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.3,
      child: FilterTime(filterdate: label),
    );
  }

  /// Helper for opening bottom sheet
  void _openBottomSheet(BuildContext context, String name, int key) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionBottomsheet(transactionName: name, itemkey: key),
      ),
    );
  }
}

class IncomeExpenseAdd extends StatelessWidget {
  final Color buttoncolor;
  final IconData buttonicon;
  final String title;
  final VoidCallback onbuttonPressed;
  const IncomeExpenseAdd({
    super.key,
    required this.buttoncolor,
    required this.buttonicon,
    required this.title,
    required this.onbuttonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.06,
      child: FilledButton(
        style: FilledButton.styleFrom(
          maximumSize: Size.fromWidth(MediaQuery.sizeOf(context).width * 0.43),
          backgroundColor: buttoncolor,
        ),
        onPressed: onbuttonPressed,
        child: Row(
          children: [
            Icon(buttonicon),
            const SizedBox(width: 2),
            Flexible(
              child: FittedBox(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.cardWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
