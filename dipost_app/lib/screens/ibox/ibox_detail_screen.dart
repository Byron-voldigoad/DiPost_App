import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails iBox'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'iBox #${_ibox.id}',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem('Adresse', _ibox.adresse),
                          const SizedBox(height: 16),
                          _buildDetailItemWithDropdown(
                            'Statut',
                            _ibox.statut,
                            IBox.statutsPossibles,
                            _updateStatut,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          label == 'Adresse' ? Icons.location_on : Icons.info,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.track_changes,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: currentValue,
                items: options.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}