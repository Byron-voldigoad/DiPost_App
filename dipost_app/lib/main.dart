import 'package:dipost_app/database/database_helper.dart';
import 'package:dipost_app/providers/ibox_provider.dart';
import 'package:dipost_app/screens/auth/login_screen.dart';
import 'package:dipost_app/screens/auth/register_screen.dart';
import 'package:dipost_app/screens/home/home_screen.dart';
import 'package:dipost_app/screens/ibox/ibox_list.dart';
import 'package:dipost_app/screens/isignature/isignature_home.dart';
import 'package:dipost_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   final dbHelper = DatabaseHelper.instance;
  // Initialisation de la base de données
  // await dbHelper.deleteAppDatabase();
  await dbHelper.database;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IBoxProvider()),
      ],
      child: const DiPostApp(),
    ),
  );
}

class DiPostApp extends StatelessWidget {
  const DiPostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiPost',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/ibox': (context) => const IBoxListScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/isignature': (context) => const ISignatureHomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return authProvider.state.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}