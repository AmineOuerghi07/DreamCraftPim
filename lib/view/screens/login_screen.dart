import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/forget_password_screen.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pim_project/view/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:pim_project/model/services/user_service.dart'; // Import UserService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool rememberMe = false;
  bool obscureText = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false;

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email invalide')),
      );
      return;
    }

    try {
      final userService = UserService(apiClient: Dio());
      final user = await userService.login(email, password);

      if (user != null) {
        context.go(RouteNames.home, extra: MyApp.userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _googleSignInMethod() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User cancelled the Google sign-in')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        context.go(RouteNames.market);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google login failed')),
        );
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: CustomWaveClipper(),
                    child: SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: Image.asset(
                        "assets/images/plantelogin.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome back",
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3E754E),
                ),
              ),
              Text(
                "Login to your account",
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF777777),
                ),
              ),
              const SizedBox(height: 20),

              // Email Input
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email, color: Color(0xFF777777)),
                    border: InputBorder.none,
                    hintText: "Email",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password Input
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE5DD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock, color: Color(0xFF777777)),
                    border: InputBorder.none,
                    hintText: "Password",
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
                      onPressed: togglePasswordVisibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Remember Me & Forgot Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                          shape: const CircleBorder(),
                          activeColor: const Color(0xFF4F6656),
                        ),
                        Text(
                          "Remember me",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forget password?",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF909090),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Login Button
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
                  onPressed: login,
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // OR Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: Divider(thickness: 1, endIndent: 10)),
                  Text("or", style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const Expanded(child: Divider(thickness: 1, indent: 10)),
                ],
              ),

              // Social Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 30),
                    onPressed: () {}, // Facebook login can be added here
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 30),
                    onPressed: _googleSignInMethod, // Google Sign-In method
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w300, color: const Color(0xFF777777))),
                  TextButton(
                    onPressed: () {
Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );                    },
                    child: Text("Sign Up", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF4F6656))),
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


// Custom Wave Clipper
class CustomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.85,
    );

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
