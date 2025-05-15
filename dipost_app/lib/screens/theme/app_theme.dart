import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

class AppTheme {
  static Color getPrimaryColor(AuthProvider authProvider) {
    if (authProvider.isAdmin) return const Color.fromARGB(255, 92, 142, 201);
    if (authProvider.isOperateur || authProvider.isLivreur)
      return const Color.fromARGB(255, 9, 149, 72);
    if (authProvider.isClient) return const Color.fromARGB(255, 102, 173, 9);
    return const Color.fromARGB(255, 22, 120, 185);
  }

  static ThemeData getThemeData(AuthProvider authProvider) {
    final primaryColor = getPrimaryColor(authProvider);

    return ThemeData(
      primarySwatch: _createMaterialColor(primaryColor),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        elevation: 1,
        centerTitle: true,
        backgroundColor: primaryColor,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      // Ajout de l'image de fond pour les Scaffold
      scaffoldBackgroundColor: Colors.transparent,
      // Optionnel: vous pouvez aussi définir un style par défaut pour les Scaffold
      // qui utilisera cette image de fond
    );
  }

  // Méthode pour obtenir un BoxDecoration avec l'image de fond
  static BoxDecoration getBackgroundDecoration(AuthProvider authProvider) {
    final primaryColor = getPrimaryColor(authProvider);
    return BoxDecoration(
      color: primaryColor.withOpacity(0.1), // Couche de teinte
      image: DecorationImage(
        image: AssetImage('assets/background_dark.png'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          primaryColor.withOpacity(0.8),
          BlendMode.softLight, // Donne un effet plus doux
        ),
      ),
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        (r + ((ds < 0 ? r : (255 - r)) * ds).round()).clamp(0, 255),
        (g + ((ds < 0 ? g : (255 - g)) * ds).round()).clamp(0, 255),
        (b + ((ds < 0 ? b : (255 - b)) * ds).round()).clamp(0, 255),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
