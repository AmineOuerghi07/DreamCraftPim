// view/screens/land_screen/components/land_list_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/view/screens/land_screen/components/land_card.dart';

class LandListView extends StatelessWidget {
  final List<Land> lands;

  const LandListView({
    Key? key,
    required this.lands,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListView.builder(
      itemCount: lands.length,
      itemBuilder: (context, index) {
        final land = lands[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: LandCard(
            title: land.name,
            location: land.cordonate,
            description: "${l10n.surface}: ${land.surface}m² • ${land.forRent ? l10n.forRent : l10n.notAvailable}",
            imageUrl: land.image.isNotEmpty ? AppConstants.imagesbaseURL + land.image : 'assets/images/placeholder.png',
            id: land.id,
            onDetailsTap: () {
              GoRouter.of(context).push('/land-details/${land.id}');
            },
          ),
        );
      },
    );
  }
}