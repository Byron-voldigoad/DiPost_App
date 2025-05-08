import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/colis_provider.dart';
import '../../providers/ibox_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/colis.dart';

class AddColisScreen extends StatefulWidget {
  const AddColisScreen({super.key});

  @override
  State<AddColisScreen> createState() => _AddColisScreenState();
}

class _AddColisScreenState extends State<AddColisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contenuController = TextEditingController();
  int? _selectedIBoxId;
  int? _selectedDestinataireId;
  bool _isLoading = false;
  bool _iboxesLoaded = false;
  bool _usersLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadIBoxes(),
        _loadUsers(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadIBoxes() async {
    try {
      await Provider.of<IBoxProvider>(context, listen: false).loadIBoxes();
      if (mounted) setState(() => _iboxesLoaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement iBoxes: ${e.toString()}')),
        );
        setState(() => _iboxesLoaded = false);
      }
    }
  }

  Future<void> _loadUsers() async {
    try {
      await Provider.of<UserProvider>(context, listen: false).loadUsers();
      if (mounted) setState(() => _usersLoaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement utilisateurs: ${e.toString()}')),
        );
        setState(() => _usersLoaded = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final iboxProvider = Provider.of<IBoxProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Colis'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contenuController,
                        decoration: const InputDecoration(
                          labelText: 'Contenu du colis*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                     
                      const SizedBox(height: 16),
                      _buildIBoxDropdown(iboxProvider),
                      const SizedBox(height: 16),
                      if (authProvider.isAdmin || authProvider.isOperateur)
                        _buildDestinataireDropdown(userProvider),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 119, 5, 154),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _submitForm,
                        child: const Text(
                          'Créer le colis',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildIBoxDropdown(IBoxProvider iboxProvider) {
    if (!_iboxesLoaded) {
      return const Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Chargement des iBox...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (iboxProvider.iboxes.isEmpty) {
      return const Column(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          Text('Aucune iBox disponible', style: TextStyle(color: Colors.orange)),
        ],
      );
    }

    return DropdownButtonFormField<int?>(
      value: _selectedIBoxId,
      decoration: const InputDecoration(
        labelText: 'iBox de destination',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Aucune iBox sélectionnée'),
        ),
        ...iboxProvider.iboxes.map((ibox) {
          return DropdownMenuItem(
            value: ibox.id,
            child: Text('${ibox.adresse} (Capacité: ${ibox.capacite})'),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedIBoxId = value);
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une iBox';
        }
        return null;
      },
    );
  }

  Widget _buildDestinataireDropdown(UserProvider userProvider) {
    if (!_usersLoaded) {
      return const Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Chargement des destinataires...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    final clients = userProvider.users.where((u) => u.role == 'client').toList();

    if (clients.isEmpty) {
      return const Column(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          Text('Aucun client disponible', style: TextStyle(color: Colors.orange)),
        ],
      );
    }

    return DropdownButtonFormField<int?>(
      value: _selectedDestinataireId,
      decoration: const InputDecoration(
        labelText: 'Destinataire*',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un destinataire';
        }
        return null;
      },
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Sélectionnez un destinataire'),
        ),
        ...clients.map((user) {
          return DropdownMenuItem(
            value: user.id,
            child: Text('${user.prenom} ${user.nom} (${user.email})'),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedDestinataireId = value);
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final colisProvider = Provider.of<ColisProvider>(context, listen: false);
      final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Validation supplémentaire
      if (authProvider.user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Pour les admins/opérateurs, vérifier que le destinataire est sélectionné
      if ((authProvider.isAdmin || authProvider.isOperateur) && _selectedDestinataireId == null) {
        throw Exception('Veuillez sélectionner un destinataire');
      }

      final selectedIBox = _selectedIBoxId != null 
          ? iboxProvider.iboxes.firstWhere((ibox) => ibox.id == _selectedIBoxId)
          : null;

      final newColis = Colis(
        id: 0,
        iboxId: _selectedIBoxId,
        destinataireId: _selectedDestinataireId ?? authProvider.user!.id,
        expediteurId: authProvider.user!.id,
        iboxAdresse: selectedIBox?.adresse ?? 'Non spécifiée',
        destinataireNom: '', // Rempli par le provider
        destinatairePrenom: '', // Rempli par le provider
        expediteurNom: authProvider.user!.nom,
        expediteurPrenom: authProvider.user!.prenom,
        contenu: _contenuController.text,
        statut: 'En attente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await colisProvider.createColis(newColis);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Colis créé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur création colis: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _contenuController.dispose();
    super.dispose();
  }
}