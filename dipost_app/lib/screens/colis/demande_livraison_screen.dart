import 'package:dipost_app/models/livraison.dart';
import 'package:dipost_app/providers/livraison_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../providers/colis_provider.dart';
import '../../providers/ibox_provider.dart';

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

    if (_existingLivraison != null) {
      return _buildAlreadyRequestedView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de livraison'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Choisissez le point de livraison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Utiliser une adresse personnalisée'),
                    value: _useCustomAddress,
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
                  if (!_useCustomAddress) ...[
                    const SizedBox(height: 10),
                    const Text('Sélectionnez une iBox:'),
                    const SizedBox(height: 10),
                    if (!_iboxesLoaded)
                      const CircularProgressIndicator()
                    else
                      DropdownButtonFormField<int?>(
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ] else ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse de livraison',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _selectedAdresse = value;
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _submitDemande,
                    child: const Text(
                      'Confirmer la demande',
                      style: TextStyle(color: Colors.white),
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
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Vous avez déjà fait une demande de livraison pour ce colis',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Statut: ${_existingLivraison?.statut ?? 'En cours'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> _submitDemande() async {
  if ((!_useCustomAddress && _selectedIBoxId == null) ||
      (_useCustomAddress && (_selectedAdresse == null || _selectedAdresse!.isEmpty))) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner un point de livraison')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 1. Mettre à jour le colis
    final updatedColis = widget.colis.copyWith(
      statut: 'En attente de livraison',
      iboxId: _useCustomAddress ? null : _selectedIBoxId,
      iboxAdresse: _useCustomAddress ? _selectedAdresse : null,
    );

    await Provider.of<ColisProvider>(context, listen: false)
        .updateColis(updatedColis);

    // 2. Créer la livraison
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