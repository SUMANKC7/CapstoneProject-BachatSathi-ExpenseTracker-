// import 'package:expensetrack/features/pdf_generation/screen/pdf_reports_screen.dart';
import 'package:expensetrack/core/appcolors.dart';
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
              child: CircleAvatar(
                radius:
                    MediaQuery.sizeOf(context).height * 0.028, // adjust size
                backgroundColor:
                    AppColors.green, // your circle background color
                child: IconButton(
                  iconSize:
                      MediaQuery.sizeOf(context).height *
                      0.025, // keep smaller than circle
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportsScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                  ), // white for contrast
                ),
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
