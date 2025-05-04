import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pim_project/view/screens/PhoneNumberScreen.dart';
import 'package:pim_project/view/screens/email_verification_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.shortestSide >= 600;
    
    // Calculate responsive dimensions - match login screen header height
    final double headerHeight = isTablet 
        ? screenSize.height * 0.35 
        : screenSize.height * 0.3;
    final double horizontalPadding = isTablet 
        ? screenSize.width * 0.1
        : screenSize.width * 0.08;
    
    // Text sizes
    final double titleFontSize = isTablet ? 32.0 : 28.0;
    final double subTitleFontSize = isTablet ? 16.0 : 14.0;
    final double optionTitleFontSize = isTablet ? 18.0 : 16.0;
    final double optionSubtitleFontSize = isTablet ? 16.0 : 14.0;
    
    // Responsive spacing
    final double verticalSpacing = screenSize.height * 0.02;
    final double containerPadding = isTablet ? 20.0 : 15.0;
    final double iconSize = isTablet ? 30.0 : 24.0;

    // Option container widget with enhanced styling
    Widget buildOptionContainer({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            color: const Color(0xFFDAE5DD),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E754E).withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3E754E).withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF3E754E), size: iconSize),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: optionTitleFontSize, 
                        color: const Color(0xFF3E754E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: optionSubtitleFontSize, 
                        color: const Color(0xFF777777),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                color: const Color(0xFF3E754E),
                size: isTablet ? 20 : 16,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header with curved image - identical to login screen
            Stack(
              children: [
                ClipPath(
                  clipper: ResponsiveWaveClipper(),
                  child: SizedBox(
                    height: headerHeight,
                    width: double.infinity,
                    child: Image.asset(
                      "assets/images/plantelogin.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    toolbarHeight: isTablet ? 70 : 56,
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: verticalSpacing),
                      
                      // Title and subtitle
                      Text(
                        l10n.forgetPassword,
                        style: GoogleFonts.roboto(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3E754E),
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                      
                      Text(
                        l10n.selectContact,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: subTitleFontSize,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      
                      SizedBox(height: verticalSpacing * 2),
                      
                      // Email option
                      buildOptionContainer(
                        icon: Icons.email_outlined,
                        title: l10n.email,
                        subtitle: l10n.sendToEmail,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailVerificationScreen(),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: verticalSpacing),
                      
                      // Phone option
                      buildOptionContainer(
                        icon: Icons.phone_android,
                        title: l10n.phoneNumber,
                        subtitle: l10n.sendToPhone,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhoneNumberScreen(),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: verticalSpacing * 2),
                      
                      // OR Divider with more styling
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDAE5DD),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "ou",
                              style: GoogleFonts.roboto(
                                fontSize: subTitleFontSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF777777),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDAE5DD),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: verticalSpacing * 1.5),
                      
                      // Sign in link with enhanced styling
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text.rich(
                          TextSpan(
                            text: l10n.didYouRemember,
                            style: GoogleFonts.roboto(
                              fontSize: isTablet ? 16.0 : 14.0,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF777777),
                            ),
                            children: [
                              TextSpan(
                                text: " ${l10n.signIn}",
                                style: GoogleFonts.roboto(
                                  fontSize: isTablet ? 16.0 : 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3E754E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: verticalSpacing * 2),
                    ],
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

// Responsive Wave Clipper - same as in LoginScreen for consistency
class ResponsiveWaveClipper extends CustomClipper<Path> {
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