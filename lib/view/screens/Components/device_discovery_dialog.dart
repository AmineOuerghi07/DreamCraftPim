// view/screens/components/device_discovery_dialog.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/irrigation_device.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:provider/provider.dart';

class DeviceDiscoveryDialog extends StatefulWidget {
  final Function(IrrigationDevice) onDeviceSelected;

  const DeviceDiscoveryDialog({
    Key? key,
    required this.onDeviceSelected,
  }) : super(key: key);

  @override
  State<DeviceDiscoveryDialog> createState() => _DeviceDiscoveryDialogState();
}

class _DeviceDiscoveryDialogState extends State<DeviceDiscoveryDialog> {
  final TextEditingController _ipAddressController = TextEditingController();
  bool _isManualEntry = false;

  @override
  void dispose() {
    _ipAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final irrigationViewModel = Provider.of<IrrigationViewModel>(context);

    return AlertDialog(
      title: const Text('Connect to Irrigation Device'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isManualEntry) ...[
              const Text('Available Devices:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Show discovered devices or loading indicator
              if (irrigationViewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (irrigationViewModel.discoveredDevices.isEmpty)
                const Center(child: Text('No devices found'))
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: irrigationViewModel.discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = irrigationViewModel.discoveredDevices[index];
                      return ListTile(
                        title: Text('Device ${device.id}'),
                        subtitle: Text('IP: ${device.ipAddress}'),
                        trailing: device.isConnected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onDeviceSelected(device);
                        },
                      );
                    },
                  ),
                ),
            ] else ...[
              // Manual IP address entry
              const Text('Enter Device IP:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _ipAddressController,
                decoration: const InputDecoration(
                  hintText: 'e.g. 192.168.1.100',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
            const SizedBox(height: 16),
            // Toggle between auto discovery and manual entry
            TextButton(
              onPressed: () {
                setState(() {
                  _isManualEntry = !_isManualEntry;
                });
              },
              child: Text(_isManualEntry
                  ? 'Show Discovered Devices'
                  : 'Enter IP Address Manually'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        if (!_isManualEntry)
          ElevatedButton(
            onPressed: () {
              irrigationViewModel.discoverDevices();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text('Refresh'),
          ),
        if (_isManualEntry)
          ElevatedButton(
            onPressed: () async {
              final ipAddress = _ipAddressController.text.trim();
              if (ipAddress.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid IP address')),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              // Find device by IP
              await irrigationViewModel.selectDeviceByIp(ipAddress);
              if (irrigationViewModel.selectedDevice != null) {
                widget.onDeviceSelected(irrigationViewModel.selectedDevice!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(irrigationViewModel.errorMessage ?? 'Failed to connect to device')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text('Connect'),
          ),
      ],
    );
  }
} 