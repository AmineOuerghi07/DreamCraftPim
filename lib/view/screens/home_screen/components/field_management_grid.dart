import 'package:flutter/material.dart';
import 'feature_card.dart';

class FieldManagementGrid extends StatelessWidget {
  final Function(String) onFeatureSelected;

  const FieldManagementGrid({
    Key? key,
    required this.onFeatureSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage your fields',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'My Connected\nRegions',
                icon: Icons.cloud_outlined,
                iconBgColor: Colors.blue[100]!,
                onTap: () => onFeatureSelected('regions'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                title: 'Rent\nLands',
                icon: Icons.eco_outlined,
                iconBgColor: Colors.green[100]!,
                onTap: () => onFeatureSelected('lands'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'Inventory',
                icon: Icons.inventory_2_outlined,
                iconBgColor: Colors.orange[100]!,
                onTap: () => onFeatureSelected('inventory'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                title: 'Balance',
                icon: Icons.account_balance_outlined,
                iconBgColor: Colors.yellow[100]!,
                onTap: () => onFeatureSelected('balance'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}