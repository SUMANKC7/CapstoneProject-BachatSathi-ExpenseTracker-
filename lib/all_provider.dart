
import 'package:expensetrack/auth/provider/auth_provider.dart';
import 'package:expensetrack/features/home/provider/bottom_nav_provider.dart';
import 'package:expensetrack/features/transactions/provider/select_date_provider.dart';
import 'package:expensetrack/features/transactions/provider/switch_transaction_provider.dart';
import 'package:expensetrack/features/transactions/provider/transaction_data_provider.dart';
import 'package:expensetrack/main.dart';
import 'package:provider/provider.dart';

MultiProvider allProviders() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ChangeNotifierProvider(create: (_) => SelectDateProvider()),
      ChangeNotifierProvider(create: (_) => SwitchTransactionProvider()),
      ChangeNotifierProvider(create: (_)=>TransactionDataProvider()),
      ChangeNotifierProvider(create: (_)=>AuthProvider()),
    ],
    child: MyApp(),
  );
}
