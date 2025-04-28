// Profile screen 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                '${user?.prenom?.substring(0, 1)}${user?.nom?.substring(0, 1)}',
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text('Nom complet'),
                subtitle: Text('${user?.prenom} ${user?.nom}'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Email'),
                subtitle: Text(user?.email ?? ''),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Téléphone'),
                subtitle: Text(user?.telephone ?? 'Non renseigné'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Rôle'),
                subtitle: Text(user?.role.toUpperCase() ?? ''),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}