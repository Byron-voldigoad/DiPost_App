import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/livraison.dart';
import '../../providers/livraison_provider.dart';
import '../../providers/auth_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Container(
      decoration: AppTheme.getBackgroundDecoration(authProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Détails de la livraison'),
          backgroundColor: primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
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
                    Icon(Icons.error_outline, size: 64, color: primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger les détails',
                      style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem(Icons.info, 'Statut', livraison.statut, primaryColor),
                          _buildDetailItem(Icons.calendar_today, 'Date de demande', _formatDate(livraison.dateDemande), primaryColor),
                          if (livraison.dateLivraison != null)
                            _buildDetailItem(Icons.event_available, 'Date de livraison', _formatDate(livraison.dateLivraison), primaryColor),
                          _buildDetailItem(Icons.inventory, 'ID Colis', livraison.colisId.toString(), primaryColor),
                          _buildDetailItem(Icons.person, 'Livreur', livraison.livreurId == 0 ? 'Non assigné' : 'Livreur #${livraison.livreurId}', primaryColor),
                        ],
                      ),
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

  Widget _buildDetailItem(IconData icon, String label, String value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
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