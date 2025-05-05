import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final bool isTablet = screenSize.width > 600;
    
    // Calculate responsive dimensions
    final double horizontalPadding = isTablet 
        ? screenSize.width * 0.08
        : screenSize.width * 0.05;
    
    // Text sizes
    final double titleFontSize = isTablet ? 32 : 28;
    final double subTitleFontSize = isTablet ? 18 : 16;
    final double optionTitleFontSize = isTablet ? 20 : 18;
    final double optionSubtitleFontSize = isTablet ? 16 : 14;
    
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
      required double delay,
    }) {
      return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
              color: const Color(0xFFF2F7F4),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                  padding: EdgeInsets.all(isTablet ? 14 : 12),
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward : Icons.arrow_back,
            color: const Color(0xFF3E754E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                SizedBox(height: verticalSpacing * 2),
                      
                // Title with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                        l10n.forgetPassword,
                        style: GoogleFonts.roboto(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3E754E),
                    ),
                    textAlign: TextAlign.center,
                        ),
                      ),
                
                      SizedBox(height: verticalSpacing * 0.5),
                      
                // Subtitle with animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Text(
                        l10n.selectContact,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: subTitleFontSize,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                  ),
                      ),
                      
                SizedBox(height: verticalSpacing * 3),
                      
                // Options in a card container
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Email option
                      buildOptionContainer(
                        icon: Icons.email_outlined,
                        title: l10n.email,
                        subtitle: l10n.sendToEmail,
                        delay: 0.2,
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
                      
                     
                    ],
                  ),
                      ),
                      
                      SizedBox(height: verticalSpacing * 2),
                      
                      // OR Divider with more styling
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Row(
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
                      ),
                      
                      SizedBox(height: verticalSpacing * 1.5),
                      
                // Sign in link with enhanced styling and animation
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFDAE5DD)),
                      ),
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
                        ),
                      ),
                      
                // Add ornamental elements at the bottom
                      SizedBox(height: verticalSpacing * 2),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenSize.width * 0.2,
                        height: 1,
                        color: const Color(0xFFDAE5DD),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.eco,
                          color: const Color(0xFF3E754E).withOpacity(0.5),
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                      Container(
                        width: screenSize.width * 0.2,
                        height: 1,
                        color: const Color(0xFFDAE5DD),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: verticalSpacing * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}