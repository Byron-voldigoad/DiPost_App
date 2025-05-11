import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../models/ibox.dart';
import '../../models/user.dart';
import '../../providers/colis_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibox_provider.dart';
import '../../providers/user_provider.dart';

class ModifierColisScreen extends StatefulWidget {
  final Colis colis;

  const ModifierColisScreen({super.key, required this.colis});

  @override
  State<ModifierColisScreen> createState() => _ModifierColisScreenState();
}

class _ModifierColisScreenState extends State<ModifierColisScreen> {
  late TextEditingController _contenuController;
  late String _selectedStatut;
  int? _selectedIBoxId;
  int? _selectedDestinataireId;
  int? _selectedExpediteurId;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _statuts = ['En attente', 'En cours', 'Livré'];
  List<User> _clients = [];
  List<IBox> _iboxes = [];

  @override
  void initState() {
    super.initState();
    _contenuController = TextEditingController(text: widget.colis.contenu);
    _selectedStatut = _statuts.contains(widget.colis.statut) 
        ? widget.colis.statut 
        : 'En attente';
    _selectedIBoxId = widget.colis.iboxId;
    _selectedDestinataireId = widget.colis.destinataireId;
    _selectedExpediteurId = widget.colis.expediteurId;
    
    // Utilisation de WidgetsBinding.instance pour différer le chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);

      await Future.wait([
        userProvider.loadUsers(),
        iboxProvider.loadIBoxes(),
      ]);

      if (mounted) {
        setState(() {
          _clients = userProvider.users.where((u) => u.role == 'client').toList();
          _iboxes = iboxProvider.iboxes;
          _verifySelectedIds();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
        );
      }
    }
  }

  void _verifySelectedIds() {
    if (_selectedExpediteurId != null && !_clients.any((u) => u.id == _selectedExpediteurId)) {
      _selectedExpediteurId = null;
    }
    if (_selectedDestinataireId != null && !_clients.any((u) => u.id == _selectedDestinataireId)) {
      _selectedDestinataireId = null;
    }
    if (_selectedIBoxId != null && !_iboxes.any((i) => i.id == _selectedIBoxId)) {
      _selectedIBoxId = null;
    }
  }

  @override
  void dispose() {
    _contenuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le colis'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modifier le colis #${widget.colis.id}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _contenuController,
                            decoration: const InputDecoration(
                              labelText: 'Contenu du colis*',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          if (authProvider.isAdmin || authProvider.isOperateur)
                            _buildUserDropdown(
                              title: 'Expéditeur*',
                              value: _selectedExpediteurId,
                              onChanged: (value) => setState(() => _selectedExpediteurId = value),
                            ),

                          if (authProvider.isAdmin || authProvider.isOperateur)
                            _buildUserDropdown(
                              title: 'Destinataire*',
                              value: _selectedDestinataireId,
                              onChanged: (value) => setState(() => _selectedDestinataireId = value),
                            ),

                          _buildIBoxDropdown(),
                          _buildStatutDropdown(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserDropdown({
    required String title,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          value: value,
          isExpanded: true,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sélectionnez un utilisateur'),
            ),
            ..._clients.map((user) => DropdownMenuItem<int?>(
                  value: user.id,
                  child: Text('${user.prenom} ${user.nom} (${user.email})'),
                )),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIBoxDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('iBox de destination'),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          value: _selectedIBoxId,
          isExpanded: true,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sélectionnez une iBox'),
            ),
            ..._iboxes.map((ibox) => DropdownMenuItem<int?>(
                  value: ibox.id,
                  child: Text('${ibox.adresse} (Statut: ${ibox.statut})'),
                )),
          ],
          onChanged: (value) => setState(() => _selectedIBoxId = value),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatutDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statut*'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatut,
          isExpanded: true,
          items: _statuts
              .map((statut) => DropdownMenuItem<String>(
                    value: statut,
                    child: Text(statut),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedStatut = value);
            }
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        child: _isSaving
            ? const CircularProgressIndicator()
            : const Text('Enregistrer les modifications'),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final colisProvider = Provider.of<ColisProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if ((authProvider.isAdmin || authProvider.isOperateur) &&
          (_selectedExpediteurId == null || _selectedDestinataireId == null)) {
        throw Exception('Expéditeur et destinataire sont obligatoires');
      }

      final updatedColis = widget.colis.copyWith(
        contenu: _contenuController.text,
        statut: _selectedStatut,
        iboxId: _selectedIBoxId,
        destinataireId: _selectedDestinataireId,
        expediteurId: _selectedExpediteurId,
        updatedAt: DateTime.now(),
      );

      await colisProvider.updateColis(updatedColis);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Colis modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}