// view/screens/land_screen/components/land_filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/view_model/land_view_model.dart';

class LandFilterDialog extends StatefulWidget {
  final String selectedFilter;
  final String selectedLocation;
  final Function(String) onFilterChanged;
  final Function(String) onLocationChanged;

  const LandFilterDialog({
    super.key,
    required this.selectedFilter,
    required this.selectedLocation,
    required this.onFilterChanged,
    required this.onLocationChanged,
  });

  @override
  State<LandFilterDialog> createState() => _LandFilterDialogState();
}

class _LandFilterDialogState extends State<LandFilterDialog> {
  late String _selectedFilter;
  late String _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final landViewModel = Provider.of<LandViewModel>(context, listen: false);
    final locations = ['all', ...landViewModel.lands.map((land) => land.cordonate).toSet()];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.filterOptions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Rent Status Filter
            Text(l10n.rentStatus),
            Column(
              children: [
                RadioListTile(
                  title: Text(l10n.allLocations),
                  value: 'all',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value.toString());
                  },
                ),
                RadioListTile(
                  title: Text(l10n.forRent),
                  value: 'forRent',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value.toString());
                  },
                ),
                RadioListTile(
                  title: Text(l10n.notForRent),
                  value: 'notForRent',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value.toString());
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Location Filter
            Text(l10n.location),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location == 'all' ? l10n.allLocations : location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLocation = value!);
              },
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onFilterChanged(_selectedFilter);
                    widget.onLocationChanged(_selectedLocation);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor, 
                  ),
                  child: Text(l10n.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}