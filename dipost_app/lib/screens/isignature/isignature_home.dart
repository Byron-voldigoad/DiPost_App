import 'package:flutter/material.dart';

class ISignatureHomeScreen extends StatelessWidget {
  const ISignatureHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iSignature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents à signer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.description, color: Colors.blue),
                      title: Text('Contrat ${index + 1}'),
                      subtitle: const Text('En attente de signature'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // TODO: Naviguer vers l'écran de signature
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('Importer un document'),
                onPressed: () {
                  _showUploadDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer un document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez une source:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 40),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.photo, size: 40),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.insert_drive_file, size: 40),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}