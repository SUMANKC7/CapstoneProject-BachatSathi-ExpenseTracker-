import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({super.key});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  @override
  Widget build(BuildContext context) {
    final transactionDataprovider = Provider.of<TransactionDataProvider>(
      context,
      listen: false,
    );
    return DropdownMenu<String>(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.summaryBorder),
        fixedSize: WidgetStateProperty.all<Size>(
          Size(280, 200), // width and max height of dropdown menu
        ),
      ),
      width: double.infinity,
      hintText: "Category",
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.transactiontype),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(15),
        ),

        fillColor: AppColors.summaryBorder,
        filled: true,
      ),
      onSelected: (String? value) {
        if (value != null) {
          transactionDataprovider.selectCategory(value);
        }
      },
      initialSelection: transactionDataprovider.selectedCategory,
      dropdownMenuEntries: transactionDataprovider.categories.map((category) {
        return DropdownMenuEntry(value: category, label: category);
      }).toList(),
    );
  }
}
