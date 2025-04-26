import 'package:dipost_app/screens/qr/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibox_provider.dart';
import 'ibox_detail.dart';

class IBoxListScreen extends StatefulWidget {
  const IBoxListScreen({super.key});

  @override
  State<IBoxListScreen> createState() => _IBoxListScreenState();
}

class _IBoxListScreenState extends State<IBoxListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIBoxes());
  }

  Future<void> _loadIBoxes() async {
    final authProvider = context.read<AuthProvider>();
    final iboxProvider = context.read<IBoxProvider>();

    if (authProvider.state.isAuthenticated) {
      await iboxProvider.loadUserIBoxes(authProvider.state.postalId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes iBox')),
      body: Consumer2<AuthProvider, IBoxProvider>(
        builder: (context, authProvider, iboxProvider, _) {
          if (!authProvider.state.isAuthenticated) {
            return const Center(child: Text('Veuillez vous connecter'));
          }

          if (iboxProvider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(iboxProvider.error!)),
              );
              iboxProvider.clearError();
            });
          }

          if (iboxProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (iboxProvider.iboxes.isEmpty) {
            return const Center(child: Text('Aucune iBox trouvée'));
          }

          return RefreshIndicator(
            onRefresh: _loadIBoxes,
            child: ListView.builder(
              itemCount: iboxProvider.iboxes.length,
              itemBuilder: (context, index) {
                final box = iboxProvider.iboxes[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    onLongPress: () => _showIBoxOptions(context, box),
                    leading: _getStatusIcon(box.status),
                    title: Text('iBox #${box.boxId}'),
                    subtitle: Text('Statut: ${box.status}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IBoxDetailScreen(box: box),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIBoxDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddIBoxDialog(BuildContext context) {
    final boxIdController = TextEditingController();
    final locationController = TextEditingController();
    String selectedSize = 'moyen(M)';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle iBox'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: boxIdController,
                    decoration: const InputDecoration(labelText: 'ID iBox'),
                  ),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Localisation'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Taille de l\'iBox:'),
                  DropdownButton<String>(
                    value: selectedSize,
                    items: ['petit(S)', 'moyen(M)', 'grand(L)', 'très grand(XL)']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => selectedSize = newValue!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final authProvider = context.read<AuthProvider>();
                      final iboxProvider = context.read<IBoxProvider>();

                      final newBox = IBox(
                        boxId: boxIdController.text,
                        location: locationController.text,
                        size: selectedSize,
                        reservationDate: DateTime.now(),
                        status: 'En attente',
                        senderId: authProvider.state.postalId,
                      );

                      await iboxProvider.addIBox(newBox);
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIBoxOptions(BuildContext context, IBox box) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Scanner colis'),
              onTap: () {
                Navigator.pop(context);
                _scanParcelForIBox(context, box);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, box);
              },
            ),
          ],
        );
      },
    );
  }

  void _scanParcelForIBox(BuildContext context, IBox box) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          onScanComplete: (qrData) => _processScannedDataForIBox(context, box, qrData),
        ),
      ),
    );
  }

  void _processScannedDataForIBox(BuildContext context, IBox box, String qrData) {
    final parts = qrData.split(':');
    if (parts.length >= 2) {
      final parcelId = parts[1];
      final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
      
      iboxProvider.updateParcelInIBox(box.id!, parcelId).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Colis $parcelId ajouté avec succès')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code invalide')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, IBox box) {
    final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer cette iBox ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await iboxProvider.deleteIBox(box.id!, authProvider.state.postalId!);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('iBox supprimée avec succès')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disponible':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'en attente':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'livré':
        return const Icon(Icons.local_shipping, color: Colors.blue);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }
}