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
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _iboxesLoaded = false;
  Livraison? _existingLivraison;
  String? _selectedPaymentMethod;
  String? _selectedMobilePayment;
  bool _isPaymentSimulated = false;
  double _deliveryPrice = 0.0; // Dynamic delivery price

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingLivraison();
      _loadIBoxes();
    });
  }

  Future<void> _checkExistingLivraison() async {
    final livraisonProvider = Provider.of<LivraisonProvider>(
      context,
      listen: false,
    );
    try {
      final livraison = await livraisonProvider.getLivraisonByColisId(
        widget.colis.id,
      );
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

  Future<double> _calculateDeliveryPrice(String? destinationAddress) async {
    // Simulate distance calculation logic
    const double basePrice = 1000.0; // Base price
    const double pricePerKm = 200.0; // Price per kilometer
    const double simulatedDistance = 10.0; // Simulated distance in kilometers

    // In a real-world scenario, you would calculate the distance using a geocoding API.
    return basePrice + (simulatedDistance * pricePerKm);
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iboxProvider = Provider.of<IBoxProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    if (_existingLivraison != null) {
      return _buildAlreadyRequestedView(primaryColor);
    }

    return Container(
      decoration: AppTheme.getBackgroundDecoration(authProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Demande de livraison'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisissez le point de livraison',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
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
                              SwitchListTile(
                                title: const Text(
                                  'Utiliser une adresse personnalisée',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                value: _useCustomAddress,
                                activeColor: primaryColor,
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
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    _iboxesLoaded
                                        ? DropdownButtonFormField<int?>(
                                          value: _selectedIBoxId,
                                          isExpanded:
                                              true, // Allow long addresses
                                          items: [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text(
                                                'Sélectionnez une iBox',
                                              ),
                                            ),
                                            ...iboxProvider.iboxes.map((ibox) {
                                              return DropdownMenuItem(
                                                value: ibox.id,
                                                child: Text(ibox.adresse),
                                              );
                                            }).toList(),
                                          ],
                                          onChanged: (value) async {
                                            setState(() {
                                              _selectedIBoxId = value;
                                            });
                                            if (value != null) {
                                              final selectedIBox = iboxProvider
                                                  .iboxes
                                                  .firstWhere(
                                                    (ibox) => ibox.id == value,
                                                  );
                                              _deliveryPrice =
                                                  await _calculateDeliveryPrice(
                                                    _useCustomAddress
                                                        ? _adresseController
                                                            .text
                                                        : selectedIBox.adresse,
                                                  );
                                              setState(() {});
                                            }
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.location_on,
                                              color: primaryColor,
                                            ),
                                          ),
                                          dropdownColor: Colors.white
                                              .withOpacity(0.95),
                                        )
                                        : const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                  ],
                                ),
                                secondChild: TextField(
                                  controller: _adresseController,
                                  decoration: InputDecoration(
                                    labelText: 'Adresse de livraison',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                    prefixIcon: Icon(
                                      Icons.map,
                                      color: primaryColor,
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    _selectedAdresse = value;
                                    _deliveryPrice =
                                        await _calculateDeliveryPrice(value);
                                    setState(() {});
                                  },
                                ),
                                crossFadeState:
                                    _useCustomAddress
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                              ),
                              const SizedBox(height: 16),
                              if (_deliveryPrice > 0)
                                Text(
                                  'Prix de la livraison: $_deliveryPrice FCFA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              const SizedBox(height: 32),
                              Text(
                                'Mode de paiement',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedPaymentMethod,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'application',
                                    child: Text('Payer via l\'application'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'livreur',
                                    child: Text('Payer au livreur'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                    _selectedMobilePayment = null;
                                    _phoneController.clear();
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  prefixIcon: Icon(
                                    Icons.payment,
                                    color: primaryColor,
                                  ),
                                ),
                                dropdownColor: Colors.white.withOpacity(0.95),
                              ),
                              if (_selectedPaymentMethod == 'application') ...[
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedMobilePayment,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'MTN',
                                      child: Text('MTN Mobile Money'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Orange',
                                      child: Text('Orange Money'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMobilePayment = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Choisissez un mode de paiement',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                    prefixIcon: Icon(
                                      Icons.phone_android,
                                      color: primaryColor,
                                    ),
                                  ),
                                  dropdownColor: Colors.white.withOpacity(0.95),
                                ),
                                if (_selectedMobilePayment != null) ...[
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Entrez votre numéro de téléphone',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.8),
                                      prefixIcon: Icon(
                                        Icons.phone,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
                          onPressed: _submitDemande,
                          child: const Text(
                            'Confirmer la demande',
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
    );
  }

  Widget _buildAlreadyRequestedView(Color primaryColor) {
    return Container(
      decoration: AppTheme.getBackgroundDecoration(
        Provider.of<AuthProvider>(context, listen: false),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Demande de livraison'),
          backgroundColor: primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: primaryColor, size: 80),
                    const SizedBox(height: 24),
                    Text(
                      'Demande de livraison déjà effectuée',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Statut: ${_existingLivraison?.statut ?? 'En cours'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Retour',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDemande() async {
    if ((!_useCustomAddress && _selectedIBoxId == null) ||
        (_useCustomAddress &&
            (_selectedAdresse == null || _selectedAdresse!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un point de livraison'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un mode de paiement'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == 'application') {
      if (_selectedMobilePayment == null || _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Veuillez entrer un numéro de téléphone valide',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Simulate payment if required
      if (_selectedPaymentMethod == 'application') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Paiement effectuer avec succès via $_selectedMobilePayment pour le numéro ${_phoneController.text}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      final updatedColis = widget.colis.copyWith(
        statut: 'En attente de livraison',
        iboxId: _useCustomAddress ? null : _selectedIBoxId,
        iboxAdresse: _useCustomAddress ? _selectedAdresse : null,
      );

      await Provider.of<ColisProvider>(
        context,
        listen: false,
      ).updateColis(updatedColis);

      final livraisonId = await Provider.of<LivraisonProvider>(
        context,
        listen: false,
      ).createLivraison(Livraison(colisId: widget.colis.id));

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
