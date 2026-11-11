import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores EDP (Color Vino y neutros)
  static const Color primary = Color(0xFF7A1C30); // Color Vino Elegante
  static const Color primaryLight = Color(
    0xFFA62C47,
  ); // Vino más claro para acentos
  static const Color background = Color(
    0xFFF4F6F8,
  ); // Fondo gris perla muy ligero
  static const Color textDark = Color(0xFF1E293B); // Texto oscuro (casi negro)
  static const Color textMuted = Color(0xFF64748B); // Texto secundario
  static const Color cardShadow = Color(
    0x0F000000,
  ); // Sombra muy sutil (6% opacidad)

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary), // Íconos color vino
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: Colors.grey[200],
    );
  }
}
