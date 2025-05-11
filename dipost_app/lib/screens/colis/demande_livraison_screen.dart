import 'package:dipost_app/models/livraison.dart';
import 'package:dipost_app/providers/livraison_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../providers/auth_provider.dart';
import '../../providers/colis_provider.dart';
import '../../providers/ibox_provider.dart';
import '../theme/app_theme.dart';

class DemandeLivraisonScreen extends StatefulWidget {
  final Colis colis;

  const DemandeLivraisonScreen({super.key, required this.colis});

  @override
  State<DemandeLivraisonScreen> createState() => _DemandeLivraisonScreenState();
}

class _DemandeLivraisonScreenState extends State<DemandeLivraisonScreen> {
  int? _selectedIBoxId;
  String? _selectedAdresse;
  bool _useCustomAddress = false;
  final TextEditingController _adresseController = TextEditingController();
  bool _isLoading = false;
  bool _iboxesLoaded = false;
  Livraison? _existingLivraison;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingLivraison();
      _loadIBoxes();
    });
  }

  Future<void> _checkExistingLivraison() async {
    final livraisonProvider = Provider.of<LivraisonProvider>(context, listen: false);
    try {
      final livraison = await livraisonProvider.getLivraisonByColisId(widget.colis.id);
      if (mounted) {
        setState(() {
          _existingLivraison = livraison;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la livraison: $e');
    }
  }

  Future<void> _loadIBoxes() async {
    final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
    await iboxProvider.loadIBoxes();
    if (mounted) {
      setState(() {
        _iboxesLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iboxProvider = Provider.of<IBoxProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (_existingLivraison != null) {
      return _buildAlreadyRequestedView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de livraison'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choisissez le point de livraison',
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
                          SwitchListTile(
                            title: const Text(
                              'Utiliser une adresse personnalisée',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            value: _useCustomAddress,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _useCustomAddress = value;
                                if (!value) {
                                  _adresseController.clear();
                                  _selectedAdresse = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          AnimatedCrossFade(
                            firstChild: Column(
                              children: [
                                Text(
                                  'Sélectionnez une iBox',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                _iboxesLoaded
                                    ? DropdownButtonFormField<int?>(
                                        value: _selectedIBoxId,
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Sélectionnez une iBox'),
                                          ),
                                          ...iboxProvider.iboxes.map((ibox) {
                                            return DropdownMenuItem(
                                              value: ibox.id,
                                              child: Text(ibox.adresse),
                                            );
                                          }).toList(),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedIBoxId = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                                        ),
                                      )
                                    : const Center(child: CircularProgressIndicator()),
                              ],
                            ),
                            secondChild: TextField(
                              controller: _adresseController,
                              decoration: InputDecoration(
                                labelText: 'Adresse de livraison',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.map, color: Theme.of(context).primaryColor),
                              ),
                              onChanged: (value) {
                                _selectedAdresse = value;
                              },
                            ),
                            crossFadeState: _useCustomAddress ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
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
                      onPressed: _submitDemande,
                      child: const Text(
                        'Confirmer la demande',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAlreadyRequestedView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de livraison'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Demande de livraison déjà effectuée',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Statut: ${_existingLivraison?.statut ?? 'En cours'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Retour',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDemande() async {
    if ((!_useCustomAddress && _selectedIBoxId == null) ||
        (_useCustomAddress && (_selectedAdresse == null || _selectedAdresse!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un point de livraison'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedColis = widget.colis.copyWith(
        statut: 'En attente de livraison',
        iboxId: _useCustomAddress ? null : _selectedIBoxId,
        iboxAdresse: _useCustomAddress ? _selectedAdresse : null,
      );

      await Provider.of<ColisProvider>(context, listen: false).updateColis(updatedColis);

      final livraisonId = await Provider.of<LivraisonProvider>(context, listen: false)
          .createLivraison(Livraison(
        colisId: widget.colis.id,
      ));

      debugPrint('Livraison créée avec ID: $livraisonId');

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}