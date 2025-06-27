

import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/core/widgets/title_text.dart';
import 'package:expensetrack/features/budget/widgets/budget_tile.dart';
import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budgets"),
        centerTitle: true,
        ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              TitleText(title: "Spending Categories"),
              BudgetTile(icon: Icons.local_pizza_outlined, title: 'Food', totalBudget: '\$500', expenses: '\$200',),
               BudgetTile(icon: Icons.movie_sharp, title: 'Entertainment', totalBudget: '\$300', expenses: '\$150',),
                BudgetTile(icon: Icons.shopping_bag_outlined, title: 'Shopping', totalBudget: '\$200', expenses: '\$50',),
                 BudgetTile(icon: Icons.emoji_transportation_outlined, title: 'Transportation', totalBudget: '\$300', expenses: '\$100',),
                  BudgetTile(icon: Icons.note_outlined, title: 'Utilities', totalBudget: '\$100', expenses: '\$50',),
                  SizedBox(height: 50,),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: OutlinedButton(
                      onPressed: (){}, 
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.subTextGrey),
                        
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.add,size: 30,color: AppColors.subTextGrey,),
                      
                      Text("Add Budget",style: TextStyle(fontSize: 17,color: AppColors.navBarSelected),)
                    ],)
                    ),
                  ),
                  SizedBox(height: 10,)
            ],
          ),
        ),
      ),
      
    );
  }
}