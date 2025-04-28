import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/ibox_provider.dart';
import '../../widgets/common/app_bar.dart';

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
  
  if (success) {  // success est maintenant un booléen
    await _loadIBoxDetails();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statut mis à jour: $newStatut')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Échec de la mise à jour')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails iBox'),
      backgroundColor: const Color.fromARGB(255, 119, 5, 154)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'iBox #${_ibox.id}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('Adresse', _ibox.adresse),
                  _buildDetailItem('Capacité', _ibox.capacite.toString()),
                  _buildDetailItemWithDropdown(
                    'Statut',
                    _ibox.statut,
                    IBox.statutsPossibles,
                    _updateStatut,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDetailItemWithDropdown(
    String label,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
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
          ),
        ],
      ),
    );
  }
}