import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isChecked = false;
  final Dio dio = Dio();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text(l10n.createAccount,
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E754E),
                )),
            const SizedBox(height: 8),
            Text( l10n.createNewAccount,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xB0777777),
                )),
            const SizedBox(height: 24),
            CustomTextField(controller: fullNameController, label: l10n.fullName, icon: Icons.person),
            CustomTextField(controller: emailController, label: l10n.email, icon: Icons.email),
            CustomTextField(controller: passwordController, label: l10n.password, icon: Icons.lock, isPassword: true),
            CustomTextField(controller: confirmPasswordController, label: l10n.confirmPassword, icon: Icons.lock, isPassword: true),
            CustomTextField(controller: phoneController, label: l10n.phoneNumber, icon: Icons.phone),
            CustomTextField(controller: addressController, label: l10n.address, icon: Icons.home),
            const SizedBox(height: 14),
            Row(
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
                RichText(
                  text: TextSpan(
                    text: l10n.understoodTerms,
                    style: GoogleFonts.roboto(fontSize: 14, color: const Color(0xFF777777)),
                    children: [
                      TextSpan(
                        text: l10n.termsPolicy,
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E754E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text(l10n.signUp,
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.alreadyHaveAccount,
                    style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF909090))),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => context.push(RouteNames.login),
                  child: Text(
                    l10n.signIn,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: const Color(0xFF3E754E),
                      fontWeight: FontWeight.w400,
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
    );
  }

  Future<void> signUp() async {
    final l10n = AppLocalizations.of(context)!;
    String fullname = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    if ([fullname, email, password, confirmPassword, phone, address].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseFillFields)));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordsDoNotMatch)));
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidEmail)));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.signUpSuccess)));
        context.push(RouteNames.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.signupFailed)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${l10n.error}: $e")));
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
