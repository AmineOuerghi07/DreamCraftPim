import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/land_request.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/view_model/land_request_view_model.dart';
import 'package:provider/provider.dart';

class LandRequestScreen extends StatefulWidget {
  const LandRequestScreen({Key? key}) : super(key: key);

  @override
  State<LandRequestScreen> createState() => _LandRequestScreenState();
}

class _LandRequestScreenState extends State<LandRequestScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<LandRequestViewModel>(context, listen: false)
          .fetchLandRequests(MyApp.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LandRequestViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Requests',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: viewModel.landRequests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(
                  request: viewModel.landRequests[index],
                  onAccept: () => _acceptRequest(viewModel.landRequests[index]),
                  onDecline: () =>
                      _rejectRequest(viewModel.landRequests[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  _acceptRequest(LandRequest request) async {
    // Handle accept request logic
    final response =
        await Provider.of<LandRequestViewModel>(context, listen: false)
            .acceptLandRequest(request.requestId);
    if (response.status == Status.COMPLETED) {
      // Show success message
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted successfully')),
        );
        await Provider.of<LandRequestViewModel>(context, listen: false)
            .fetchLandRequests(MyApp.userId);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.message}')),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.message}')),
      );
    }
  }

  _rejectRequest(LandRequest request) async {
    // Handle reject request logic
    final response =
        await Provider.of<LandRequestViewModel>(context, listen: false)
            .rejectLandRequest(request.requestId);

    if (response.status == Status.COMPLETED) {
      // Show success message
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected successfully')),
        );
        await Provider.of<LandRequestViewModel>(context, listen: false)
            .fetchLandRequests(MyApp.userId);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.message}')),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.message}')),
      );
    }
  }

  Widget _buildRequestCard({
    required LandRequest request,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            request.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: [
                            const TextSpan(
                              text: 'Requested to rent ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextSpan(
                              text: request.landName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            request.landLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '1 Year',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.monetization_on_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${request.price} DT/month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onDecline,
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
