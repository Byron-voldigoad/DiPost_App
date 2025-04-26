import 'package:dipost_app/providers/auth_provider.dart';
import 'package:dipost_app/screens/auth/login_screen.dart';
import 'package:dipost_app/screens/ibox/ibox_list.dart';
import 'package:dipost_app/screens/isignature/isignature_home.dart';
import 'package:dipost_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DiPost - Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => authProvider.state.isAuthenticated
                      ? const ProfileScreen()
                      : const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Services Postaux Digitaux',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildServiceCard(
                  context,
                  Icons.mail,
                  'iBox',
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IBoxListScreen()),
                  ),
                ),
               _buildServiceCard(
  context,
  Icons.assignment,
  'iSignature',
  Colors.green,
  () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ISignatureHomeScreen()),
  ),
),
_buildServiceCard(
  context,
  Icons.delivery_dining,
  'Livraison',
  Colors.orange,
  () {
    // TODO: Écran de livraison
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module de livraison à implémenter')),
    );
  },
),
                _buildServiceCard(
                  context,
                  Icons.payment,
                  'Paiements',
                  Colors.purple,
                  () {}, // À implémenter
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: color),
            const SizedBox(height: 8.0),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}