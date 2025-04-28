import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibox_provider.dart';
import 'ibox_detail_screen.dart';
import 'ibox_create_screen.dart';

class IBoxListScreen extends StatefulWidget {
  const IBoxListScreen({super.key});

  @override
  State<IBoxListScreen> createState() => _IBoxListScreenState();
}

class _IBoxListScreenState extends State<IBoxListScreen> {
  String? _selectedStatutFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IBoxProvider>(context, listen: false).loadIBoxes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final iboxProvider = Provider.of<IBoxProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des iBoxes'),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedStatutFilter = value == 'Tous' ? null : value;
              });
              iboxProvider.loadIBoxes(statut: _selectedStatutFilter);
            },
            itemBuilder: (BuildContext context) {
              return ['Tous', ...IBox.statutsPossibles]
                  .map((statut) => PopupMenuItem(
                        value: statut,
                        child: Text(statut),
                      ))
                  .toList();
            },
          ),
        ],
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 119, 5, 154),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IBoxCreateScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: _buildIBoxList(iboxProvider, authProvider),
    );
  }

  Widget _buildIBoxList(IBoxProvider iboxProvider, AuthProvider authProvider) {
    if (iboxProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (iboxProvider.iboxes.isEmpty) {
      return const Center(child: Text('Aucune iBox trouvée'));
    }

    return ListView.builder(
      itemCount: iboxProvider.iboxes.length,
      itemBuilder: (context, index) {
        final ibox = iboxProvider.iboxes[index];
        return ListTile(
          title: Text(ibox.adresse),
          subtitle: Text('Statut: ${ibox.statut}'),
          trailing: authProvider.isAdmin
              ? IconButton(
                  icon: const Icon(Icons.edit,color: Color.fromARGB(255, 119, 5, 154)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IBoxDetailScreen(iboxId: ibox.id),
                    ),
                  ),
                )
              : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IBoxDetailScreen(iboxId: ibox.id),
            ),
          ),
        );
      },
    );
  }
}