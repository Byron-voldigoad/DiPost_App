import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibox_provider.dart';
import '../theme/app_theme.dart';

class IBoxCreateScreen extends StatefulWidget {
  const IBoxCreateScreen({super.key});

  @override
  State<IBoxCreateScreen> createState() => _IBoxCreateScreenState();
}

class _IBoxCreateScreenState extends State<IBoxCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adresseController = TextEditingController();
  final _capaciteController = TextEditingController();
  String _selectedStatut = IBox.statutsPossibles[0];
  bool _isLoading = false;

  @override
  void dispose() {
    _adresseController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  Future<void> _createIBox(IBoxProvider iboxProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newIBox = IBox(
          id: 0,
          adresse: _adresseController.text.trim(),
          capacite: int.parse(_capaciteController.text.trim()),
          statut: _selectedStatut,
          createdAt: DateTime.now(),
        );

        final result = await iboxProvider.addIBox(newIBox);

        if (!mounted) return;

        if (result > 0) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('iBox créée avec succès'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        } else {
          throw Exception('Failed to create iBox');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erreur lors de la création'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Container(
      decoration: AppTheme.getBackgroundDecoration(authProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Créer une iBox'),
          backgroundColor: primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nouvelle iBox',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _adresseController,
                                  decoration: InputDecoration(
                                    labelText: 'Adresse',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.location_on,
                                      color: primaryColor,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez entrer une adresse';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatut,
                                  items:
                                      IBox.statutsPossibles.map((statut) {
                                        return DropdownMenuItem(
                                          value: statut,
                                          child: Text(statut),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedStatut = value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Statut',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.track_changes,
                                      color: primaryColor,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                  ),
                                  dropdownColor: Colors.white.withOpacity(0.95),
                                  style: TextStyle(color: primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: primaryColor.withOpacity(0.9),
                            ),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => _createIBox(iboxProvider),
                            child: const Text(
                              'Créer iBox',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
