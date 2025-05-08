import 'package:dipost_app/screens/colis/add_colis_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/colis_provider.dart';
import 'colis_detail_screen.dart'; // Assurez-vous que ce fichier existe

class ColisListScreen extends StatefulWidget {
  const ColisListScreen({super.key});

  @override
  State<ColisListScreen> createState() => _ColisListScreenState();
}

class _ColisListScreenState extends State<ColisListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadColis());
  }

  Future<void> _loadColis() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<ColisProvider>(context, listen: false).loadColis(
      userId: authProvider.user?.id,
      userRole: authProvider.user?.role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final colisProvider = Provider.of<ColisProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.isLivreur 
            ? 'Colis à livrer' 
            : 'Mes Colis',
        ),
        backgroundColor: const Color.fromARGB(255, 119, 5, 154),
      ),
      body: _buildBody(colisProvider),
      floatingActionButton: authProvider.isClient || authProvider.isAdmin || authProvider.isOperateur
          ? FloatingActionButton(
              onPressed: () => _navigateToAddColis(context),
              backgroundColor: const Color.fromARGB(255, 119, 5, 154),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody(ColisProvider colisProvider) {
    if (colisProvider.isLoading && colisProvider.colisList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadColis,
      child: colisProvider.colisList.isEmpty
          ? const Center(child: Text('Aucun colis disponible'))
          : ListView.builder(
              itemCount: colisProvider.colisList.length,
              itemBuilder: (context, index) {
                final colis = colisProvider.colisList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('Colis #${colis.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contenu: ${colis.contenu}'),
                        Text('Statut: ${colis.statut}'),
                        if (colis.iboxId != null)
                          Text('iBox: ${colis.iboxAdresse}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ColisDetailScreen(colisId: colis.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _navigateToAddColis(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddColisScreen()),
    );
    
    if (result == true) {
      await _loadColis();
    }
  }
}