import 'package:dipost_app/screens/qr/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/ibox_provider.dart';

class IBoxDetailScreen extends StatelessWidget {
  final IBox box;
  
  const IBoxDetailScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    final qrData = 'IBOX:${box.boxId}:${box.senderId}';

    return Scaffold(
      appBar: AppBar(
        title: Text('iBox #${box.boxId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusIndicator(box.status),
                    const SizedBox(height: 20),
                    Text(
                      'iBox #${box.boxId}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Localisation', box.location),
                    _buildDetailRow('Taille', box.size),
                    _buildDetailRow('Statut', box.status),
                    _buildDetailRow('Depuis', _formatDate(box.reservationDate)),
                    if (box.collectionDate != null)
                      _buildDetailRow('Collecté le', _formatDate(box.collectionDate!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Code: ${box.boxId}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (box.status != 'Livré')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _markAsDelivered(context),
                  child: const Text('Marquer comme Livré'),
                ),
              ),
          SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.qr_code_scanner),
    label: const Text('Scanner un colis'),
    onPressed: () => _scanParcelQR(context),
  ),
),
          ],
          
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'Livré':
        color = Colors.green;
        break;
      case 'En attente':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _markAsDelivered(BuildContext context) async {
    final provider = Provider.of<IBoxProvider>(context, listen: false);
    try {
      await provider.updateIBoxStatus(box.id!, 'Livré');
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  void _scanParcelQR(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QRScannerScreen(
        onScanComplete: (qrData) {
          // Traitement des données scannées
          _processScannedData(context, qrData);
        },
      ),
    ),
  );
}

void _processScannedData(BuildContext context, String qrData) {
  final parts = qrData.split(':');
  if (parts.length >= 2) {
    final parcelId = parts[1];
    final iboxProvider = Provider.of<IBoxProvider>(context, listen: false);
    
    // Mettre à jour l'iBox avec le colis scanné
    iboxProvider.updateParcelInIBox(box.id!, parcelId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Colis $parcelId ajouté à l\'iBox')),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    });
  }
}
}