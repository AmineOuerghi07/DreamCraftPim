// view/screens/land_details_for_rent_screen.dart
import 'package:flutter/material.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:pim_project/view_model/land_for_rent_view_model.dart';
import 'package:pim_project/view_model/land_request_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LandDetailsForRentScreen extends StatefulWidget {
  final String landId;

  const LandDetailsForRentScreen({
    Key? key,
    required this.landId,
  }) : super(key: key);

  @override
  State<LandDetailsForRentScreen> createState() =>
      _LandDetailsForRentScreenState();
}

class _LandDetailsForRentScreenState extends State<LandDetailsForRentScreen> {
  bool _isLoading = true;
  Land? _land;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLandDetails();
  }

  Future<void> _fetchLandDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final viewModel =
          Provider.of<LandForRentViewModel>(context, listen: false);
      final landRequestViewModel =
          Provider.of<LandForRentViewModel>(context, listen: false);

      // If we already have lands in the view model, try to find this one
      if (viewModel.landsForRent.isNotEmpty) {
        try {
          _land = viewModel.landsForRent.firstWhere(
            (land) => land.id == widget.landId,
          );
          setState(() {
            _isLoading = false;
          });
          return;
        } catch (e) {
          // Land not found in local list, continue to fetch
          print('Land not found in local list, fetching from server');
        }
      }

      // Fetch explicitly from server
      await viewModel.fetchLandDetails(widget.landId);
      _land = viewModel.selectedLand;

      if (_land == null) {
        throw Exception('Failed to load land details');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching land details: $_errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_land == null) return;

    final l10n = AppLocalizations.of(context)!;
    final landRequestViewModel =
        Provider.of<LandRequestViewModel>(context, listen: false);
    // Show a confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmRequest),
        content: Text(l10n.confirmRequestLandRental),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => {
              landRequestViewModel.addLandRequest(_land!.id),
              Navigator.of(context).pop(true)
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Get the phone number from the land
      final phoneNumber = _land!.getPhoneNumber();

      // Only attempt to launch if phone number is available
      /*if (phoneNumber.isNotEmpty) {
        final Uri phoneUri = Uri(
          scheme: 'tel',
          path: phoneNumber,
        );

        try {
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            _showErrorSnackBar(l10n.anErrorOccurred);
          }
        } catch (e) {
          _showErrorSnackBar('${l10n.anErrorOccurred}: $e');
        }
      } else {
        _showErrorSnackBar(l10n.contactNotAvailable);
      }*/
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.landDetails),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: AppProgressIndicator(
                loadingText: 'Growing data...',
                primaryColor: const Color(0xFF4CAF50), // Green
                secondaryColor: const Color(0xFF8BC34A), // Light Green
                size: 75, // Controls the overall size
              ),
            )
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(context, isTablet),
    );
  }

  Widget _buildContent(BuildContext context, bool isTablet) {
    if (_land == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.noLandDataAvailable),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchLandDetails,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    //  final size = MediaQuery.of(context).size;

    // Get owner information
    final phoneNumber = _land!.getPhoneNumber();
    final ownerName = _land!.owner?.fullname ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Land Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _land!.image.isNotEmpty
                    ? AppConstants.imagesbaseURL + _land!.image
                    : 'assets/images/placeholder.png',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child:
                          Icon(Icons.error, size: 48, color: Colors.grey[700]),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: isTablet ? 24 : 16),

          // Land Name and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _land!.name,
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12, vertical: isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_land!.rentPrice.toStringAsFixed(2)} DT/month',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _land!.cordonate,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          Divider(height: isTablet ? 40 : 32),

          // Details Section
          Text(
            l10n.details,
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Surface
          _buildDetailRow(
            context,
            Icons.straighten,
            l10n.surface,
            '${_land!.surface.toStringAsFixed(0)} m²',
            isTablet,
          ),

          SizedBox(height: isTablet ? 12 : 8),

          // Owner name if available
          if (ownerName.isNotEmpty) ...[
            _buildDetailRow(
              context,
              Icons.person,
              l10n.name,
              ownerName,
              isTablet,
            ),
            SizedBox(height: isTablet ? 12 : 8),
          ],

          // Owner Contact
          _buildDetailRow(
            context,
            Icons.phone,
            l10n.ownerContact,
            phoneNumber.isEmpty ? l10n.contactNotAvailable : phoneNumber,
            isTablet,
          ),

          if (_land!.regions.isNotEmpty) ...[
            SizedBox(height: isTablet ? 12 : 8),
            _buildDetailRow(
              context,
              Icons.grid_view,
              l10n.regions,
              '${_land!.regions.length}',
              isTablet,
            ),
          ],

          Divider(height: isTablet ? 40 : 32),

          // Description Section (if available)
          Text(
            l10n.description,
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Since description might not exist on the Land model, show a placeholder
          Text(
            l10n.noDescriptionAvailable,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: isTablet ? 32 : 24),

          // Request Button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton(
              onPressed: _sendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.sendRequest,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label,
      String value, bool isTablet) {
    return Row(
      children: [
        Icon(icon, size: isTablet ? 24 : 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
