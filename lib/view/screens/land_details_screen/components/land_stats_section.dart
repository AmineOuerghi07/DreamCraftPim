import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:provider/provider.dart';
import 'info_card.dart';

class LandStatsSection extends StatelessWidget {
  final Land land;

  const LandStatsSection({
    Key? key,
    required this.land,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
final viewModel = Provider.of<LandDetailsViewModel>(context);
    
    // Get the plant count from the view model
    final plantCount = viewModel.totalPlantCount;
    return SizedBox(
      height: isTablet ? 400 : 150, // Taller for tablet's column layout
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isTablet 
            // Column layout for tablet
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoCard(
                    title: l10n.expanse,
                    value: "${land.surface}m²",
                    imageName: "square_foot.png",
                  ),
               
                  InfoCard(
                    title: l10n.plants,
                    value: "${plantCount}",
                    imageName: "plant.png",
                  ),
                ],
              )
            // Row layout for phones - exactly like original
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoCard(
                    title: l10n.expanse,
                    value: "${land.surface}m²",
                    imageName: "square_foot.png",
                  ),
             
                  InfoCard(
                    title: l10n.plants,
                    value: "${plantCount}",
                    imageName: "plant.png",
                  ),
                ],
              ),
        ),
      ),
    );
  }
}