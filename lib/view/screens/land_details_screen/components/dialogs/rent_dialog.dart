import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showSetForRentDialog(BuildContext context, LandDetailsViewModel viewModel, Land land) {
  // Get screen dimensions for responsive dialog
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final l10n = AppLocalizations.of(context)!;
  
  // Text controller for the price input
  final TextEditingController priceController = TextEditingController();
  // Add the current price if already set
  if (land.rentPrice != null && land.rentPrice! > 0) {
    priceController.text = land.rentPrice.toString();
  }
  
  showDialog(
    context: context,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (context, setState) {
        bool isValidPrice = true;
        
        return AlertDialog(
          title: Text(
            l10n.setForRent,
            style: TextStyle(fontSize: isTablet ? 22 : 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.confirmSetForRent,
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                l10n.setRentalPrice,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.price,
                  hintText: l10n.enterRentalPrice,
                  suffixText: 'DT/month',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    // Validate price input
                    if (value.isEmpty) {
                      isValidPrice = false;
                    } else {
                      try {
                        double price = double.parse(value);
                        isValidPrice = price > 0;
                      } catch (e) {
                        isValidPrice = false;
                      }
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                // Validate price input before proceeding
                if (priceController.text.isEmpty) {
                  setState(() {
                    isValidPrice = false;
                  });
                  return;
                }
                
                double? price;
                try {
                  price = double.parse(priceController.text);
                  if (price <= 0) {
                    setState(() {
                      isValidPrice = false;
                    });
                    return;
                  }
                } catch (e) {
                  setState(() {
                    isValidPrice = false;
                  });
                  return;
                }
                
                // Update the land with forRent = true and the rental price
                final updatedLand = land.copyWith(
                  forRent: true,
                  rentPrice: price,
                );
                
                // Call the updateLand method
                final response = await viewModel.updateLand(updatedLand);
                
                // Pop dialog
                if (context.mounted) context.pop();
                
                if (response.status == Status.COMPLETED) {
                  // Refresh land data
                  await viewModel.fetchLandById(land.id);
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.landIsNowForRent),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.message ?? l10n.updateFailed),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.confirm, style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      }
    ),
  );
}

void showDisableRentDialog(BuildContext context, LandDetailsViewModel viewModel, Land land) {
  // Get screen dimensions for responsive dialog
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final l10n = AppLocalizations.of(context)!;
  
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        l10n.disableForRent,
        style: TextStyle(fontSize: isTablet ? 22 : 18),
      ),
      content: Text(
        l10n.confirmDisableForRent,
        style: TextStyle(fontSize: isTablet ? 18 : 16),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            // Update the land with forRent = false
            final updatedLand = land.copyWith(forRent: false);
            
            // Call the updateLand method
            final response = await viewModel.updateLand(updatedLand);
            
            // Pop dialog
            if (context.mounted) context.pop();
            
            if (response.status == Status.COMPLETED) {
              // Refresh land data
              await viewModel.fetchLandById(land.id);
              
              // Show success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.landIsNoLongerForRent),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            } else {
              // Show error message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message ?? l10n.updateFailed),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(l10n.confirm, style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}