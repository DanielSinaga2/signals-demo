import 'package:flutter/material.dart';
import 'pages/login_page.dart';

class SignalsDemoApp extends StatelessWidget {
  const SignalsDemoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Signals Product Management',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: const LoginPage(),
  );
}
