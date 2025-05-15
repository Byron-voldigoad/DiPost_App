import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/livraison_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/livraison.dart';
import '../../models/user.dart';
import '../theme/app_theme.dart';

class LivraisonManagementScreen extends StatefulWidget {
  const LivraisonManagementScreen({super.key});

  @override
  State<LivraisonManagementScreen> createState() => _LivraisonManagementScreenState();
}

class _LivraisonManagementScreenState extends State<LivraisonManagementScreen> {
  final Map<int, int?> _selectedLivreurs = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Container(
      decoration: AppTheme.getBackgroundDecoration(authProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
  title: const Text('Gestion des Livraisons'),
  backgroundColor: primaryColor,
  elevation: 0,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
  ),  // <-- Closing parenthesis for shape
  actions: [  // <-- Now properly placed as a direct parameter of AppBar
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: _refreshData,
      tooltip: 'Actualiser',
    ),
  ],
),
        body: _buildBody(primaryColor),
      ),
    );
  }

  // [Rest of the code remains exactly the same...]
  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer2<LivraisonProvider, UserProvider>(
      builder: (context, livraisonProvider, userProvider, _) {
        final livraisons = livraisonProvider.livraisons;
        final livreurs = userProvider.livreurs;

        if (livraisons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining, size: 50, color: primaryColor),
                const SizedBox(height: 16),
                Text('Aucune livraison disponible', 
                    style: TextStyle(fontSize: 18, color: primaryColor)),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed: _refreshData,
                  child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            )],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          color: primaryColor,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildLivraisonSection(
                'En attente', 
                livraisons.where((l) => l.statut == 'En attente').toList(), 
                livreurs,
                Colors.orange,
                primaryColor
              ),
              _buildLivraisonSection(
                'En cours', 
                livraisons.where((l) => l.statut == 'En cours').toList(), 
                livreurs,
                Colors.blue,
                primaryColor
              ),
              _buildLivraisonSection(
                'Livrées', 
                livraisons.where((l) => l.statut == 'Livrée').toList(), 
                livreurs,
                Colors.green,
                primaryColor
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLivraisonSection(
    String title, 
    List<Livraison> livraisons, 
    List<User> livreurs,
    Color statusColor,
    Color primaryColor
  ) {
    if (livraisons.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.9),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                Text(
                  '$title (${livraisons.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
          ...livraisons.map((livraison) => _buildLivraisonItem(livraison, livreurs, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildLivraisonItem(Livraison livraison, List<User> livreurs, Color primaryColor) {
    final canAssign = livraison.statut == 'En attente';
    final hasLivreur = livraison.livreurId > 0;

    return ExpansionTile(
      title: Text(
        'Livraison #${livraison.id}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy - HH:mm').format(livraison.dateDemande),
      ),
      trailing: Chip(
        label: Text(
          livraison.statut,
          style: TextStyle(color: _getStatusColor(livraison.statut)),
        ),
        backgroundColor: _getStatusColor(livraison.statut).withOpacity(0.1),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Colis ID:', livraison.colisId.toString(), primaryColor),
              if (hasLivreur) 
                _buildInfoRow('Livreur:', _getLivreurName(livraison.livreurId, livreurs), primaryColor),
              
              if (canAssign) ...[
                const SizedBox(height: 16),
                _buildAssignForm(livraison, livreurs, primaryColor),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAssignForm(Livraison livraison, List<User> livreurs, Color primaryColor) {
    _selectedLivreurs.putIfAbsent(livraison.id, () => null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          value: _selectedLivreurs[livraison.id],
          decoration: InputDecoration(
            labelText: 'Assigner un livreur',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: Icon(Icons.person_search, color: primaryColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
          ),
          items: livreurs.map((livreur) => DropdownMenuItem(
            value: livreur.id,
            child: Text('${livreur.prenom} ${livreur.nom} (${livreur.id})'),
          )).toList(),
          onChanged: (value) => setState(() => _selectedLivreurs[livraison.id] = value),
          dropdownColor: Colors.white.withOpacity(0.95),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _selectedLivreurs[livraison.id] == null 
              ? null
              : () => _assignLivreur(livraison.id, _selectedLivreurs[livraison.id]!),
          child: const Text('Confirmer l\'assignation', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final livraisonProvider = Provider.of<LivraisonProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      await Future.wait([
        livraisonProvider.loadLivraisons(),
        userProvider.loadLivreurs(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de rafraîchissement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _assignLivreur(int livraisonId, int livreurId) async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      await Provider.of<LivraisonProvider>(context, listen: false)
          .assignerLivreur(livraisonId, livreurId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livreur assigné avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'En attente': return Colors.orange;
      case 'En cours': return Colors.blue;
      case 'Livrée': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getLivreurName(int livreurId, List<User> livreurs) {
    try {
      final livreur = livreurs.firstWhere((l) => l.id == livreurId);
      return '${livreur.prenom} ${livreur.nom}';
    } catch (e) {
      return 'Non assigné';
    }
  }
}