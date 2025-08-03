import 'package:expensetrack/features/entity/screen/addentity.dart';
import 'package:expensetrack/features/entity/widgets/add_newentity.dart';
import 'package:expensetrack/features/home/screen/homescreen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => Homescreen());
      case "addentity":
        return MaterialPageRoute(builder: (context) => AddEntity());
      case "addnewentity":
        return MaterialPageRoute(builder: (context) => AddNewentity());

      default:
        return MaterialPageRoute(builder: (context) => Homescreen());
    }
  }
}
