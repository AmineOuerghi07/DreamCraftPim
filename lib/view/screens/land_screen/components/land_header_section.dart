// view/screens/land_screen/components/land_header_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/view_model/land_view_model.dart';

class LandHeaderSection extends StatelessWidget {
  const LandHeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.yourGreenhouses,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Consumer<LandViewModel>(
          builder: (context, viewModel, child) {
            return Text(
              "${viewModel.filteredLands.length} ${l10n.places}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }
}