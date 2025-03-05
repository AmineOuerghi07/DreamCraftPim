import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart' as cp;

// Custom country data class with coordinates
class CountryWithCoordinates {
  final cp.Country country;
  final LatLng coordinates;

  CountryWithCoordinates({
    required this.country,
    required this.coordinates,
  });
}

// Country data repository
class CountryData {
  static final List<CountryWithCoordinates> countries = [
    CountryWithCoordinates(
      country: cp.Country(
        isoCode: 'US',
        name: 'United States',
        iso3Code: 'USA',
        phoneCode: '+1',
      ),
      coordinates: LatLng(37.0902, -95.7129),
    ),
    CountryWithCoordinates(
      country: cp.Country(
        isoCode: 'FR',
        name: 'France',
        iso3Code: 'FRA',
        phoneCode: '+33',
      ),
      coordinates: LatLng(46.603354, 1.888334),
    ),
    // Add all countries with their coordinates
    // Get full list from: https://developers.google.com/public-data/docs/canonical/countries_csv
  ];

  // Helper method to get country by ISO code
  static CountryWithCoordinates? getCountryByIsoCode(String isoCode) {
    return countries.firstWhere(
      (country) => country.country.isoCode == isoCode,
      orElse: () => countries.first,
    );
  }
}

class OSMFlutterMap extends StatefulWidget {
  const OSMFlutterMap({super.key});

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap>
    with AutomaticKeepAliveClientMixin {
      static const double minZoom = 1.0; // Minimum zoom level to show entire world
  static const double maxZoom = 18.0; // Maximum zoom level for details
  final MapController _mapController = MapController();
  LatLng? selectedLocation;
  CountryWithCoordinates? selectedCountry;
  List<Marker> markers = [];

  @override
  bool get wantKeepAlive => true;

  Future<void> _filterByCountry(CountryWithCoordinates? country) async {
    if (country == null) return;
    
    setState(() {
      selectedCountry = country;
      _mapController.move(country.coordinates, 5);
    });
  }
//**************************************************** */
Future<void> _goToCurrentLocation() async {
  StreamSubscription<Position>? positionStream; 
  try {
    print('Checking location service...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services disabled');
      return _showErrorDialog('Please enable location services');
    }

    print('Checking permissions...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permission denied after request');
        return _showErrorDialog('Location permissions denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission denied forever');
      return _showErrorDialog('Enable permissions in app settings');
    }

    print('Starting location stream...');
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      print('Position update: ${position.latitude}, ${position.longitude}');
      final currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(currentLocation, 15);
      setState(() {
        selectedLocation = currentLocation;
        markers = [
          Marker(
            point: currentLocation,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          )
        ];
      });
      positionStream?.cancel(); // Safe to use now, cancel after first position
    });

    // Timeout the stream after 30 seconds
    await Future.delayed(const Duration(seconds: 30), () {
      positionStream?.cancel();
      if (selectedLocation == null) {
        throw TimeoutException('Location stream timed out');
      }
    });
  } on TimeoutException {
    _showErrorDialog('Location request timed out. Try moving to an open area.');
  } catch (e) {
    print('Error: $e');
    _showErrorDialog('Error: ${e.toString()}');
  } finally {
    // Ensure stream is cancelled if an error occurs
    positionStream?.cancel();
  }
}
//********************************************* */
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        )
      ],
    ),
  );
}

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      selectedLocation = point;
      markers = [
        Marker(
          point: point,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<CountryWithCoordinates>(
              value: selectedCountry,
              hint: const Text("Select Country"),
              isExpanded: true,
              items: CountryData.countries.map((country) {
                return DropdownMenuItem<CountryWithCoordinates>(
                  value: country,
                  child: _buildDropdownItem(country),
                );
              }).toList(),
              onChanged: _filterByCountry,
            ),
          ),
     Expanded(
  child: FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      initialCenter: LatLng(0, 0),
      initialZoom: minZoom,
      onTap: _onMapTap,
      initialRotation: 0,
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.drag |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.doubleTapZoom,
      ),
      // Updated position changed callback
      onPositionChanged: (position, hasGesture) {
        if (position.zoom < minZoom) {
          _mapController.move(position.center, minZoom);
        }
      },
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.app',
        minZoom: minZoom,
        maxZoom: maxZoom,
      ),
      MarkerLayer(markers: markers)
    ],
  ),
),
        ],
      ),
     floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    if (selectedLocation != null) {
      // Get the address based on the selected location
      List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedLocation!.latitude, selectedLocation!.longitude);
      Placemark place = placemarks[0];

      // Return the location text as you did in _getCurrentLocation
      Navigator.pop(
        context,
        "${place.locality}, ${place.country}",
      );
    }
  },
  label: const Text("Confirm"),
  icon: const Icon(Icons.check),
),

    );
  }

  Widget _buildDropdownItem(CountryWithCoordinates country) {
    return Row(
      children: [
        CountryPickerUtils.getDefaultFlagImage(country.country),
        const SizedBox(width: 8),
        Text("${country.country.name} (${country.country.isoCode})"),
      ],
    );
  }
}