import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/route_names.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('${authProvider.user?.prenom} ${authProvider.user?.nom}'),
            accountEmail: Text(authProvider.user?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => Navigator.pushReplacementNamed(context, RouteNames.dashboard),
          ),
          if (authProvider.isAdmin || authProvider.isOperateur)
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('iBox'),
              onTap: () => Navigator.pushReplacementNamed(context, RouteNames.iboxList),
            ),
          if (authProvider.isAdmin || authProvider.isOperateur || authProvider.isLivreur)
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Colis'),
              onTap: () => Navigator.pushReplacementNamed(context, RouteNames.colisList),
            ),
          if (authProvider.isAdmin)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Utilisateurs'),
              onTap: () => Navigator.pushReplacementNamed(context, RouteNames.userManagement),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
          ),
        ],
      ),
    );
  }
}