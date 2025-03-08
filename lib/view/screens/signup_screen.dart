// view/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:pim_project/routes/routes.dart'; // Import Dio for HTTP requests
import 'package:pim_project/constants/constants.dart';

class SignupScreen extends StatefulWidget {
  
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isChecked = false;
  final Dio dio = Dio(); // Initialize Dio instance for HTTP requests

  // Controllers for the form fields
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
                "Create your new account",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w300, // Light
                  color: const Color(0xB0777777), // 67% opacity
                ),
              ),

              const SizedBox(height: 24),

              // Input Fields
              CustomTextField(controller: fullNameController, label: "Full Name", icon: Icons.person),
              CustomTextField(controller: emailController, label: "Email", icon: Icons.email),
              CustomTextField(controller: passwordController, label: "Password", icon: Icons.lock, isPassword: true),
              CustomTextField(controller: confirmPasswordController, label: "Confirm Password", icon: Icons.lock, isPassword: true),
              CustomTextField(controller: phoneController, label: "Phone Number", icon: Icons.phone),
              CustomTextField(controller: addressController, label: "Address", icon: Icons.home),

              const SizedBox(height: 14),

              // Terms & Policy Checkbox
              Row(
                children: [
                  Theme(
                    data: ThemeData(
                      checkboxTheme: CheckboxThemeData(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Circular Checkbox
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
                  onPressed: signUp,
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
                      context.push(RouteNames.login);                    
                    },
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

  Future<void> signUp() async {
    String fullname = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    // Validate input fields
    if (fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
      return;
    }

    // Validate if password and confirm password match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Validate email format
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email address')),
      );
      return;
    }

    try {
      // Send POST request to the signup endpoint
      final response = await dio.post(
        '${AppConstants.baseUrl}/account/sign-up', // Your IP address here
        data: {
          'fullname': fullname,
          'email': email,
          'password': password,
          'confirmpassword': confirmPassword,
          'phone': phone,
          'address': address,
        },
      );

      // Check the response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Signup successful: ${response.data}');
        
        // You could save user data locally if needed (e.g., in SharedPreferences)
        
        // Navigate to login screen after successful signup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
        context.push(RouteNames.login);  // Redirect to login screen
      } else {
        print('Signup failed: ${response.statusCode}, ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup failed')),
        );
      }
    } catch (e) {
      // Handle error during signup
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

// Custom TextField Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFDAE5DD), // Background color of text fields
          labelText: label,
          labelStyle: GoogleFonts.roboto(
            color: const Color(0xFF777777),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF5E7364)),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFFDAE5DD)),
            borderRadius: BorderRadius.circular(8), // Border radius
          ),
        ),
      ),
    );
  }
}
