import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ibox.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibox_provider.dart';
import '../theme/app_theme.dart';
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
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Theme.of(context).appBarTheme.iconTheme?.color),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IBoxCreateScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: _buildIBoxList(iboxProvider, authProvider),
      ),
    );
  }

  Widget _buildIBoxList(IBoxProvider iboxProvider, AuthProvider authProvider) {
    if (iboxProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (iboxProvider.iboxes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              'Aucune iBox trouvée',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: iboxProvider.iboxes.length,
      itemBuilder: (context, index) {
        final ibox = iboxProvider.iboxes[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            title: Text(
              ibox.adresse,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Statut: ${ibox.statut}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: authProvider.isAdmin
                ? IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
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
          ),
        );
      },
    );
  }
}