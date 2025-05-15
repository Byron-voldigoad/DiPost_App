import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibox_provider.dart';
import '../theme/app_theme.dart';

class IBoxDetailScreen extends StatefulWidget {
  final int iboxId;

  const IBoxDetailScreen({super.key, required this.iboxId});

  @override
  State<IBoxDetailScreen> createState() => _IBoxDetailScreenState();
}

class _IBoxDetailScreenState extends State<IBoxDetailScreen> {
  late IBox _ibox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIBoxDetails();
  }

  Future<void> _loadIBoxDetails() async {
    final provider = Provider.of<IBoxProvider>(context, listen: false);
    final ibox = await provider.getIBoxById(widget.iboxId);

    if (mounted) {
      setState(() {
        _ibox = ibox!;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatut(String newStatut) async {
    final provider = Provider.of<IBoxProvider>(context, listen: false);
    final success = await provider.updateIBoxStatut(_ibox.id, newStatut);

    if (!mounted) return;

    if (success) {
      await _loadIBoxDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour: $newStatut'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Échec de la mise à jour'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _updateAdresse(String newAdresse) async {
    final provider = Provider.of<IBoxProvider>(context, listen: false);
    final success = await provider.updateIBoxAdresse(_ibox.id, newAdresse);

    if (!mounted) return;

    if (success) {
      await _loadIBoxDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Adresse mise à jour avec succès'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Échec de la mise à jour de l\'adresse'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Container(
      decoration: AppTheme.getBackgroundDecoration(authProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Détails iBox'),
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
                        'iBox #${_ibox.id}',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEditableDetailItem(
                                'Adresse',
                                _ibox.adresse,
                                _updateAdresse,
                                primaryColor,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailItemWithDropdown(
                                'Statut',
                                _ibox.statut,
                                IBox.statutsPossibles,
                                _updateStatut,
                                primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          label == 'Adresse' ? Icons.location_on : Icons.info,
          color: primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemWithDropdown(
    String label,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
    Color primaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.track_changes, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: currentValue,
                items:
                    options.map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
      ],
    );
  }

  Widget _buildEditableDetailItem(
    String label,
    String currentValue,
    Function(String) onChanged,
    Color primaryColor,
  ) {
    final controller = TextEditingController(text: currentValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: controller,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty && newValue != currentValue) {
                onChanged(newValue);
              }
            },
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
