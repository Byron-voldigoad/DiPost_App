import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_helper.dart';
import '../../constants/route_names.dart';
import '../theme/app_theme.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Container(
      decoration: AppTheme.getBackgroundDecoration(authProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mes Livraisons'),
          backgroundColor: primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
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
                        Icon(Icons.local_shipping_outlined, size: 64, color: primaryColor),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune livraison assignée',
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
                  'Destinataire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person, 'Nom', '${livraison['destinataire_nom']} ${livraison['destinataire_prenom']}', primaryColor),
                _buildDetailRow(Icons.phone, 'Téléphone', livraison['destinataire_telephone'] ?? 'Non spécifié', primaryColor),
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
                Center(
                  child: Column(
                    children: [
                      
                     
                      Text(
                        'Scannez le code QR du client pour valider la livraison',
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