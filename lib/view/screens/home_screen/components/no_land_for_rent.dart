// view/screens/components/no_land_for_rent.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';

class NoLandForRent extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const NoLandForRent({
    Key? key,
    this.onTryAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_lands_for_rent.png',
              width: isTablet ? 200 : 150,
              height: isTablet ? 200 : 150,
            ),
            SizedBox(height: 24),
            Text(
              l10n.noLandsForRent,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.noLandsForRent ,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onTryAgain,
                  child: Text(l10n.retry),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    context.push(RouteNames.billingScreen);
                  },
                  child: Text(l10n.myBillings),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}