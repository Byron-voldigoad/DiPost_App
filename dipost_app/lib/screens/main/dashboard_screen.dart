import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/custom_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _buildDashboardContent(context, authProvider),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildUserCard(authProvider),
          const SizedBox(height: 20),
          Expanded(child: _buildActionGrid(context, authProvider)),
        ],
      ),
    );
  }

  Widget _buildUserCard(AuthProvider authProvider) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text('${authProvider.user?.prenom} ${authProvider.user?.nom}'),
        subtitle: Text(authProvider.user?.email ?? ''),
        trailing: Chip(
          label: Text(authProvider.user?.role.toUpperCase() ?? ''),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, AuthProvider authProvider) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        if (authProvider.isAdmin || authProvider.isOperateur)
          _DashboardAction(
            icon: Icons.storage,
            label: 'Gestion iBox',
            onTap: () => Navigator.pushNamed(context, RouteNames.iboxList),
          ),
        if (authProvider.isAdmin || authProvider.isOperateur)
          _DashboardAction(
            icon: Icons.mail,
            label: 'Gestion Colis',
            onTap: () => Navigator.pushNamed(context, RouteNames.colisList),
          ),
        if (authProvider.isAdmin)
          _DashboardAction(
            icon: Icons.people,
            label: 'Gestion Utilisateurs',
            onTap:
                () => Navigator.pushNamed(context, RouteNames.userManagement),
          ),
        if (authProvider.isAdmin || authProvider.isLivreur)
          _DashboardAction(
            icon: Icons.delivery_dining,
            label: 'Livraisons',
            onTap: () => Navigator.pushNamed(context, RouteNames.colisList),
          ),
        if (authProvider.isAdmin || authProvider.isClient)
          _DashboardAction(
            icon: Icons.mail,
            label: 'Mes Colis',
            onTap: () => Navigator.pushNamed(context, RouteNames.colisList),
          ),
      ],
    );
  }
}

class _DashboardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
