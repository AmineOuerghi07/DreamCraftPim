// view/screens/PhoneNumberScreen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON encoding
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/constants/constants.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String _phoneNumber = ""; // Stocke le numéro saisi

  // Fonction pour envoyer l'OTP
  Future<void> sendOtp(BuildContext context) async {
    final url = Uri.parse('${AppConstants.baseUrl}/account/forgot-password-otp-phone');

    try {
      debugPrint("📡 Sending OTP to: $_phoneNumber");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'phone': _phoneNumber}),
      );

      debugPrint("📥 Response Status Code: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ OTP sent successfully!");
        // Naviguer vers la page de vérification avec le numéro de téléphone
        context.push(RouteNames.phoneVerification, extra: _phoneNumber);
      } else {
        debugPrint("❌ Failed to send OTP: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send OTP')),
        );
      }
    } catch (e) {
      debugPrint("🚨 Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Forget Password",
              style: TextStyle(
                color: Color(0xFF3E754E),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your phone number and we will send you a confirmation code",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            IntlPhoneField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD3DED5),
                hintText: "Phone Number",
                hintStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF777777),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              initialCountryCode: 'TN',
              dropdownIcon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF777777),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              onChanged: (phone) {
                setState(() {
                  _phoneNumber = phone.completeNumber; // Met à jour le numéro
                });
                debugPrint("📞 Phone Number Updated: $_phoneNumber");
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E754E),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                if (_phoneNumber.isNotEmpty) {
                  sendOtp(context); // Envoi l'OTP avec le bon numéro
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a phone number')),
                  );
                }
              },
              child: const Center(
                child: Text(
                  "Send",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
