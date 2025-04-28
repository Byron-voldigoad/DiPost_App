import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../providers/colis_provider.dart';
import '../../providers/auth_provider.dart';

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
    _colisFuture = Provider.of<ColisProvider>(context, listen: false)
        .getColisWithDetails(widget.colisId);
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
                  colis.iboxAdresse, // Afficher l'adresse au lieu de l'ID
                  context,
                ),
                if (colis.createdAt != null)
                  _buildDetailItem(
                    'Date de création', 
                    _formatDate(colis.createdAt!),
                    context,
                  ),
                if (authProvider.isOperateur || authProvider.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 119, 5, 154),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          // Logique pour modifier le colis
                        },
                        child: const Text(
                          'Modifier le colis',
                          style: TextStyle(color: Colors.white),
                        ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute}';
  }
}