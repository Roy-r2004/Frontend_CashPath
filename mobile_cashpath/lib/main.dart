import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_cashpath/providers/transaction_provider.dart';
import 'package:mobile_cashpath/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CashPath',
      theme: ThemeData.dark(),
      home: SplashScreen(), // SplashScreen is now the initial screen
    );
  }
}
