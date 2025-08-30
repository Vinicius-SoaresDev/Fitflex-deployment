import 'package:fitflex/core/config/app_theme.dart';
import 'package:fitflex/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitlex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SignupPage(), // <= ATENÇÃO AO NOME
    );
  }
}
