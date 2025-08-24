// import 'package:expensetrack/features/pdf_generation/screen/pdf_reports_screen.dart';
import 'package:expensetrack/pdf_generation/screen/reports_screen.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: preferredSize.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "Home",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                iconSize: MediaQuery.sizeOf(context).height * 0.035,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                },
                icon: Icon(Icons.settings_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
