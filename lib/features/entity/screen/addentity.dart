import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/widgets/filter_widget.dart';
import 'package:expensetrack/features/transactions/widgets/transaction_widget.dart';
import 'package:flutter/material.dart';

class AddEntity extends StatelessWidget {
  const AddEntity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text("Entity"),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.navBarIcon),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(
                            Icons.search,
                            size: 30,
                            color: AppColors.subTextGrey,
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.55,
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search Entity",
                                hintStyle: TextStyle(
                                  color: AppColors.subTextGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 17),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.13,
                      height: 49,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.subTextGrey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.filter_list),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: [
                      FilterTime(filterdate: "All"),
                      FilterTime(filterdate: "To Give"),
                      FilterTime(filterdate: 'To Receive'),
                      FilterTime(filterdate: "Settled"),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Divider(),
                SizedBox(height: 15),
                TransactionsWidgets(
                  icon: Icons.person,
                  title: "hari",
                  subtitle: "2082 Shr 12",
                  cost: "1200",
                  amountColor: Colors.green,
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "addnewentity");
              },
              child: Container(
                height: 46,
                width: MediaQuery.sizeOf(context).width * 0.41,
                decoration: BoxDecoration(
                  color: AppColors.greenAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1, color: AppColors.cardWhite),
                    SizedBox(width: 5),
                    Text(
                      "New Entity",
                      style: TextStyle(color: AppColors.cardWhite),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
