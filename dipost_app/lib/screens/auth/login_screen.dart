import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/auth_button.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion DiPost'),
      backgroundColor: const Color.fromARGB(255, 119, 5, 154),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthFormField(
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
              const SizedBox(height: 16),
              AuthFormField(
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
              const SizedBox(height: 24),
              AuthButton(
                text: 'Se connecter',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await authProvider.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                    
                    if (!mounted) return;
                    
                    if (success) {
                      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email ou mot de passe incorrect')),
                      );
                    }
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.signup);
                },
                child: const Text('Créer un compte'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.forgotPassword);
                },
                child: const Text('Mot de passe oublié?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}