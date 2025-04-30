// view/screens/email_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pim_project/view/screens/OTPVerificationScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController _emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    l10n.forgetPassword,
                    style: GoogleFonts.roboto(
                      color: const Color(0xFF3E754E),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.setEmailHere,
                    style: GoogleFonts.roboto(
                      color: const Color(0xFF777777),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: l10n.email,
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF777777),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFD3DED5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 320,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E754E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () async {
                        String email = _emailController.text;

                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.pleaseEnterValidEmailAddress)),
                          );
                          return;
                        }

                        // Send request to the backend to check if email exists and send OTP
                        var response = await http.post(
                          Uri.parse('${AppConstants.baseUrl}/account/forgot-password-otp-email'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({'email': email}),
                        );

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          // OTP sent successfully, show alert and navigate to OTP verification
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.otpSentSuccessfully)),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OTPVerificationScreen(email: email),
                            ),
                          );
                        } else {
                          // Show alert if email not found
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.emailNotFound)),
                          );
                        }
                      },
                      child: Text(
                        l10n.send,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

