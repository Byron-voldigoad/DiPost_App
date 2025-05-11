import 'package:dipost_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../services/database_helper.dart';
import '../theme/app_theme.dart';

class LivraisonScanScreen extends StatefulWidget {
  const LivraisonScanScreen({super.key});

  @override
  State<LivraisonScanScreen> createState() => _LivraisonScanScreenState();
}

class _LivraisonScanScreenState extends State<LivraisonScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner livraison'),
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return Icon(Icons.flash_off, color: Theme.of(context).appBarTheme.iconTheme?.color);
                  case TorchState.on:
                    return Icon(Icons.flash_on, color: Theme.of(context).appBarTheme.iconTheme?.color);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_isProcessing) return;
              setState(() => _isProcessing = true);

              try {
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;

                final code = barcodes.first.rawValue;
                if (code == null || !code.startsWith('LIV-')) {
                  _showError(context, 'QR code invalide');
                  return;
                }

                final parts = code.split('-');
                if (parts.length < 4) {
                  _showError(context, 'Format QR code incorrect');
                  return;
                }

                final livraisonId = int.tryParse(parts[1]);
                final colisId = int.tryParse(parts[3]);
                if (livraisonId == null || colisId == null) {
                  _showError(context, 'IDs invalides dans le QR code');
                  return;
                }

                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final livreurId = authProvider.user?.id;

                if (livreurId == null) {
                  _showError(context, 'Livreur non identifié');
                  return;
                }

                final db = await DatabaseHelper.instance.database;

                final livraisonValide = await db.query(
                  'livraisons',
                  where: 'id = ? AND colis_id = ? AND livreur_id = ? AND statut IN (?, ?)',
                  whereArgs: [livraisonId, colisId, livreurId, 'En attente', 'En cours'],
                  limit: 1,
                );

                if (livraisonValide.isEmpty) {
                  _showError(context, 'Livraison non trouvée ou déjà validée');
                  return;
                }

                await db.transaction((txn) async {
                  final now = DateTime.now().toIso8601String();

                  await txn.update(
                    'livraisons',
                    {
                      'statut': 'Livré',
                      'date_livraison': now,
                    },
                    where: 'id = ?',
                    whereArgs: [livraisonId],
                  );

                  await txn.update(
                    'colis',
                    {
                      'statut': 'Livré',
                      'updated_at': now,
                    },
                    where: 'id_colis = ?',
                    whereArgs: [colisId],
                  );

                  await txn.insert('historique_livraisons', {
                    'livraison_id': livraisonId,
                    'action': 'Livraison validée par scan QR',
                    'date_action': now,
                    'user_id': livreurId,
                  });
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Livraison validée avec succès !'),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                debugPrint('Erreur validation livraison: $e');
                if (mounted) {
                  _showError(context, 'Erreur technique: ${e.toString()}');
                }
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Scannez le QR code de la livraison',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}