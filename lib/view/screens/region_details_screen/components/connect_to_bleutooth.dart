// view/screens/components/connect_to_bleutooth.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view/screens/region_details_screen/components/device_discovery_dialog.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectToBluetooth extends StatelessWidget {
  final VoidCallback? onDeviceConnected;
  
  const ConnectToBluetooth({
    this.onDeviceConnected, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final irrigationViewModel = Provider.of<IrrigationViewModel>(context);
    final regionViewModel = Provider.of<RegionDetailsViewModel>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/images/graph_3.png")),
              const SizedBox(height: 12),
              Text(
                l10n.connectIrrigationTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.connectIrrigationDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              
              // Always show the connect button, regardless of connection state
              ElevatedButton(
                onPressed: () {
                  // Force reset of connections first
                  irrigationViewModel.resetDeviceConnection();
                  // Always show the device discovery dialog
                  _showDeviceDiscoveryDialog(context, regionViewModel);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 106, 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: Text(
                  l10n.connectDeviceButton,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDeviceDiscoveryDialog(BuildContext context, RegionDetailsViewModel regionViewModel) {
    final irrigationViewModel = Provider.of<IrrigationViewModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    // Start discovery process
    irrigationViewModel.discoverDevices();
    
    // Show the dialog
    showDialog(
      context: context,
      builder: (context) => DeviceDiscoveryDialog(
        onDeviceSelected: (device) async {
          // Get status when a device is selected
          irrigationViewModel.selectDevice(device.id);
          
          // Update the region's isConnected status to true
          if (regionViewModel.region != null) {
            final updatedRegion = Region(
              id: regionViewModel.region!.id,
              name: regionViewModel.region!.name,
              surface: regionViewModel.region!.surface,
              land: regionViewModel.region!.land,
              sensors: regionViewModel.region!.sensors,
              plants: regionViewModel.region!.plants,
              isConnected: true,
              description: regionViewModel.region!.description, // Set to true when a device is connected
            );
            
            // Update the region in the database and view model
            final response = await regionViewModel.updateRegion(updatedRegion);
            
            if (response.status == Status.COMPLETED) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.deviceConnectedMessage(device.id)),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Call the callback if provided
              if (onDeviceConnected != null) {
                onDeviceConnected!();
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.deviceConnectedUpdateFailedMessage(response.message!)),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.deviceConnectedNoRegionMessage),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      ),
    );
  }
}