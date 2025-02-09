import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Title: Create Account
              Text(
                "Create account",
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w600, // SemiBold
                  color: const Color(0xFF3E754E),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "create your new account",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w300, // Light
                  color: const Color(0xB0777777), // 67% opacity
                ),
              ),

              const SizedBox(height: 24),

              // Input Fields
              CustomTextField(label: "Full Name", icon: Icons.person),
              CustomTextField(label: "Email", icon: Icons.email),
              CustomTextField(
                  label: "Password", icon: Icons.lock, isPassword: true),
              CustomTextField(
                  label: "Confirm Password",
                  icon: Icons.lock,
                  isPassword: true),
              CustomTextField(label: "Phone Number", icon: Icons.phone),
              CustomTextField(label: "Address", icon: Icons.home),

              const SizedBox(height: 14),

              // Terms & Policy Checkbox
              Row(
                children: [
                  Theme(
                    data: ThemeData(
                      checkboxTheme: CheckboxThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Circular Checkbox
                        ),
                      ),
                    ),
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                      activeColor: const Color(0xFF3E754E),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "I understood the ",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF777777),
                      ),
                      children: [
                        TextSpan(
                          text: "terms & policy.",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: const Color(0xFF3E754E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Sign Up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E754E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    "Sign Up",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600, // SemiBold
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Already have an account? Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400, // Regular
                      color: const Color(0xFF909090),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                         context.go(RouteNames.login);                    },
                    child: Text(
                      "Sign in",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF3E754E),
                        fontWeight: FontWeight.w400, // Regular
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16.0), // Plus d’espace entre les champs
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFDAE5DD), // Fond des champs de texte
          labelText: label,
          labelStyle: GoogleFonts.roboto(
            color: const Color(0xFF777777),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF5E7364)),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFFDAE5DD)),
            borderRadius: BorderRadius.circular(8), // Border Radius
          ),
        ),
      ),
    );
  }
}
