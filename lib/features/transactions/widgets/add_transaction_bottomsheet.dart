import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/widgets/add_dates.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTransactionBottomsheet extends StatelessWidget {
  final String transactionName;
  final int itemkey; // 0 = income, 1 = expense

  const AddTransactionBottomsheet({
    super.key,
    required this.transactionName,
    required this.itemkey,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionDataProvider>(context);

    // Set transaction type based on itemkey
    provider.setTransactionType(itemkey == 1); // true = expense, false = income

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // Title field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: provider.titleController,
                    autofocus: true,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: transactionName,
                      hintStyle: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    cursorColor: Colors.grey.shade400,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 27),
                ),
              ],
            ),

            // Amount input
            InputData(amountcontroller: provider.amountController),

            // Date picker
            AddDates(),

            const SizedBox(height: 20),

            // Category selection title
            Text(
              "Select Category",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 15),

            // Category chips
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: List.generate(
                itemkey == 0
                    ? provider.incomeCategories.length
                    : provider.expenseCategories.length,
                (index) {
                  final category = itemkey == 0
                      ? provider.incomeCategories[index]
                      : provider.expenseCategories[index];

                  final isSelected = provider.selectedCategory == category;

                  return GestureDetector(
                    onTap: () => provider.setCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Colors.green.shade300
                            : AppColors.filterColor,
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.filterTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Remarks input
            transactionadd(
              mycontroller: provider.descriptionController,
              hinttext: "Remarks",
              keyboardtype: TextInputType.text,
            ),

            const SizedBox(height: 20),

            // Add button
            ElevatedButton(
              onPressed: () {
                provider.addTransaction();
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(
                  MediaQuery.sizeOf(context).height * 0.06,
                ),
                backgroundColor: itemkey == 0
                    ? Colors.green.shade300
                    : Colors.red.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                itemkey == 0 ? 'Add Income' : "Add Expense",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundColor,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class InputData extends StatelessWidget {
  final TextEditingController amountcontroller;
  const InputData({super.key, required this.amountcontroller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 13),
      child: TextFormField(
        controller: amountcontroller,
        keyboardType: TextInputType.number,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          labelText: "Amount",
          labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 19),
          prefixText: "\$ ",
          hintText: "Amount",
          hintStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade400,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        cursorColor: Colors.grey.shade400,
      ),
    );
  }
}

TextFormField transactionadd({
  required TextEditingController mycontroller,
  required String hinttext,
  required TextInputType keyboardtype,
}) {
  return TextFormField(
    controller: mycontroller,
    keyboardType: keyboardtype,
    maxLines: null,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      filled: true,
      fillColor: AppColors.summaryBorder,
      hintText: hinttext,
      hintStyle: TextStyle(color: AppColors.transactiontype),
    ),
  );
}
