import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/chart/screen/financial_dashboard.dart';
import 'package:expensetrack/features/entity/screen/addentity.dart';
import 'package:expensetrack/features/home/provider/bottom_nav_provider.dart';
import 'package:expensetrack/features/home/screen/home.dart';
import 'package:expensetrack/features/other_assets/screen/financial_dashboard_screen.dart';
import 'package:expensetrack/features/transactions/screen/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final List<Widget> _screens = [
    Home(),
    TransactionScreen(),
    FinancialDashboard(),
    // BudgetScreen(),
    AddEntity(),
    // SettingsScreen(),
    FinancialDashboardScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    return Scaffold(
      body: _screens[navProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        unselectedItemColor: AppColors.transactiontype,
        currentIndex: navProvider.currentIndex,
        onTap: navProvider.onitemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_to_mobile_outlined),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_rounded),
            label: "Budget",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Add Party"),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: "Other Assets",
          ),
        ],
      ),
    );
  }
}
