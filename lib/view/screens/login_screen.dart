import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pim_project/view/screens/forget_password_screen.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool obscureText = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text;

   /* if (email.isEmpty || password.isEmpty) {
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
    }*/

    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
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
            //const SizedBox(height: 5),
            Positioned(
              top: 0,
              right: 90,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "Welcome back",
                          style: GoogleFonts.roboto(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3E754E),
                          ),
                        ),
                      ],
                    ),
                  ]),
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
                    fontWeight: FontWeight.w300, // Light font
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
                    fontWeight: FontWeight.w300, // Light font
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
                      // Navigate to Forgot Password screen
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
                onPressed: login, // Appelle la fonction login
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
                Text("or",
                    style: TextStyle(color: Colors.black54, fontSize: 14)),
                const Expanded(child: Divider(thickness: 1, indent: 10)),
              ],
            ),
      
            // Social Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook,
                      color: Colors.blue, size: 30),
                  onPressed: () {},
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google,
                      color: Colors.red, size: 30),
                  onPressed: () {},
                ),
              ],
            ),
           const SizedBox(height: 8),
      
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF777777),
                  ),
                ),
                TextButton(
                  onPressed: () {
                   context.push(RouteNames.signup);
                  },
                  child: Text(
                    "Sign up",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF3E754E),
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
}

//class hedhi bch bech trigel limage lkbira
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
