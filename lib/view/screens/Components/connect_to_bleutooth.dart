// view/screens/components/connect_to_bleutooth.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view/screens/components/device_discovery_dialog.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    
    // Always ensure we have no previous connection showing
    final shouldShowConnectionInfo = irrigationViewModel.selectedDevice != null && 
                                     regionViewModel.region != null &&
                                     regionViewModel.region!.isConnected;

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
              const Text(
                "Want to connect Your Irrigation System?",
                textAlign: TextAlign.center,
                style: TextStyle(

                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Discover and connect to available irrigation devices",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              
              // Show connected device info ONLY when the device is connected to THIS region
              if (shouldShowConnectionInfo) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Connected to Device ${irrigationViewModel.selectedDevice!.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "IP: ${irrigationViewModel.selectedDevice!.ipAddress}",
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Mode: ${irrigationViewModel.isAutomaticMode ? 'Automatic' : 'Manual'}",
                            style: TextStyle(
                              color: irrigationViewModel.isAutomaticMode 
                                ? Colors.blue 
                                : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Pump: ${irrigationViewModel.isPumpOn ? 'On' : 'Off'}",
                            style: TextStyle(
                              color: irrigationViewModel.isPumpOn 
                                ? Colors.green 
                                : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Force reset of connections first
                    irrigationViewModel.resetDeviceConnection();
                    _showDeviceDiscoveryDialog(context, regionViewModel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text(
                    "Change Device",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ] else ...[
                // Connection button if no device is connected
                ElevatedButton(
                  onPressed: () {
                    // Force reset of connections first
                    irrigationViewModel.resetDeviceConnection();
                    _showDeviceDiscoveryDialog(context, regionViewModel);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 23, 106, 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text(
                    "Connect Your Device",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),

                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDeviceDiscoveryDialog(BuildContext context, RegionDetailsViewModel regionViewModel) {
    final irrigationViewModel = Provider.of<IrrigationViewModel>(context, listen: false);
    
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
              isConnected: true, // Set to true when a device is connected
            );
            
            // Update the region in the database and view model
            final response = await regionViewModel.updateRegion(updatedRegion);
            
            if (response.status == Status.COMPLETED) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Connected to device ${device.id}'),
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
                  content: Text('Connected to device but failed to update region status: ${response.message}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connected to device but region information is missing'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      ),
    );
  }
}
