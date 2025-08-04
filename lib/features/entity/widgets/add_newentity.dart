import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/home/widgets/income_expense_toggle.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewentity extends StatelessWidget {
  const AddNewentity({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController entityController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    // final provider = Provider.of<SwitchExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Add New Entity"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.info_outline))],
      ),
      body: Column(
        children: [
          SizedBox(height: 27),
          Center(
            child: CircleAvatar(
              backgroundColor: AppColors.filterColor,
              radius: 42,
              child: Icon(
                Icons.person_3,
                size: 50,
                color: AppColors.textTitleColor,
              ),
            ),
          ),
          SizedBox(height: 30),
          NewPartyField(
            labelText: 'Entity Name',
            keyboard: TextInputType.name,
            controller: entityController,
          ),
          SizedBox(height: 20),
          NewPartyField(
            labelText: 'Phone Number',
            keyboard: TextInputType.phone,
            controller: numberController,
          ),
          SizedBox(height: 25),
          IncomeExpenseToggle(
            firstIndex: 'Amount Info',
            secondIndex: 'Additional Details',
          ),
          Consumer2<SwitchExpenseProvider, TransactionDataProvider>(
            builder: (context, switchprovider, transactionprovider, _) {
              return switchprovider.selectedIndex == 0
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.4,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.08,
                                child: TextFormField(
                                  // autofocus: true,
                                  keyboardType: TextInputType.number,
                                  controller: amountController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.currency_rupee_rounded,
                                      color: Colors.black54,
                                    ),
                                    labelText: "Amount",
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    enabled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.green.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () =>
                                    transactionprovider.pickDate(context),
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.07,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.calendar_month_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          transactionprovider.selectedDate,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal,
                                            color:
                                                transactionprovider
                                                        .selectedDate ==
                                                    "Date"
                                                ? Colors.grey.shade400
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Column(children: [
                    
              ],
            );
            },
          ),
        ],
      ),
    );
  }
}

class NewPartyField extends StatelessWidget {
  final String labelText;
  final TextInputType keyboard;
  final TextEditingController controller;
  const NewPartyField({
    super.key,
    required this.labelText,
    required this.keyboard,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        // autofocus: true,
        keyboardType: keyboard,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          enabled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.shade300),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
