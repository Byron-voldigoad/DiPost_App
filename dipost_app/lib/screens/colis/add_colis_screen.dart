import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/colis_provider.dart';
import '../../providers/ibox_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/colis.dart';
import '../theme/app_theme.dart';

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
  int? _selectedExpediteurId;
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
          SnackBar(
            content: Text('Erreur de chargement: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
          SnackBar(
            content: Text('Erreur chargement iBoxes: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
          SnackBar(
            content: Text('Erreur chargement utilisateurs: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 100 : 16.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créer un nouveau colis',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.9,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _contenuController,
                                    decoration: InputDecoration(
                                      labelText: 'Contenu du colis*',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: Icon(Icons.inventory,
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ce champ est obligatoire';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildExpediteurDropdown(userProvider),
                                  const SizedBox(height: 16),
                                  _buildIBoxDropdown(iboxProvider),
                                  if (authProvider.isAdmin || authProvider.isOperateur) ...[
                                    const SizedBox(height: 16),
                                    _buildDestinataireDropdown(userProvider),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _submitForm,
                              child: const Text(
                                'Créer le colis',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildExpediteurDropdown(UserProvider userProvider) {
    if (!_usersLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Chargement des expéditeurs...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Même liste que pour les destinataires (clients)
    final clients = userProvider.users.where((u) => u.role == 'client').toList();

    if (clients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(Icons.warning, color: Theme.of(context).primaryColor, size: 40),
            const SizedBox(height: 8),
            Text(
              'Aucun expéditeur disponible',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int?>(
      isExpanded: true,
      value: _selectedExpediteurId,
      decoration: InputDecoration(
        labelText: 'Expéditeur*',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.person_outline,
            color: Theme.of(context).primaryColor),
      ),
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner un expéditeur';
        }
        return null;
      },
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Sélectionnez un expéditeur'),
        ),
        ...clients.map((user) {
          return DropdownMenuItem(
            value: user.id,
            child: Text(
              '${user.prenom} ${user.nom} (${user.email})',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
      ],
      onChanged: (value) {
        setState(() => _selectedExpediteurId = value);
      },
    );
  }

  Widget _buildIBoxDropdown(IBoxProvider iboxProvider) {
    if (!_iboxesLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Chargement des iBox...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (iboxProvider.iboxes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(Icons.warning, color: Theme.of(context).primaryColor, size: 40),
            const SizedBox(height: 8),
            Text(
              'Aucune iBox disponible',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int?>(
      isExpanded: true,
      value: _selectedIBoxId,
      decoration: InputDecoration(
        labelText: 'iBox de destination',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.location_on,
            color: Theme.of(context).primaryColor),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Aucune iBox sélectionnée'),
        ),
        ...iboxProvider.iboxes.map((ibox) {
          return DropdownMenuItem(
            value: ibox.id,
            child: Text(
              '${ibox.adresse} (Capacité: ${ibox.capacite})',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Chargement des destinataires...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final clients = userProvider.users.where((u) => u.role == 'client').toList();

    if (clients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(Icons.warning, color: Theme.of(context).primaryColor, size: 40),
            const SizedBox(height: 8),
            Text(
              'Aucun client disponible',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int?>(
      isExpanded: true,
      value: _selectedDestinataireId,
      decoration: InputDecoration(
        labelText: 'Destinataire*',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
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
            child: Text(
              '${user.prenom} ${user.nom} (${user.email})',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
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
    if (!_iboxesLoaded || !_usersLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez attendre le chargement des données'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final colisProvider = Provider.of<ColisProvider>(context, listen: false);
      final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('Utilisateur non authentifié');
      }

      if (_selectedExpediteurId == null) {
        throw Exception('Veuillez sélectionner un expéditeur');
      }

      if ((authProvider.isAdmin || authProvider.isOperateur) &&
          _selectedDestinataireId == null) {
        throw Exception('Veuillez sélectionner un destinataire');
      }

      final expediteur = userProvider.users
          .firstWhere((user) => user.id == _selectedExpediteurId);
      final destinataire = _selectedDestinataireId != null
          ? userProvider.users.firstWhere(
              (user) => user.id == _selectedDestinataireId)
          : authProvider.user;

      final newColis = Colis(
        id: 0,
        iboxId: _selectedIBoxId,
        destinataireId: _selectedDestinataireId ?? authProvider.user!.id,
        expediteurId: _selectedExpediteurId!,
        iboxAdresse: _selectedIBoxId != null
            ? iboxProvider.iboxes
                .firstWhere((ibox) => ibox.id == _selectedIBoxId)
                .adresse
            : 'Non spécifiée',
        destinataireNom: destinataire?.nom ?? '',
        destinatairePrenom: destinataire?.prenom ?? '',
        expediteurNom: expediteur.nom,
        expediteurPrenom: expediteur.prenom,
        contenu: _contenuController.text,
        statut: 'En attente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await colisProvider.createColis(newColis);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Colis créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur création colis: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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