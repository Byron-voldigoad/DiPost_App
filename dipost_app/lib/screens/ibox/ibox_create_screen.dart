import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
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

  void _createIBox(IBoxProvider iboxProvider) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newIBox = IBox(
        id: 0,
        adresse: _adresseController.text.trim(),
        capacite: int.parse(_capaciteController.text.trim()),
        statut: _selectedStatut,
        createdAt: DateTime.now(),
      );

      final result = await iboxProvider.addIBox(newIBox);

      if (!mounted) return;

      if (result > 0) { // Supposons que addIBox retourne l'ID de l'iBox (int)
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('iBox créée avec succès'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la création'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une iBox'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nouvelle iBox',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez entrer une adresse';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _capaciteController,
                              decoration: InputDecoration(
                                labelText: 'Capacité',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.storage, color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez entrer une capacité';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Veuillez entrer un nombre valide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedStatut,
                              items: IBox.statutsPossibles.map((statut) {
                                return DropdownMenuItem(
                                  value: statut,
                                  child: Text(statut),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedStatut = value;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Statut',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.track_changes, color: Theme.of(context).primaryColor),
                              ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : () => _createIBox(iboxProvider),
                        child: const Text(
                          'Créer iBox',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}