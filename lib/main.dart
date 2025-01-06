
import 'package:flutter/material.dart';
import 'presentation/screens/user_input_screen.dart';

void main() {
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