import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/auth/provider/auth_provider.dart';
import 'package:expensetrack/features/home/provider/bottom_nav_provider.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/services/all_transaction_entity_service.dart';
import 'package:expensetrack/features/transactions/services/entity_repository.dart';
import 'package:expensetrack/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MultiProvider> allProviders() async {
  final prefs = await SharedPreferences.getInstance();
  return MultiProvider(
    providers: [
      // 1️⃣ Provide repositories first (these don't depend on anything)
      Provider<AddTransactionRepo>(create: (_) => AddTransactionRepo()),
      Provider<EntityRepositoryService>(
        create: (_) => EntityRepositoryService(
          prefs: prefs,
          firestore: FirebaseFirestore.instance,
        ),
      ),

      // 2️⃣ Basic ChangeNotifierProviders (these don't depend on other providers)
      ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ChangeNotifierProvider(create: (_) => TransactionDataProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => SwitchExpenseProvider()),

      // 3️⃣ Providers that depend on repositories
      ChangeNotifierProxyProvider<EntityRepositoryService, PartiesProvider>(
        create: (context) =>
            PartiesProvider(context.read<EntityRepositoryService>()),
        update: (context, repository, previous) =>
            previous ?? PartiesProvider(repository),
      ),

      ChangeNotifierProxyProvider<AddTransactionRepo, AddTransactionProvider>(
        create: (context) =>
            AddTransactionProvider(context.read<AddTransactionRepo>()),
        update: (context, repository, previous) =>
            previous ?? AddTransactionProvider(repository),
      ),
    ],
    child: MyApp(),
  );
}
