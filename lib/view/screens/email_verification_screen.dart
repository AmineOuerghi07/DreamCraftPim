// view/screens/email_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pim_project/view/screens/OTPVerificationScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Custom Wave Clipper for Email Verification Screen
class EmailVerificationWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);

    // First curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.85,
    );

    // Second curve
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.8,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController _emailController = TextEditingController();
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    
    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.shortestSide >= 600;
    final double horizontalPadding = isTablet ? screenSize.width * 0.1 : screenSize.width * 0.08;
    
    // Calculate responsive dimensions
    final double headerHeight = isTablet 
        ? screenSize.height * 0.35 
        : screenSize.height * 0.3;
    
    // Text sizes
    final double titleFontSize = isTablet ? 32.0 : 28.0;
    final double subTitleFontSize = isTablet ? 16.0 : 14.0;
    final double inputFontSize = isTablet ? 18.0 : 16.0;
    final double buttonFontSize = isTablet ? 18.0 : 16.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with curved image
              Stack(
                children: [
                  ClipPath(
                    clipper: EmailVerificationWaveClipper(),
                    child: SizedBox(
                      height: headerHeight,
                      width: double.infinity,
                      child: Image.asset(
                        "assets/images/plantelogin.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 20,
                    left: isRTL ? null : 20,
                    right: isRTL ? 20 : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: isTablet ? 24 : 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              
              // Title
              Text(
                l10n.forgetPassword,
                style: GoogleFonts.roboto(
                  color: const Color(0xFF3E754E),
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              
              // Subtitle
              Text(
                l10n.setEmailHere,
                style: GoogleFonts.roboto(
                  color: const Color(0xFF777777),
                  fontSize: subTitleFontSize,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.03),
              
              // Email input field
              Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.03,
                ),
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                ),
                child: TextField(
                  controller: _emailController,
                  textCapitalization: TextCapitalization.none,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.roboto(
                    fontSize: inputFontSize,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.email,
                      color: const Color(0xFF777777),
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      size: isTablet ? 24 : 20,
                    ),
                    border: InputBorder.none,
                    hintText: l10n.email,
                    hintStyle: GoogleFonts.roboto(
                      fontSize: inputFontSize,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              
              // Submit button
              Container(
                width: double.infinity,
                height: isTablet ? 60 : 50,
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E754E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                  ),
                  onPressed: () async {
                    String email = _emailController.text;

                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.pleaseEnterValidEmailAddress)),
                      );
                      return;
                    }

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3E754E),
                        ),
                      ),
                    );

                    try {
                      // Send request to the backend to check if email exists and send OTP
                      var response = await http.post(
                        Uri.parse('${AppConstants.baseUrl}/account/forgot-password-otp-email'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'email': email}),
                      );

                      // Close loading dialog
                      Navigator.pop(context);

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
                    } catch (e) {
                      // Close loading dialog
                      Navigator.pop(context);
                      
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.anErrorOccurred)),
                      );
                    }
                  },
                  child: Text(
                    l10n.send,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}