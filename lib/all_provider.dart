import 'package:expensetrack/auth/provider/auth_provider.dart';
import 'package:expensetrack/features/home/provider/bottom_nav_provider.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/screen/partyscreen.dart';
import 'package:expensetrack/features/transactions/services/all_transaction_entity_service.dart';
import 'package:expensetrack/features/transactions/services/entity_repository.dart';
import 'package:expensetrack/main.dart';
import 'package:provider/provider.dart';

MultiProvider allProviders() {
  return MultiProvider(
    providers: [
      // 1️⃣ Provide repositories first (these don't depend on anything)
      Provider<AddTransactionRepo>(create: (_) => AddTransactionRepo()),
      Provider<EntityRepositoryService>(
        create: (_) => EntityRepositoryService(),
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
