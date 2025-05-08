import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/livraison.dart';
import '../../providers/livraison_provider.dart';

class LivraisonDetailUserScreen extends StatefulWidget {
  const LivraisonDetailUserScreen({super.key});

  @override
  State<LivraisonDetailUserScreen> createState() => _LivraisonDetailUserScreenState();
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
      ),
      body: FutureBuilder<Livraison?>(
        future: _livraisonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Impossible de charger les détails'));
          }

          final livraison = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Statut', livraison.statut),
                _buildDetailItem('Date de demande', livraison.dateDemande.toString()),
                if (livraison.dateLivraison != null)
                  _buildDetailItem('Date de livraison', livraison.dateLivraison.toString()),
                _buildDetailItem('ID Colis', livraison.colisId.toString()),
                _buildDetailItem('Livreur', livraison.livreurId == 0 
                    ? 'Non assigné' 
                    : 'Livreur #${livraison.livreurId}'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }
}