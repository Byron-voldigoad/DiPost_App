import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_helper.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class LivraisonListUserScreen extends StatefulWidget {
  const LivraisonListUserScreen({super.key});

  @override
  State<LivraisonListUserScreen> createState() => _LivraisonListUserScreenState();
}

String formatDate(String? dateString) {
  if (dateString == null) return 'Non spécifié';
  
  try {
    final dateTime = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy à HH:mm:ss').format(dateTime);
  } catch (e) {
    return dateString;
  }
}

class _LivraisonListUserScreenState extends State<LivraisonListUserScreen> {
  List<Map<String, dynamic>> _livraisonsDetails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLivraisonsWithDetails();
  }

  Future<void> _loadLivraisonsWithDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
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
          u.id_utilisateur as livreur_id,
          u.nom as livreur_nom,
          u.prenom as livreur_prenom,
          u.telephone as livreur_telephone
        FROM livraisons l
        JOIN colis c ON l.colis_id = c.id_colis
        LEFT JOIN utilisateurs u ON l.livreur_id = u.id_utilisateur
        WHERE c.id_destinataire = ?
        ORDER BY l.date_demande DESC
      ''', [userId]);

      setState(() {
        _livraisonsDetails = results;
        _isLoading = false;
      });
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
          title: const Text('Vos Livraisons'),
          backgroundColor: primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        )),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _livraisonsDetails.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 64, color: primaryColor),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune livraison trouvée',
                          style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLivraisonsWithDetails,
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: _livraisonsDetails.length,
                      itemBuilder: (context, index) {
                        final livraison = _livraisonsDetails[index];
                        return _buildLivraisonCard(livraison, primaryColor);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildLivraisonCard(Map<String, dynamic> livraison, Color primaryColor) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9),
      child: ExpansionTile(
        leading: Icon(Icons.local_shipping, color: primaryColor),
        title: Text(
          'Livraison #${livraison['livraison_id']}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        subtitle: Text(
          'Statut: ${livraison['statut']}',
          style: const TextStyle(fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détails du colis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.description, 'Contenu', livraison['colis_contenu'], primaryColor),
                _buildDetailRow(Icons.info, 'Statut', livraison['colis_statut'], primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Livreur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                livraison['livreur_id'] != null && livraison['livreur_id'] != 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.person, 'Nom', '${livraison['livreur_nom']} ${livraison['livreur_prenom']}', primaryColor),
                          _buildDetailRow(Icons.phone, 'Téléphone', livraison['livreur_telephone'], primaryColor),
                        ],
                      )
                    : _buildDetailRow(Icons.person_off, 'Livreur', 'Non assigné', primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Dates',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, 'Demande', formatDate(livraison['date_demande']), primaryColor),
                if (livraison['date_livraison'] != null)
                  _buildDetailRow(Icons.event_available, 'Livraison', formatDate(livraison['date_livraison']), primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Code QR pour livraison',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'LIV-${livraison['livraison_id']}-COL-${livraison['id_colis']}',
                        version: QrVersions.auto,
                        size: 150,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'À présenter au livreur pour confirmation',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}