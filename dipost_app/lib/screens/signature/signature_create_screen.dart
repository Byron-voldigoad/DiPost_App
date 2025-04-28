// Signature create screen 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/signature_provider.dart';
import '../../../widgets/common/app_bar.dart';

class SignatureCreateScreen extends StatefulWidget {
  const SignatureCreateScreen({Key? key}) : super(key: key);

  @override
  _SignatureCreateScreenState createState() => _SignatureCreateScreenState();
}

class _SignatureCreateScreenState extends State<SignatureCreateScreen> {
  String? _selectedNiveau;
  XFile? _selectedDocument;

  final List<String> _niveaux = [
    'simple',
    'avancee',
    'qualifiee'
  ];

  Future<void> _pickDocument() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedDocument = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final signatureProvider = Provider.of<SignatureProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text ('Créer une Signature')),
      backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedNiveau,
              hint: const Text('Niveau de signature'),
              items: _niveaux.map((niveau) {
                return DropdownMenuItem(
                  value: niveau,
                  child: Text(niveau),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNiveau = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un niveau';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDocument,
              child: const Text('Sélectionner un document'),
            ),
            if (_selectedDocument != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Document sélectionné: ${_selectedDocument!.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (_selectedNiveau != null && _selectedDocument != null) {
                  await signatureProvider.createSignature(
                    document: _selectedDocument!,
                    niveau: _selectedNiveau!,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez compléter tous les champs')),
                  );
                }
              },
              child: const Text('Signer le document'),
            ),
          ],
        ),
      ),
    );
  }
}