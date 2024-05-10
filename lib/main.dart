import 'package:coffeeshop_app/constants.dart';
import 'package:flutter/material.dart';

import 'pages/login.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Constants.initialize();
    return MaterialApp(
      title: 'My CoffeeShop App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
