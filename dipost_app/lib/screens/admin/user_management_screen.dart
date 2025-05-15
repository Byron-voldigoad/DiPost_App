import 'package:dipost_app/screens/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipost_app/services/database_helper.dart';
import 'package:dipost_app/providers/user_provider.dart';
import 'package:dipost_app/widgets/common/custom_drawer.dart';
import 'package:dipost_app/models/user.dart';
import 'package:dipost_app/providers/auth_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'client';
  bool _isLoading = false;
  bool _usersLoading = false;
  User? _userToEdit;

  final List<String> _roles = ['client', 'livreur', 'operateur', 'admin'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _usersLoading = true);
    await Provider.of<UserProvider>(context, listen: false).loadUsers();
    if (!mounted) return;
    setState(() => _usersLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _selectedRole = 'client';
    _userToEdit = null;
  }

  Future<void> _createOrUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = {
        'nom': _lastNameController.text,
        'prenom': _firstNameController.text,
        'adresse_email': _emailController.text,
        'telephone': _phoneController.text,
        'role': _selectedRole,
      };

      // Si c'est une création, on ajoute le mot de passe
      if (_userToEdit == null) {
        user['mot_de_passe'] = _passwordController.text;
        user['created_at'] = DateTime.now().toIso8601String();
        await DatabaseHelper.instance.insert('utilisateurs', user);
      } else {
        // Mise à jour sans toucher au mot de passe
        await DatabaseHelper.instance.update(
          'utilisateurs',
          user,
          where: 'id_utilisateur = ?',
          whereArgs: [_userToEdit!.id],
        );
      }

      await _loadUsers();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _userToEdit == null
                ? 'Utilisateur créé avec succès'
                : 'Utilisateur mis à jour avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Fermer la popup
      Navigator.of(context).pop();
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUserFormPopup({User? user}) {
    _userToEdit = user;

    // Pré-remplir le formulaire si on modifie un utilisateur
    if (user != null) {
      _firstNameController.text = user.prenom;
      _lastNameController.text = user.nom;
      _emailController.text = user.email;
      _phoneController.text = user.telephone ?? '';
      _selectedRole = user.role;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              user == null ? 'Nouvel utilisateur' : 'Modifier utilisateur',
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prénom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un email';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    if (user == null) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit avoir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rôle',
                        prefixIcon: Icon(Icons.assignment_ind),
                      ),
                      items:
                          _roles.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(
                                role.toUpperCase(),
                                style: TextStyle(
                                  color: _getRoleColor(role),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          _resetForm();
                          Navigator.of(context).pop();
                        },
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: _isLoading ? null : _createOrUpdateUser,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(user == null ? 'Créer' : 'Mettre à jour'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColorDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showUserFormPopup(),
            tooltip: 'Nouvel utilisateur',
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(authProvider),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Liste des Utilisateurs',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // ElevatedButton.icon(
                      //   icon: const Icon(Icons.add),
                      //   label: const Text('Nouveau'),
                      //   onPressed: () => _showUserFormPopup(),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: theme.primaryColor,
                      //     foregroundColor: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildUserList(userProvider, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(UserProvider userProvider, ThemeData theme) {
    if (_usersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProvider.users.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur trouvé',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                child: Text(
                  '${user.prenom[0]}${user.nom[0]}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
              title: Text(
                '${user.prenom} ${user.nom}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showUserFormPopup(user: user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteUser(user.id),
                  ),
                ],
              ),
              onTap: () => _showUserDetails(user),
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'operateur':
        return Colors.blue;
      case 'livreur':
        return Colors.green;
      case 'client':
        return const Color.fromARGB(255, 183, 112, 4); // Orange
      default:
        return const Color.fromARGB(255, 183, 112, 4); // Orange par défaut
    }
  }

  Future<void> _confirmDeleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cet utilisateur ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.delete(
          'utilisateurs',
          where: 'id_utilisateur = ?',
          whereArgs: [userId],
        );

        await _loadUsers();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showUserDetails(User user) async {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails de ${user.prenom} ${user.nom}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.email, 'Email:', user.email),
                  _buildDetailRow(
                    Icons.phone,
                    'Téléphone:',
                    user.telephone ?? 'Non renseigné',
                  ),
                  _buildDetailRow(
                    Icons.assignment_ind,
                    'Rôle:',
                    user.role.toUpperCase(),
                    color: _getRoleColor(user.role),
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date de création:',
                    user.createdAt?.toLocal().toString() ?? 'Date inconnue',
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
