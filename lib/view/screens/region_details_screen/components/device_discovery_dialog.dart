// view/screens/components/device_discovery_dialog.dart
import 'package:flutter/material.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/irrigation_device.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeviceDiscoveryDialog extends StatefulWidget {
  final Function(IrrigationDevice) onDeviceSelected;

  const DeviceDiscoveryDialog({
    Key? key,
    required this.onDeviceSelected,
  }) : super(key: key);

  @override
  State<DeviceDiscoveryDialog> createState() => _DeviceDiscoveryDialogState();
}

class _DeviceDiscoveryDialogState extends State<DeviceDiscoveryDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _ipAddressController = TextEditingController();
  bool _isManualEntry = false;
  late TabController _tabController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isManualEntry = _tabController.index == 1;
      });
    });
    
    // Start device discovery when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final irrigationViewModel = Provider.of<IrrigationViewModel>(context, listen: false);
      _startDiscovery(irrigationViewModel);
    });
  }

  void _startDiscovery(IrrigationViewModel viewModel) {
    setState(() => _isSearching = true);
    viewModel.discoverDevices().then((_) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    });
  }

  @override
  void dispose() {
    _ipAddressController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final l10n = AppLocalizations.of(context)!;
    final irrigationViewModel = Provider.of<IrrigationViewModel>(context);
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : size.width * 0.9,
          maxHeight: size.height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wifi_tethering, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.deviceDiscoveryTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tabs for navigation between discovery and manual entry
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: UnderlineTabIndicator(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                  ),
                  labelColor: Colors.black,
                  // Add these properties to remove the focus/tap effect
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  indicatorColor: Colors.transparent,
                  // Rest of your TabBar properties remain the same
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.radar),
                      text: l10n.discoverTab,
                    ),
                    Tab(
                      icon: const Icon(Icons.edit),
                      text: l10n.manualEntryTab,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Auto Discovery Tab
                    _buildDiscoveryContent(irrigationViewModel, l10n),
                    
                    // Manual Entry Tab
                    _buildManualEntryContent(irrigationViewModel, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryContent(IrrigationViewModel viewModel, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.availableDevices,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.green.shade900,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isSearching ? null : () => _startDiscovery(viewModel),
              icon: _isSearching 
                  ? const SizedBox(
                      width: 0, 
                      height: 0, 
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(_isSearching ? l10n.scanningText : l10n.scanButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Expanded(
          child: viewModel.isLoading && !_isSearching
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : viewModel.discoveredDevices.isEmpty
                  ? _buildEmptyState(l10n)
                  : _buildDevicesList(viewModel, l10n),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDevicesFound,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noDevicesMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(IrrigationViewModel viewModel, AppLocalizations l10n) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: viewModel.discoveredDevices.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        final device = viewModel.discoveredDevices[index];
        return _buildDeviceCard(device, l10n);
      },
    );
  }

  Widget _buildDeviceCard(IrrigationDevice device, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: device.isConnected ? Colors.green.shade50 : null,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: device.isConnected ? Colors.green.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pop();
          widget.onDeviceSelected(device);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.router,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.devicePrefix} ${device.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.ipAddressPrefix} ${device.ipAddress}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (device.isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        l10n.connectedStatus,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntryContent(IrrigationViewModel viewModel, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.enterDeviceIpTitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.enterDeviceIpSubtitle,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ipAddressController,
          decoration: InputDecoration(
            hintText: l10n.ipAddressHint,
            prefixIcon: Icon(Icons.lan, color: Colors.green.shade700),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade700, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final ipAddress = _ipAddressController.text.trim();
              if (ipAddress.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.invalidIpError)),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              // Find device by IP
              await viewModel.selectDeviceByIp(ipAddress);
              if (viewModel.selectedDevice != null) {
                widget.onDeviceSelected(viewModel.selectedDevice!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to connect to device')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(200, 48),
            ),
            child: Text(
              l10n.connectButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}