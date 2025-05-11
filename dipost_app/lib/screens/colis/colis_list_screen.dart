import 'package:dipost_app/models/colis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/colis_provider.dart';
import '../theme/app_theme.dart';
import 'colis_detail_screen.dart';
import 'add_colis_screen.dart';
import 'demande_livraison_screen.dart';

class ColisListScreen extends StatefulWidget {
  const ColisListScreen({super.key});

  @override
  State<ColisListScreen> createState() => _ColisListScreenState();
}

class _ColisListScreenState extends State<ColisListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadColis());
  }

  Future<void> _loadColis() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<ColisProvider>(context, listen: false).loadColis(
      userId: authProvider.user?.id,
      userRole: authProvider.user?.role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colisProvider = Provider.of<ColisProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.isLivreur ? 'Colis à livrer' : 'Mes Colis',
        ),
        backgroundColor: primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: _buildBody(colisProvider, primaryColor),
      ),
      floatingActionButton: _shouldShowFloatingActionButton(authProvider)
          ? FloatingActionButton(
              onPressed: () => _navigateToAddColis(context),
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(ColisProvider colisProvider, Color primaryColor) {
    if (colisProvider.isLoading && colisProvider.colisList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadColis,
      color: primaryColor,
      child: colisProvider.colisList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun colis disponible',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: colisProvider.colisList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final colis = colisProvider.colisList[index];
                return _buildColisCard(colis, primaryColor, context);
              },
            ),
    );
  }

  Widget _buildColisCard(Colis colis, Color primaryColor, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColisDetailScreen(colisId: colis.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Colis #${colis.id}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      colis.statut,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.inventory, colis.contenu),
              if (colis.iboxId != null) 
                _buildInfoRow(Icons.location_on, colis.iboxAdresse ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowFloatingActionButton(AuthProvider authProvider) {
    return authProvider.isAdmin || authProvider.isOperateur;
  }

  Future<void> _navigateToAddColis(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddColisScreen()),
    );

    if (result == true) {
      await _loadColis();
    }
  }
}