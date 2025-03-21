import 'package:flutter/material.dart';

import 'presentation/screens/user_input_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb && TelegramWebApp.instance.isSupported) {
  //   try {
  //     // Telegram Web App initialization.
  //     TelegramWebApp.instance.ready();
  //     Future.delayed(
  //         const Duration(seconds: 1), TelegramWebApp.instance.expand);
  //   } catch (e) {
  //     // On error, retry after a short delay.
  //     print("Error in Telegram initialization: $e");
  //     await Future.delayed(const Duration(milliseconds: 200));
  //     main();
  //     return;
  //   }
  // }

  // // Step 3: Setup Flutter error handling.
  // FlutterError.onError = (details) {
  //   print("Flutter error: $details");
  // };

  // Step 4: Run the main application.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Опросник здоровья',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserInputScreen(),
    );
  }
}
