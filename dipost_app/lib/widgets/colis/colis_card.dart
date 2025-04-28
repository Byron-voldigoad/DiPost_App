// Colis card 
import 'package:flutter/material.dart';
import '../../models/colis.dart';

class ColisCard extends StatelessWidget {
  final Colis colis;

  const ColisCard({super.key, required this.colis});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Colis #${colis.id}'),
        subtitle: Text(colis.contenu),
        trailing: Chip(label: Text(colis.statut)),
      ),
    );
  }
}