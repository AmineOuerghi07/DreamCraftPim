// view/screens/components/rent_land_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RentLandCard extends StatelessWidget {
  final Land land;

  const RentLandCard({
    Key? key,
    required this.land,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isLandscape = size.width > size.height;
    final l10n = AppLocalizations.of(context)!;
    
    // Calculate dynamic sizes based on screen width
    final imageSize = isTablet ? size.width * 0.12 : size.width * 0.20;
    final double fontSize = isTablet ? 16.0 : 14.0;
    final double titleFontSize = isTablet ? 18.0 : 16.0;
    final double priceFontSize = isTablet ? 16.0 : 14.0;
    
    // Get phone number from land, either directly or from owner
    final phoneNumber = land.getPhoneNumber();
    final ownerName = land.owner?.fullname ?? '';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Land Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    land.image.isNotEmpty
                        ? AppConstants.imagesbaseURL + land.image
                        : 'assets/images/placeholder.png',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                
                SizedBox(width: isTablet ? 16 : 8),
                
                // Land Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        land.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: fontSize - 2, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              land.cordonate,
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      // Surface
                      Row(
                        children: [
                          Icon(Icons.straighten, size: fontSize - 2, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${land.surface.toStringAsFixed(0)} m²",
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // Owner name if available
                      if (ownerName.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: fontSize - 2, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ownerName,
                                style: TextStyle(
                                  fontSize: fontSize - 2,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      SizedBox(height: 4),
                      
                      // Price and Phone
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${land.rentPrice.toStringAsFixed(2)} DT/month",
                              style: TextStyle(
                                fontSize: priceFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: 4),
                          
                          // Contact Info
                          Row(
                            children: [
                              Icon(Icons.phone, size: fontSize - 2, color: Colors.grey),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  phoneNumber.isEmpty ? l10n.contactNotAvailable : phoneNumber,
                                  style: TextStyle(
                                    fontSize: fontSize - 2,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isTablet ? 16 : 8),
            
            // Read Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/land-details-for-rent/${land.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.readDetails,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 