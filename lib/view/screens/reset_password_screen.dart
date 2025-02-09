import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pim_project/view/screens/login_screen.dart';
import 'package:pim_project/view/screens/phone_verification_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart'; 

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Removed the input validation logic
  void _resetPassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Simply print the entered password now
    print("Password reset successful: $password");
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Reset Password",
              style: TextStyle(
                color: Color(0xFF3E754E),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Set new password",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            _buildPasswordField(
              controller: _passwordController,
              hintText: "Password",
              obscureText: _obscurePassword,
              onToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),

            const SizedBox(height: 15),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),

            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E754E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
         onPressed: () {
  _resetPassword(); // Exécute la fonction de réinitialisation du mot de passe
  context.push(RouteNames.login); // Navigue directement vers l'écran de connexion
},

              
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Sign In Link
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text.rich(
                TextSpan(
                  text: "Did you remember your password? ",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF777777),
                  ),
                  children: [
                    TextSpan(
                      text: "Sign In",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF3E754E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
