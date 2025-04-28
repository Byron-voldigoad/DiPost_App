// Signature list screen 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/signature_provider.dart';
import '../../widgets/common/app_bar.dart';

class SignatureListScreen extends StatelessWidget {
  const SignatureListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signatureProvider = Provider.of<SignatureProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Signatures')),
      backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      body: signatureProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : signatureProvider.signatures.isEmpty
              ? const Center(child: Text('Aucune signature trouvée'))
              : ListView.builder(
                  itemCount: signatureProvider.signatures.length,
                  itemBuilder: (context, index) {
                    final signature = signatureProvider.signatures[index];
                    return ListTile(
                      title: Text('Signature #${signature.id}'),
                      subtitle: Text(signature.niveau),
                      // Ajoutez plus de détails au besoin
                    );
                  },
                ),
    );
  }
}