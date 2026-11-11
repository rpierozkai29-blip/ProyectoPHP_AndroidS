import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart'; // Importa el tema

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EDP Dashboard',
      theme: AppTheme.lightTheme, // Aplica el tema global aquí
      home: LoginScreen(),
    );
  }
}
