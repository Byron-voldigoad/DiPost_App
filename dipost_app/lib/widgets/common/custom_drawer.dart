import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/route_names.dart';
import '../../screens/theme/app_theme.dart'; // Assure-toi que ce chemin est correct

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text(
              '${authProvider.user?.prenom ?? ''} ${authProvider.user?.nom ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(authProvider.user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: primaryColor),
            ),
          ),
          _buildDrawerTile(
            context,
            icon: Icons.home,
            label: 'Accueil',
            routeName: RouteNames.dashboard,
            color: primaryColor,
          ),
          if (authProvider.isAdmin || authProvider.isOperateur)
            _buildDrawerTile(
              context,
              icon: Icons.storage,
              label: 'iBox',
              routeName: RouteNames.iboxList,
              color: primaryColor,
            ),
          if (authProvider.isAdmin || authProvider.isOperateur || authProvider.isLivreur)
            _buildDrawerTile(
              context,
              icon: Icons.mail,
              label: 'Colis',
              routeName: RouteNames.colisList,
              color: primaryColor,
            ),
          if (authProvider.isAdmin)
            _buildDrawerTile(
              context,
              icon: Icons.people,
              label: 'Utilisateurs',
              routeName: RouteNames.userManagement,
              color: primaryColor,
            ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: primaryColor),
            title: Text('Déconnexion', style: TextStyle(color: primaryColor)),
            onTap: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(BuildContext context,
      {required IconData icon,
      required String label,
      required String routeName,
      required Color color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => Navigator.pushReplacementNamed(context, routeName),
    );
  }
}
