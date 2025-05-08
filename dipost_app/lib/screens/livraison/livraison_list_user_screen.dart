import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_helper.dart';
import '../../models/livraison.dart';
import '../../models/colis.dart';
import '../../models/user.dart';
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
    return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(dateTime);
  } catch (e) {
    return dateString; // Retourne la chaîne originale si le parsing échoue
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
      
      // Requête pour récupérer les livraisons avec les détails complets
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos Livraisons'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _livraisonsDetails.isEmpty
              ? const Center(child: Text('Aucune livraison trouvée'))
              : ListView.builder(
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
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text('Livraison #${livraison['livraison_id']}'),
        subtitle: Text('Statut: ${livraison['statut']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Détails du colis:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('ID: ${livraison['id_colis']}'),
                Text('Contenu: ${livraison['colis_contenu']}'),
                Text('Statut: ${livraison['colis_statut']}'),
                
                const SizedBox(height: 16),
                const Text('Livreur:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (livraison['livreur_id'] != null && livraison['livreur_id'] != 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nom: ${livraison['livreur_nom']} ${livraison['livreur_prenom']}'),
                      Text('Téléphone: ${livraison['livreur_telephone']}'),
                    ],
                  )
                else
                  const Text('Livreur non assigné'),
                
                const SizedBox(height: 16),
                const Text('Dates:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Demande: ${formatDate(livraison['date_demande'])}'),
                if (livraison['date_livraison'] != null)
                  Text('Livraison: ${formatDate(livraison['date_livraison'])}'),
                
                const SizedBox(height: 16),
                const Text('Code QR pour livraison:', style: TextStyle(fontWeight: FontWeight.bold)),
                Center(
                  child: QrImageView(
                    data: 'LIV-${livraison['livraison_id']}-COL-${livraison['id_colis']}',
                    version: QrVersions.auto,
                    size: 150,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('À présenter au livreur pour confirmation',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}