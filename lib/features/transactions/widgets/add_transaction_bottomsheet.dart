
import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/widgets/add_dates.dart';
import 'package:expensetrack/features/transactions/widgets/drop_down_widget.dart';
import 'package:expensetrack/features/transactions/widgets/switch_transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTransactionBottomsheet extends StatelessWidget {
  const AddTransactionBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    final addTransactionProvider = Provider.of<TransactionDataProvider>( context,listen: false );

    return IconButton(
      onPressed: () {
        showBottomSheet(
          constraints: BoxConstraints.tight(
            Size(
              MediaQuery.sizeOf(context).width * 0.9,
              MediaQuery.sizeOf(context).height * 0.7,
            ),
          ),
          context: context,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close),
                      ),
                      Text("Add Transactions"),
                    ],
                  ),

                  transactionadd(
                    mycontroller: addTransactionProvider.amountController,
                    hinttext: "Amount",
                    keyboardtype: TextInputType.number,
                  ),

                  DropDownWidget(),
                  AddDates(),
                  transactionadd(
                    mycontroller: addTransactionProvider.descriptionController,
                    hinttext: "Description",
                    keyboardtype: TextInputType.multiline,
                  ),
                  SwitchTransactionWidget(),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      addTransactionProvider.addTransaction();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 300),
                        content: Text("content added")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navBarIcon,
                      fixedSize: Size.fromWidth(double.maxFinite),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: AppColors.summaryBorder),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      icon: Icon(Icons.add, size: 30),
    );
  }
}

TextFormField transactionadd({
  required TextEditingController mycontroller,
  required hinttext,
  required keyboardtype,
}) {
  return TextFormField(
    controller: mycontroller,
    keyboardType: keyboardtype,
    maxLines: null,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      filled: true,
      fillColor: AppColors.summaryBorder,
      hintText: hinttext,
      hintStyle: TextStyle(color: AppColors.transactiontype),
    ),
  );
}
