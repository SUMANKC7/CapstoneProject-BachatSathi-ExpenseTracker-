import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/widgets/add_dates.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTransactionBottomsheet extends StatelessWidget {
  final String transactionName;

  const AddTransactionBottomsheet({super.key, required this.transactionName});

  @override
  Widget build(BuildContext context) {
    final addTransactionProvider = Provider.of<TransactionDataProvider>(
      context,
      listen: false,
    );

    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  autofocus: true,
                  maxLines: 1,
                  style: TextStyle(
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
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close, size: 27),
              ),
            ],
          ),
          
          InputData(),
          AddDates(),
      
          SizedBox(height: 20),
      
          Text(
            "Select Category",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.grey.shade400,
            ),
          ),
      
          SizedBox(height: 15),
      
          Wrap(
            spacing: 10,
            runSpacing: 3,
            children: List.generate(addTransactionProvider.expensecategories.length, (index) {
              return IntrinsicWidth(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.filterColor,
                      ),
                      child: Center(
                        child: Text(
                          addTransactionProvider.expensecategories[index],
                          style: TextStyle(
                            color: AppColors.filterTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    if(index == addTransactionProvider.expensecategories.length-1)
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Container(
                          height: MediaQuery.sizeOf(context).height*0.07,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.shade400,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: (){},
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(MediaQuery.sizeOf(context).height*0.06),
              backgroundColor: Colors.red.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ),
            child: Text("Add Expense",style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.backgroundColor
            ),)
          ),
SizedBox(height: 30,)
        ],
      ),
    );
  }
}

class InputData extends StatelessWidget {
  const InputData({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 13),
      child: TextFormField(
        keyboardType: TextInputType.number,
        maxLines: 1,
        style: TextStyle(
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
  required hinttext,
  required keyboardtype,
}) {
  return TextFormField(
    focusNode: FocusNode(),
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
