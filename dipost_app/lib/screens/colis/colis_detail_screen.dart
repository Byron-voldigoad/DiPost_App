import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../providers/colis_provider.dart';
import '../../providers/auth_provider.dart';
import './modifier_colis_screen.dart';
import './demande_livraison_screen.dart'; // À créer

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

  void _navigateToModifierColis(BuildContext context, Colis colis) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierColisScreen(colis: colis),
      ),
    );

    if (result == true) {
      setState(() {
        _loadColis();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colis modifié avec succès')),
      );
    }
  }

  void _navigateToDemandeLivraison(BuildContext context, Colis colis) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DemandeLivraisonScreen(colis: colis),
      ),
    );

    if (result == true) {
      setState(() {
        _loadColis();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de livraison envoyée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Colis'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      ),
      body: FutureBuilder<Colis?>(
        future: _colisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Colis non trouvé'));
          }

          final colis = snapshot.data!;
          final authProvider = Provider.of<AuthProvider>(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Contenu', colis.contenu, context),
                _buildDetailItem('Statut', colis.statut, context),
                _buildDetailItem(
                  'Destinataire', 
                  '${colis.destinatairePrenom} ${colis.destinataireNom}',
                  context,
                ),
                _buildDetailItem(
                  'Expéditeur', 
                  '${colis.expediteurPrenom} ${colis.expediteurNom}',
                  context,
                ),
                if (colis.iboxId != null)
                _buildDetailItem(
                  'iBox', 
                  colis.iboxAdresse ?? 'Non spécifiée',
                  context,
                ),
                if (colis.createdAt != null)
                  _buildDetailItem(
                    'Date de création', 
                    _formatDate(colis.createdAt!),
                    context,
                  ),
                const SizedBox(height: 20),
                if (authProvider.isOperateur || authProvider.isAdmin)
                  _buildActionButton(
                    context,
                    'Modifier le colis',
                    () => _navigateToModifierColis(context, colis),
                    const Color.fromARGB(255, 119, 5, 154),
                  )
                else if (authProvider.isClient)
                  _buildActionButton(
                    context,
                    'Demander livraison',
                    () => _navigateToDemandeLivraison(context, colis),
                    Colors.blue,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(),
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
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}