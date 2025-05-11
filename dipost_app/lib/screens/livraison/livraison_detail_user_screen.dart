import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/livraison.dart';
import '../../providers/livraison_provider.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class LivraisonDetailUserScreen extends StatefulWidget {
  const LivraisonDetailUserScreen({super.key});

  @override
  State<LivraisonDetailUserScreen> createState() => _LivraisonDetailUserScreenState();
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Non spécifié';
  return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
}

class _LivraisonDetailUserScreenState extends State<LivraisonDetailUserScreen> {
  late Future<Livraison?> _livraisonFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final livraisonId = ModalRoute.of(context)!.settings.arguments as int;
    _loadLivraison(livraisonId);
  }

  void _loadLivraison(int id) {
    final provider = Provider.of<LivraisonProvider>(context, listen: false);
    _livraisonFuture = provider.getLivraisonById(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la livraison'),
        elevation: 0,
      ),
      body: FutureBuilder<Livraison?>(
        future: _livraisonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger les détails',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }

          final livraison = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails de la livraison #${livraison.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem(Icons.info, 'Statut', livraison.statut),
                        _buildDetailItem(Icons.calendar_today, 'Date de demande', _formatDate(livraison.dateDemande)),
                        if (livraison.dateLivraison != null)
                          _buildDetailItem(Icons.event_available, 'Date de livraison', _formatDate(livraison.dateLivraison)),
                        _buildDetailItem(Icons.inventory, 'ID Colis', livraison.colisId.toString()),
                        _buildDetailItem(Icons.person, 'Livreur', livraison.livreurId == 0 ? 'Non assigné' : 'Livreur #${livraison.livreurId}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}