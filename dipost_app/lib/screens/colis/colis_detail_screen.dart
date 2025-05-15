import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../providers/colis_provider.dart';
import '../../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import './modifier_colis_screen.dart';
import './demande_livraison_screen.dart';

class ColisDetailScreen extends StatefulWidget {
  final int colisId;

  const ColisDetailScreen({super.key, required this.colisId});

  @override
  State<ColisDetailScreen> createState() => _ColisDetailScreenState();
}

class _ColisDetailScreenState extends State<ColisDetailScreen> {
  late Future<Colis?> _colisFuture;

  @override
  void initState() {
    super.initState();
    _loadColis();
  }

  void _loadColis() {
    _colisFuture = Provider.of<ColisProvider>(context, listen: false)
        .getColisWithDetails(widget.colisId);
  }

  Future<void> _navigateToModifierColis(BuildContext context, Colis colis) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierColisScreen(colis: colis),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _loadColis();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Colis modifié avec succès'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _navigateToDemandeLivraison(BuildContext context, Colis colis) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DemandeLivraisonScreen(colis: colis),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _loadColis();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Demande de livraison envoyée'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  final primaryColor = AppTheme.getPrimaryColor(authProvider);

  return Container(
    decoration: AppTheme.getBackgroundDecoration(authProvider),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Détails du Colis'),
        backgroundColor: primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FutureBuilder<Colis?>(
        future: _colisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Colis non trouvé',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final colis = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildInfoCard(colis, primaryColor, context),
                ),
                const SizedBox(height: 20),
                if (authProvider.isOperateur || authProvider.isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildActionButton(
                      context,
                      'Modifier le colis',
                      () => _navigateToModifierColis(context, colis),
                      primaryColor,
                    ),
                  )
                else if (authProvider.isClient)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildActionButton(
                      context,
                      'Demander livraison',
                      () => _navigateToDemandeLivraison(context, colis),
                      primaryColor,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildInfoCard(Colis colis, Color primaryColor, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Contenu', colis.contenu, Icons.inventory, primaryColor),
            _buildDetailRow('Statut', colis.statut, Icons.info, primaryColor),
            _buildDetailRow(
              'Destinataire', 
              '${colis.destinatairePrenom} ${colis.destinataireNom}',
              Icons.person,
              primaryColor,
            ),
            _buildDetailRow(
              'Expéditeur', 
              '${colis.expediteurPrenom} ${colis.expediteurNom}',
              Icons.person_outline,
              primaryColor,
            ),
            if (colis.iboxId != null)
              _buildDetailRow(
                'iBox', 
                colis.iboxAdresse ?? 'Non spécifiée',
                Icons.location_on,
                primaryColor,
              ),
            if (colis.createdAt != null)
              _buildDetailRow(
                'Date de création', 
                _formatDate(colis.createdAt!),
                Icons.calendar_today,
                primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}