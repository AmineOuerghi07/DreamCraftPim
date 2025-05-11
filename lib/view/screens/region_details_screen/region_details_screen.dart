import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/region_details_screen/components/connect_to_bleutooth.dart';
import 'package:pim_project/view/screens/region_details_screen/components/region_detail_text.dart';
import 'package:pim_project/view/screens/region_details_screen/components/region_info.dart';
import 'package:pim_project/view/screens/region_details_screen/components/smart_regionsGrid.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';
import 'package:pim_project/view_model/region_details_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegionDetailsScreen extends StatefulWidget {
  final String id;
  final LandDetailsViewModel? landDetailsViewModel;
  const RegionDetailsScreen({required this.id, this.landDetailsViewModel, super.key});

  @override
  State<RegionDetailsScreen> createState() => _RegionDetailsScreenState();
}

class _RegionDetailsScreenState extends State<RegionDetailsScreen> with WidgetsBindingObserver {
  // This flag will override the database isConnected status
  bool _isDeviceVerified = false;
  // Add loading state to prevent UI flashing during connection
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous connections and reset state
    _resetConnectionState();
    
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Load data initially
    _loadRegionData();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This can catch some navigation events when returning to the screen
    _loadRegionData();
  }
  
  @override
  void dispose() {
    // Remove the observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // If app comes to the foreground, refresh data
    if (state == AppLifecycleState.resumed) {
      _loadRegionData();
    }
  }
  
  // Method to load region data
  void _loadRegionData() {
    final viewModel = Provider.of<RegionDetailsViewModel>(context, listen: false);
    
    // Reset local connection state if needed
    if (viewModel.region?.isConnected == false) {
      _resetConnectionState();
    }
    
    // Always refresh data when this method is called
    viewModel.getRegionById(widget.id);
    
    // If we have a land ID, also refresh land data
    if (viewModel.region?.land.id != null) {
      final landVM = widget.landDetailsViewModel ?? 
          Provider.of<LandDetailsViewModel>(context, listen: false);
          
      landVM.fetchRegionsForLand(viewModel.region!.land.id);
      landVM.fetchPlantsForLand(viewModel.region!.land.id);
    }
  }

  // Completely reset the connection state
  void _resetConnectionState() {
    // Reset local connection state
    setState(() {
      _isDeviceVerified = false;
      _isConnecting = false;
    });
    
    // Schedule a microtask to reset the IrrigationViewModel
    // This is done after the build to avoid errors during widget initialization
    Future.microtask(() {
      if (!mounted) return;
      final irrigationViewModel = Provider.of<IrrigationViewModel>(context, listen: false);
      
      // Clear any existing selected device
      irrigationViewModel.resetDeviceConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width to determine if it's a phone or tablet
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isTablet = screenWidth > 600; // Common breakpoint for tablet layouts
    final l10n = AppLocalizations.of(context)!;

    final viewModel = Provider.of<RegionDetailsViewModel>(context, listen: false);
    final landVM = widget.landDetailsViewModel ?? context.read<LandDetailsViewModel>();
    
    // This ensures initial data load if needed
    if (viewModel.region == null || viewModel.region!.id != widget.id) {
      Future.microtask(() {
        viewModel.getRegionById(widget.id);
      });
    }

    return Consumer<RegionDetailsViewModel>(
      builder: (contextRegionDetailsViewModel, viewModel, child) {
        final regionResponse = viewModel.regionResponse;

        if (regionResponse?.status == Status.LOADING || regionResponse == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (regionResponse.status == Status.ERROR) {
          return Scaffold(body: Center(child: Text(regionResponse.message!)));
        }

        final region = viewModel.region!;
        
        return PopScope(
          // Add this to refresh data when returning via system back button
          onPopInvoked: (didPop) {
            if (didPop) return;
            _loadRegionData();
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Refresh the land details before popping
                  if (region.land.id.isNotEmpty) {
                    landVM.fetchRegionsForLand(region.land.id);
                    landVM.fetchPlantsForLand(region.land.id);
                  }
                  context.pop();
                },
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onSelected: (value) => _handleMenuSelection(value, context, viewModel),
                  itemBuilder: (BuildContext context) => [
                     PopupMenuItem<String>(
                      value: 'update',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text(l10n.updateRegion),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                     PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text(l10n.deleteRegion),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            body: Container(
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Pull-to-refresh functionality
                    _loadRegionData();
                    // Need to return a Future that completes when the refresh is done
                    await Future.delayed(Duration(milliseconds: 500));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24.0 : 16.0,
                      vertical: 8.0,
                    ),
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Responsive RegionInfo widget with adaptive layout
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return RegionInfo(
                              regionCount: region.plants.length.toString(),
                              cultivationType: region.name,
                              location: viewModel.land?.cordonate ?? "Loading...",
                              onAddRegion: () => _navigateToAddPlantScreen(
                                contextRegionDetailsViewModel,
                                region,
                                viewModel,
                                landVM,
                              ),
                              buttonText: l10n.addPlant,
                              showRegionCount: false,
                              onAddSensors: () => _showAddSensorsDialog(context, region, viewModel),
                            );
                          },
                        ),
                        
                        // Information section without scroll
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: RegionInformationSection(
                            description: region.description?.isNotEmpty == true
                              ? region.description!
                              : "No description available",),
                        ),
                        
                        // Conditional content based on verified device connection
                        Expanded(
                          child: _isDeviceVerified
                            ? const SmartRegionsGrid()
                            : _isConnecting 
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Color(0xFF204D4F)),
                                      SizedBox(height: 16),
                                      Text(
                                        "Connecting to device...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF204D4F),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ConnectToBluetooth(
                                  onDeviceConnected: () {
                                    // Set connecting state first to avoid flashing content
                                    setState(() {
                                      _isConnecting = true;
                                    });
                                    
                                    // Use a slight delay to ensure smooth transition
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      if (mounted) {
                                        setState(() {
                                          _isDeviceVerified = true;
                                          _isConnecting = false;
                                          
                                          // Also update the region.isConnected in the database
                                          if (viewModel.region != null) {
                                            final updatedRegion = Region(
                                              id: viewModel.region!.id,
                                              name: viewModel.region!.name,
                                              surface: viewModel.region!.surface,
                                              land: viewModel.region!.land,
                                              sensors: viewModel.region!.sensors,
                                              plants: viewModel.region!.plants,
                                              description: viewModel.region!.description,
                                              isConnected: true,
                                            );
                                            viewModel.updateRegion(updatedRegion);
                                          }
                                        });
                                      }
                                    });
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String value, BuildContext context, RegionDetailsViewModel viewModel) {
    switch (value) {
      case 'update':
        if (viewModel.region != null) _showUpdateRegionDialog(context, viewModel);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, viewModel);
        break;
    }
  }

  void _navigateToAddPlantScreen(
    BuildContext context,
    Region region,
    RegionDetailsViewModel regionVM,
    LandDetailsViewModel landVM,
  ) {
    context.push('${RouteNames.addplantScreen}/${region.id}').then((result) async {
      if (result != null && result is Map<String, int>) {
        await regionVM.addSelectedPlantsToRegion(region.id, selectedPlants: result);
        print('Navigation ViewModel instance: $landVM, hash: ${landVM.hashCode}');
        
        await landVM.fetchPlantsForLand(region.land.id);
        
        // Also refresh the region data to reflect new plants
        await regionVM.getRegionById(region.id);
        
        print('Fetch completed for landId: ${region.land.id}, quantity: ${landVM.plants.isNotEmpty ? landVM.plants.first.totalQuantity : "none"}');
      }
    });
  }

  void _showUpdateRegionDialog(BuildContext context, RegionDetailsViewModel viewModel) {
    final region = viewModel.region!;
    TextEditingController nameController = TextEditingController(text: region.name);
    TextEditingController surfaceController = TextEditingController(text: region.surface.toString());
    bool isLoading = false;
    final l10n = AppLocalizations.of(context)!;

    // Get screen size for responsive dialog
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.updateRegion),
              content: Container(
                width: isSmallScreen ? screenSize.width * 0.85 : screenSize.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.regionName,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: surfaceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.surfaceArea,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (nameController.text.isEmpty || surfaceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.pleaseFillFields), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          final surface = double.tryParse(surfaceController.text);
                          if (surface == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.invalidSurfaceValue), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          final updatedRegion = Region(
                            id: region.id,
                            name: nameController.text,
                            surface: surface,
                            land: region.land,
                            sensors: region.sensors,
                            plants: region.plants,
                            isConnected: region.isConnected, description: region.description,
                          );
                          print('Sending update payload: ${updatedRegion.toJson()}');
                          final response = await viewModel.updateRegion(updatedRegion);

                          setState(() => isLoading = false);

                          if (response.status == Status.COMPLETED) {
                            Navigator.of(dialogContext).pop();
                            
                            // Refresh data after update
                            viewModel.getRegionById(region.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message ?? l10n.updateFailed), backgroundColor: Colors.red),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

 void _showDeleteConfirmationDialog(BuildContext context, RegionDetailsViewModel viewModel) {
  final isSmallScreen = MediaQuery.of(context).size.width < 600;
  final l10n = AppLocalizations.of(context)!;
  final landId = viewModel.region?.land.id;
  final landViewModel = widget.landDetailsViewModel ?? Provider.of<LandDetailsViewModel>(context, listen: false);
  
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(l10n.confirmDelete),
      content: Text(l10n.confirmDeleteMessage),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20.0 : 40.0,
        vertical: 24.0,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            final response = await viewModel.deleteRegion(viewModel.region!.id);
            Navigator.of(context).pop();
            
            if (response.status == Status.COMPLETED && context.mounted) {
              // Important: Refresh the land details data before navigation
              if (landId != null) {
                // Refresh regions for the parent land
                landViewModel.fetchRegionsForLand(landId);
                // Also refresh plants if needed
                landViewModel.fetchPlantsForLand(landId);
              }
              
              // Navigate back to land details
              context.go("${RouteNames.landDetails}/$landId");
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response.message ?? l10n.deleteFailed), backgroundColor: Colors.red),
              );
            }
          },
          child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  void _showAddSensorsDialog(BuildContext context, Region region, RegionDetailsViewModel viewModel) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSensors),
        content: Text(l10n.featureComingSoon),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 20.0 : 40.0,
          vertical: 24.0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}