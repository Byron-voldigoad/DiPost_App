import 'package:dipost_app/providers/livraison_provider.dart';
import 'package:dipost_app/providers/user_provider.dart';
import 'package:dipost_app/screens/colis/demande_livraison_screen.dart';
import 'package:dipost_app/screens/livraison/livraison_detail_screen.dart';
import 'package:dipost_app/screens/livraison/livraison_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipost_app/services/database_helper.dart';
import 'constants/route_names.dart';
import 'providers/auth_provider.dart';
import 'providers/colis_provider.dart';
import 'providers/ibox_provider.dart';
import 'providers/signature_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main/dashboard_screen.dart';
import 'screens/ibox/ibox_list_screen.dart';
import 'screens/colis/colis_list_screen.dart';
import 'screens/signature/signature_list_screen.dart';
import 'screens/signature/signature_create_screen.dart';
import 'package:dipost_app/screens/colis/add_colis_screen.dart';
import 'package:dipost_app/screens/livraison/livraison_list_user_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Décommenter seulement pour la première initialisation ou réinitialisation
  // await DatabaseHelper.instance.recreateDatabase();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IBoxProvider()),
        ChangeNotifierProvider(create: (_) => ColisProvider()),
        ChangeNotifierProvider(create: (_) => SignatureProvider()),
        ChangeNotifierProvider(create: (_) => LivraisonProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
      title: 'DiPost App',
      theme: _buildAppTheme(),
      initialRoute: RouteNames.login,
      routes: _buildAppRoutes(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _handleUnknownRoutes,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      RouteNames.login: (context) => const LoginScreen(),
      RouteNames.signup: (context) => const SignupScreen(),
      RouteNames.dashboard: (context) => const DashboardScreen(),
      RouteNames.iboxList: (context) => const IBoxListScreen(),
      RouteNames.colisList: (context) => const ColisListScreen(),
      RouteNames.signatureList: (context) => const SignatureListScreen(),
      RouteNames.signatureCreate: (context) => const SignatureCreateScreen(),
      RouteNames.livraisonList: (context) => const LivraisonScanScreen(),
      RouteNames.livraisonListUser: (context) => const LivraisonListUserScreen(),
      // RouteNames.livraisonDetail: (context) => const LivraisonDetailScreen()
      
    };
  }

  Route<dynamic> _handleUnknownRoutes(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Page non trouvée'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.dashboard),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}