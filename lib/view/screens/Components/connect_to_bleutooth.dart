import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectToBluetooth extends StatelessWidget {
  const ConnectToBluetooth({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding for text wrapping
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/images/graph_3.png")),
              const SizedBox(height: 12),
              Text(
                l10n.connectDeviceTitle,
                textAlign: TextAlign.center, // Center the text
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.enableBluetoothPermission,
                textAlign: TextAlign.center, // Center the text
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.bluetooth,
                textAlign: TextAlign.center, // Center the text
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 106, 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: Text(
                  l10n.connectDevice,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
