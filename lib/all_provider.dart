import 'package:expensetrack/auth/provider/auth_provider.dart';
import 'package:expensetrack/features/home/provider/bottom_nav_provider.dart';
import 'package:expensetrack/features/home/provider/switch_expense.dart';
import 'package:expensetrack/features/transactions/provider/add_entity_provider.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/features/transactions/services/add_entity_services.dart';
import 'package:expensetrack/main.dart';
import 'package:provider/provider.dart';

MultiProvider allProviders() {
  return MultiProvider(
    providers: [
      // 1️⃣ Provide EntityRepository first
      Provider<EntityRepository>(create: (_) => EntityRepository()),

      // 2️⃣ Other providers
      ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ChangeNotifierProvider(create: (_) => TransactionDataProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => SwitchExpenseProvider()),

      // 3️⃣ Proxy providers that depend on EntityRepository
      ChangeNotifierProxyProvider<EntityRepository, PartiesProvider>(
        create: (context) => PartiesProvider(context.read<EntityRepository>()),
        update: (context, repository, previous) =>
            previous ?? PartiesProvider(repository),
      ),
      ChangeNotifierProxyProvider<EntityRepository, AddEntityProvider>(
        create: (context) =>
            AddEntityProvider(context.read<EntityRepository>()),
        update: (context, repository, previous) =>
            previous ?? AddEntityProvider(repository),
      ),
    ],
    child: MyApp(),
  );
}
