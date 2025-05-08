import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colis.dart';
import '../../providers/colis_provider.dart';
import '../../providers/auth_provider.dart';

class ModifierColisScreen extends StatefulWidget {
  final Colis colis;

  const ModifierColisScreen({super.key, required this.colis});

  @override
  State<ModifierColisScreen> createState() => _ModifierColisScreenState();
}

class _ModifierColisScreenState extends State<ModifierColisScreen> {
  late TextEditingController _contenuController;
  late TextEditingController _destinataireController;
  late TextEditingController _expediteurController;
  late TextEditingController _iboxController;
  late String _selectedStatut;
  bool _isLoading = false;

  final List<String> _statuts = [
    'En préparation',
    'Enregistré',
    'Expédié',
    'En transit',
    'Livré',
    'Retourné'
  ];

  @override
  void initState() {
    super.initState();
    _contenuController = TextEditingController(text: widget.colis.contenu);
    _destinataireController = TextEditingController(
      text: '${widget.colis.destinatairePrenom} ${widget.colis.destinataireNom}',
    );
    _expediteurController = TextEditingController(
      text: '${widget.colis.expediteurPrenom} ${widget.colis.expediteurNom}',
    );
    _iboxController = TextEditingController(
      text: widget.colis.iboxAdresse ?? 'Non spécifiée',
    );
    _selectedStatut = widget.colis.statut;
  }

  @override
  void dispose() {
    _contenuController.dispose();
    _destinataireController.dispose();
    _expediteurController.dispose();
    _iboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le colis'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _contenuController,
                    decoration: const InputDecoration(
                      labelText: 'Contenu du colis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _destinataireController,
                    decoration: const InputDecoration(
                      labelText: 'Destinataire',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _expediteurController,
                    decoration: const InputDecoration(
                      labelText: 'Expéditeur',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.person),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _iboxController,
                    decoration: const InputDecoration(
                      labelText: 'iBox',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.location_on),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedStatut,
                    items: _statuts.map((statut) {
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
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 119, 5, 154),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _saveChanges,
                    child: const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final updatedColis = widget.colis.copyWith(
      contenu: _contenuController.text,
      statut: _selectedStatut,
    );

    try {
      final colisProvider = Provider.of<ColisProvider>(context, listen: false);
      await colisProvider.updateColis(updatedColis);
      
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la modification: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}