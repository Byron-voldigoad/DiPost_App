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
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des iBoxes'),
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(authProvider),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildIBoxList(iboxProvider, authProvider, primaryColor),
        ),
      ),
    );
  }

  Widget _buildIBoxList(IBoxProvider iboxProvider, AuthProvider authProvider, Color primaryColor) {
    if (iboxProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (iboxProvider.iboxes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Aucune iBox trouvée',
              style: TextStyle(
                fontSize: 20,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => iboxProvider.loadIBoxes(statut: _selectedStatutFilter),
      color: primaryColor,
      child: ListView.builder(
        itemCount: iboxProvider.iboxes.length,
        itemBuilder: (context, index) {
          final ibox = iboxProvider.iboxes[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white.withOpacity(0.9),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: Icon(Icons.location_on, color: primaryColor),
              title: Text(
                ibox.adresse,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              subtitle: Text(
                'Statut: ${ibox.statut}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: authProvider.isAdmin
                  ? IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
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
      ),
    );
  }
}