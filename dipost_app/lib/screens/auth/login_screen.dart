import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);
    
    return Scaffold(
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(authProvider),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4.0,
              color: Color.lerp(Colors.white, primaryColor, 0.1), // Alternative à withOpacity
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bienvenue sur DiPost',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.grey[50], primaryColor, 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AuthFormField(
                          controller: _emailController,
                          label: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Color.lerp(Colors.grey[50], primaryColor, 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AuthFormField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthButton(
                        text: 'Se connecter',
                        color: primaryColor,
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final success = await authProvider.login(
                              _emailController.text,
                              _passwordController.text,
                            );

                            if (!mounted) return;

                            if (success) {
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, RouteNames.dashboard);
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Email ou mot de passe incorrect'),
                                    backgroundColor: Color.lerp(
                                      primaryColor, 
                                      Colors.black, 
                                      0.2
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RouteNames.signup);
                        },
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: Color.lerp(primaryColor, Colors.white, 0.2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}