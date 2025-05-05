import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/constants/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isChecked = false;
  final Dio dio = Dio();
  bool isLoading = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    final bool isRTL = Localizations.localeOf(context).languageCode == 'ar';
    
    // Calculate responsive dimensions similar to login screen
    final double headerHeight = isTablet 
        ? screenSize.height * 0.3 
        : screenSize.height * 0.25;
    final double horizontalPadding = isTablet 
        ? screenSize.width * 0.08
        : screenSize.width * 0.05;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with curved image like login screen
                  Stack(
                    children: [
                      ClipPath(
                        clipper: ResponsiveWaveClipper(),
                        child: Container(
                          height: headerHeight,
                          width: double.infinity,
                          child: Image.asset(
                            "assets/images/plantelogin.png", // Reusing the same image as login
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Optional: Add a floating back button
                      Positioned(
                        top: isTablet ? 20 : 16,
                        left: isRTL ? null : 16,
                        right: isRTL ? 16 : null,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRTL ? Icons.arrow_forward : Icons.arrow_back,
                              color: const Color(0xFF3E754E),
                              size: isTablet ? 24 : 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenSize.height * 0.02),
                  
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
                      l10n.createAccount,
                      style: GoogleFonts.roboto(
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3E754E),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.01),
                  
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
                      l10n.createNewAccount,
                      style: GoogleFonts.roboto(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xB0777777),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.03),
                  
                  // Form Container with card-like styling
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                        // If tablet, use two-column layout for form fields
                        if (isTablet) 
                          _buildTabletForm(l10n)
                        else
                          _buildPhoneForm(l10n),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.02),
                  
                  // Terms and conditions row
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          child: Checkbox(
                            value: isChecked,
                            onChanged: (value) => setState(() => isChecked = value!),
                            activeColor: const Color(0xFF3E754E),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: l10n.understoodTerms,
                              style: GoogleFonts.roboto(
                                fontSize: isTablet ? 16 : 14, 
                                color: const Color(0xFF777777)
                              ),
                              children: [
                                TextSpan(
                                  text: l10n.termsPolicy,
                                  style: GoogleFonts.roboto(
                                    fontSize: isTablet ? 16 : 14,
                                    color: const Color(0xFF3E754E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.025),
                  
                  // Sign up button with animation
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: isTablet ? 60 : 50,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E754E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                           l10n.signUp,
                          style: GoogleFonts.roboto(
                            fontSize: isTablet ? 20 : 18, 
                            fontWeight: FontWeight.w600, 
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.02),
                  
                  // Already have account link
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: GoogleFonts.roboto(
                            fontSize: isTablet ? 16 : 14, 
                            fontWeight: FontWeight.w400, 
                            color: const Color(0xFF909090)
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.login),
                          child: Text(
                            l10n.signIn,
                            style: GoogleFonts.roboto(
                              fontSize: isTablet ? 16 : 14,
                              color: const Color(0xFF3E754E),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Add ornamental elements at the bottom
                  SizedBox(height: screenSize.height * 0.04),
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
                  SizedBox(height: screenSize.height * 0.03),
                ],
              ),
            ),
            // Loading indicator overlay
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3E754E)),
                    strokeWidth: isTablet ? 4.0 : 3.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Two-column layout for tablets
  Widget _buildTabletForm(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: fullNameController, 
                label: l10n.fullName, 
                icon: Icons.person,
                bgColor: const Color(0xFFF2F7F4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: emailController, 
                label: l10n.email, 
                icon: Icons.email,
                bgColor: const Color(0xFFF2F7F4),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: passwordController, 
                label: l10n.password, 
                icon: Icons.lock, 
                isPassword: true,
                bgColor: const Color(0xFFF2F7F4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: confirmPasswordController, 
                label: l10n.confirmPassword, 
                icon: Icons.lock, 
                isPassword: true,
                bgColor: const Color(0xFFF2F7F4),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: phoneController, 
                label: l10n.phoneNumber, 
                icon: Icons.phone,
                bgColor: const Color(0xFFF2F7F4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: addressController, 
                label: l10n.address, 
                icon: Icons.home,
                bgColor: const Color(0xFFF2F7F4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Single-column layout for phones with animation
  Widget _buildPhoneForm(AppLocalizations l10n) {
    return Column(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CustomTextField(
            controller: fullNameController, 
            label: l10n.fullName, 
            icon: Icons.person,
            bgColor: const Color(0xFFF2F7F4),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CustomTextField(
            controller: emailController, 
            label: l10n.email, 
            icon: Icons.email,
            bgColor: const Color(0xFFF2F7F4),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CustomTextField(
            controller: passwordController, 
            label: l10n.password, 
            icon: Icons.lock, 
            isPassword: true,
            bgColor: const Color(0xFFF2F7F4),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CustomTextField(
            controller: confirmPasswordController, 
            label: l10n.confirmPassword, 
            icon: Icons.lock, 
            isPassword: true,
            bgColor: const Color(0xFFF2F7F4),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CustomTextField(
            controller: phoneController, 
            label: l10n.phoneNumber, 
            icon: Icons.phone,
            bgColor: const Color(0xFFF2F7F4),
          ),
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: CustomTextField(
            controller: addressController, 
            label: l10n.address, 
            icon: Icons.home,
            bgColor: const Color(0xFFF2F7F4),
          ),
        ),
      ],
    );
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
    });
    
    final l10n = AppLocalizations.of(context)!;
    String fullname = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    if ([fullname, email, password, confirmPassword, phone, address].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillFields),
          backgroundColor: Colors.red,
        )
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordsDoNotMatch),
          backgroundColor: Colors.red,
        )
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidEmail),
          backgroundColor: Colors.red,
        )
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/account/sign-up',
        data: {
          'fullname': fullname,
          'email': email,
          'password': password,
          'confirmpassword': confirmPassword,
          'phonenumber': phone,
          'address': address,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.signUpSuccess),
              backgroundColor: const Color(0xFF3E754E),
            )
          );
          // Short delay to show success message before navigation
          Future.delayed(const Duration(seconds: 1), () {
            context.push(RouteNames.login);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.signupFailed),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.error}: $e"),
            backgroundColor: Colors.red,
          )
        );
      }
    }
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

// Enhanced Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final Color bgColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.bgColor = const Color(0xFFDAE5DD),
  });

  @override
  Widget build(BuildContext context) {
    // Adjust based on screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: const Color(0xFF444444),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: bgColor,
          labelText: label,
          labelStyle: GoogleFonts.roboto(
            color: const Color(0xFF777777),
            fontSize: isTablet ? 16 : 14,
          ),
          prefixIcon: Icon(
            icon, 
            color: const Color(0xFF3E754E),
            size: isTablet ? 24 : 20,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 12,
            horizontal: isTablet ? 16 : 12,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF3E754E), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Responsive Wave Clipper (the same as in the login screen)
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