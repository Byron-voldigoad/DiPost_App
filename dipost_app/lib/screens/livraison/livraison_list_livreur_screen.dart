import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_helper.dart';
import '../../constants/route_names.dart';
import 'package:intl/intl.dart';

class LivraisonListLivreurScreen extends StatefulWidget {
  const LivraisonListLivreurScreen({super.key});

  @override
  State<LivraisonListLivreurScreen> createState() => _LivraisonListLivreurScreenState();
}

String formatDate(String? dateString) {
  if (dateString == null) return 'Non spécifié';
  
  try {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(dateTime);
  } catch (e) {
    return dateString;
  }
}

class _LivraisonListLivreurScreenState extends State<LivraisonListLivreurScreen> {
  List<Map<String, dynamic>> _livraisonsDetails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLivraisonsWithDetails();
  }

  Future<void> _loadLivraisonsWithDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final livreurId = authProvider.user?.id;

    if (livreurId != null) {
      final db = await DatabaseHelper.instance.database;
      
      final results = await db.rawQuery('''
        SELECT 
          l.id as livraison_id, 
          l.statut, 
          l.date_demande, 
          l.date_livraison,
          c.id_colis, 
          c.contenu as colis_contenu, 
          c.statut as colis_statut,
          u.id_utilisateur as destinataire_id,
          u.nom as destinataire_nom,
          u.prenom as destinataire_prenom,
          u.telephone as destinataire_telephone
        FROM livraisons l
        JOIN colis c ON l.colis_id = c.id_colis
        JOIN utilisateurs u ON c.id_destinataire = u.id_utilisateur
        WHERE l.livreur_id = ?
        ORDER BY l.date_demande DESC
      ''', [livreurId]);

      setState(() {
        _livraisonsDetails = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Livraisons'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).appBarTheme.iconTheme?.color),
            onPressed: () => Navigator.pushNamed(context, RouteNames.livraisonList),
            tooltip: 'Scanner un QR code',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _livraisonsDetails.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 64, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune livraison assignée',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _livraisonsDetails.length,
                  itemBuilder: (context, index) {
                    final livraison = _livraisonsDetails[index];
                    return _buildLivraisonCard(livraison);
                  },
                ),
    );
  }

  Widget _buildLivraisonCard(Map<String, dynamic> livraison) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
        title: Text(
          'Livraison #${livraison['livraison_id']}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Statut: ${livraison['statut']}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails du colis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.description, 'Contenu', livraison['colis_contenu']),
                _buildDetailRow(Icons.info, 'Statut', livraison['colis_statut']),
                const SizedBox(height: 16),
                Text(
                  'Destinataire',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person, 'Nom', '${livraison['destinataire_nom']} ${livraison['destinataire_prenom']}'),
                _buildDetailRow(Icons.phone, 'Téléphone', livraison['destinataire_telephone'] ?? 'Non spécifié'),
                const SizedBox(height: 16),
                Text(
                  'Dates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, 'Demande', formatDate(livraison['date_demande'])),
                if (livraison['date_livraison'] != null)
                  _buildDetailRow(Icons.event_available, 'Livraison', formatDate(livraison['date_livraison'])),
                const SizedBox(height: 16),
                
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Scannez Le code QR du client pour valider la livraison',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}