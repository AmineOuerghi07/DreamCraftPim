// view/screens/reset_password_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String userId;
  const ResetPasswordScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillFields)),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordTooShort)),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordsDoNotMatch)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/account/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId, 
          'newPassword': password,
          'confirmPassword': confirmPassword
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.signUpSuccess)),
        );
        context.go(RouteNames.login);
      } else {
        String errorMessage = l10n.signupFailed;
        try {
          final decodedResponse = json.decode(response.body);
          errorMessage = decodedResponse["message"] ?? errorMessage;
        } catch (_) {
          // Handle error
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.error}: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD3DED5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock, color: Color(0xFF777777)),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF777777),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF777777),
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    
    // Determine if we're on a tablet or phone based on width
    final bool isTablet = screenWidth > 600;
    
    // Responsive sizing
    final double horizontalPadding = screenWidth * 0.05;
    final double maxContentWidth = isTablet ? 500.0 : screenWidth * 0.9;
    
    // Responsive text sizing
    final double titleFontSize = isTablet ? 32.0 : 24.0;
    final double subtitleFontSize = isTablet ? 18.0 : 16.0;
    final double buttonFontSize = isTablet ? 18.0 : 16.0;
    
    // Responsive spacing
    final double topSpacing = screenHeight * 0.08;
    final double widgetSpacing = screenHeight * 0.02;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: topSpacing),
                    Text(
                      l10n.resetPassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF3E754E),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: widgetSpacing),
                    Text(
                      l10n.setNewPassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF777777),
                        fontSize: subtitleFontSize,
                      ),
                    ),
                    SizedBox(height: widgetSpacing * 1.5),
                    _buildPasswordField(
                      controller: _passwordController,
                      hintText: l10n.password,
                      obscureText: _obscurePassword,
                      onToggle: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    SizedBox(height: widgetSpacing),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: l10n.confirmPassword,
                      obscureText: _obscureConfirmPassword,
                      onToggle: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    SizedBox(height: widgetSpacing * 1.5),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3E754E),
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 18.0 : 15.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _resetPassword,
                              child: Text(
                                l10n.save,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: widgetSpacing * 1.2),
                    GestureDetector(
                      onTap: () {
                        context.goNamed(RouteNames.login);
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "${l10n.didYouRemember} ",
                          style: GoogleFonts.roboto(
                            fontSize: isTablet ? 16.0 : 14.0,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF777777),
                          ),
                          children: [
                            TextSpan(
                              text: l10n.signIn,
                              style: GoogleFonts.roboto(
                                fontSize: isTablet ? 16.0 : 14.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF3E754E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 40.0 : 20.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}