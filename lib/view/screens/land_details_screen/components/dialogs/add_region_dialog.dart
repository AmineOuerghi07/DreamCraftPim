import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showAddRegionDialog(BuildContext context, Land land) {
  TextEditingController nameController = TextEditingController();
  TextEditingController surfaceController = TextEditingController();
  final l10n = AppLocalizations.of(context)!;

  // Get screen dimensions for better responsiveness
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
  final isSmallPhone = screenWidth < 360;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            // Make dialog more responsive on different devices
            insetPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 64.0 : (isSmallPhone ? 16.0 : 24.0),
              vertical: isTablet ? 32.0 : 24.0,
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    Center(
                      child: Text(
                        l10n.addNewRegion,
                        style: TextStyle(
                          fontSize: isTablet ? 24 : (isSmallPhone ? 18 : 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.regionName,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    TextField(
                      controller: surfaceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.surfaceArea,
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              surfaceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.pleaseFillFields),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final surface = double.tryParse(surfaceController.text);
                          if (surface == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.invalidSurfaceValue),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final viewModel = Provider.of<LandDetailsViewModel>(
                              context,
                              listen: false);

                          // Create Region object
                          final newRegion = Region(
                            id: "",
                            name: nameController.text,
                            surface: surface,
                            land: land,
                            isConnected: false,
                          );

                          final response =
                              await viewModel.addRegion(newRegion).timeout(
                                    const Duration(seconds: 15),
                                    onTimeout: () {
                                      return ApiResponse.error(l10n.requestTimeout);
                                    },
                                  );

                          if (response.status == Status.COMPLETED) {
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    response.message ?? l10n.failedToAddRegion),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : (isSmallPhone ? 16 : 20), 
                            vertical: isTablet ? 16 : 12
                          ),
                        ),
                        child: Text(
                          l10n.addRegion,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 18 : (isSmallPhone ? 14 : 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}