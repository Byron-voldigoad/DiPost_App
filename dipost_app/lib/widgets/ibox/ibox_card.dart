// IBox card 
import 'package:flutter/material.dart';
import '../../../models/ibox.dart';

class IBoxCard extends StatelessWidget {
  final IBox ibox;
  final VoidCallback onTap;

  const IBoxCard({
    Key? key,
    required this.ibox,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'Disponible':
        return Colors.green;
      case 'Occupée':
        return Colors.orange;
      case 'En maintenance':
        return Colors.blue;
      case 'Hors service':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'iBox #${ibox.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(
                      ibox.statut,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(ibox.statut),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ibox.adresse,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Capacité: ${ibox.capacite} colis',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}