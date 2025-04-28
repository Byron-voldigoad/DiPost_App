import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../constants/route_names.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
        );
        return;
      }

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.register(
          email: _emailController.text,
          password: _passwordController.text,
          nom: _nomController.text,
          prenom: _prenomController.text,
          telephone: _telephoneController.text,
        );
        
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription'),
      backgroundColor: const Color.fromARGB(255, 119, 5, 154),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthFormField(
                controller: _nomController,
                label: 'Nom',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _prenomController,
                label: 'Prénom',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
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
                controller: _telephoneController,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre téléphone';
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
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthFormField(
                controller: _confirmPasswordController,
                label: 'Confirmer le mot de passe',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: 'S\'inscrire',
                onPressed: _submitForm,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, RouteNames.login);
                },
                child: const Text('Déjà un compte? Connectez-vous'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}