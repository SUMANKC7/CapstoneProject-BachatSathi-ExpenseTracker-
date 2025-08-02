import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/all_provider.dart';
import 'package:expensetrack/features/home/screen/addparties.dart';
import 'package:expensetrack/features/home/screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true, //Enable offline cache
  );
  runApp(allProviders());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: "serif"),
      home: const Addparties(),
    );
  }
}
