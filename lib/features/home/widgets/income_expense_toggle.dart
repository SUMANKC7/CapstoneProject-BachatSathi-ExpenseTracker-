import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IncomeExpenseToggle extends StatefulWidget {
  final String firstIndex;
  final String secondIndex;
  const IncomeExpenseToggle({
    super.key,
    required this.firstIndex,
    required this.secondIndex,
  });

  @override
  State<IncomeExpenseToggle> createState() => _IncomeExpenseToggleState();
}

class _IncomeExpenseToggleState extends State<IncomeExpenseToggle> {
  @override
  Widget build(BuildContext context) {
    final toggleprovider = context.watch<SwitchExpenseProvider>();
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(2, (index) {
          final isSelected = toggleprovider.selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                toggleprovider.toggleIndex(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  index == 0 ? widget.firstIndex : widget.secondIndex,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
