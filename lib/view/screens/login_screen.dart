// view/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view_model/login_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/constants/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool rememberMe = false;
  bool obscureText = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
    _initializeGoogleSignIn();
  }

  Future<void> _loadRememberMePreference() async {
    print('🔍 Loading Remember Me preference...');
    final rememberMeValue = await UserPreferences.getRememberMe();
    print('📋 Remember Me preference loaded: $rememberMeValue');
    setState(() {
      rememberMe = rememberMeValue;
    });
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      print('🔐 [LoginScreen] Initialisation de Google Sign-In');
      final GoogleSignInAccount? currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) {
        print('✅ [LoginScreen] Utilisateur déjà connecté: ${currentUser.email}');
        await _handleGoogleSignIn(currentUser);
      }
    } catch (error) {
      print('❌ [LoginScreen] Erreur lors de l\'initialisation: $error');
    }
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    try {
      print('🔐 [LoginScreen] Début de la connexion Google');
      print('👤 Utilisateur Google sélectionné: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('🔑 Authentification Google réussie');
      
      if (googleAuth.accessToken == null) {
        print('❌ [LoginScreen] Pas de token d\'accès');
        throw Exception('Pas de token d\'accès');
      }

      final loginViewModel = context.read<LoginViewModel>();
      final success = await loginViewModel.signInWithGoogle(
        googleAuth.accessToken!,
        googleUser.email,
        googleUser.displayName ?? '',
        googleUser.photoUrl ?? ''
      );

      if (success && mounted) {
        final userId = loginViewModel.currentUser?.userId ?? MyApp.userId;
        if (userId.isNotEmpty) {
          context.go(RouteNames.home, extra: userId);
        }
      }
    } catch (error) {
      print('❌ [LoginScreen] Erreur: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  Future<void> login() async {
    print('🔐 Login button pressed');
    print('📝 Remember Me state: $rememberMe');
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final loginViewModel = context.read<LoginViewModel>();
    final success = await loginViewModel.login(email, password, rememberMe);

    if (success && mounted) {
      final userId = loginViewModel.currentUser?.userId ?? MyApp.userId;
      if (userId.isNotEmpty) {
        context.go(RouteNames.home, extra: userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: ID utilisateur non trouvé')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                    l10n.welcomeBack,
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3E754E),
                    ),
                  ),
                  Text(
                    l10n.loginToAccount,
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
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.email,
                          color: const Color(0xFF777777),
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        ),
                        border: InputBorder.none,
                        hintText: l10n.email,
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
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.lock,
                          color: const Color(0xFF777777),
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                        ),
                        border: InputBorder.none,
                        hintText: l10n.password,
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
                              l10n.rememberMe,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.push(RouteNames.forgetPassword),
                          child: Text(
                            l10n.forgetPassword,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3E754E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: loginViewModel.isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E754E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        loginViewModel.isLoading ? l10n.connexion : l10n.login,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Or continue with
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 1,
                        color: const Color(0xFFDAE5DD),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.orContinueWith,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 100,
                        height: 1,
                        color: const Color(0xFFDAE5DD),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFDAE5DD),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            try {
                              final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
                              if (googleUser != null) {
                                await _handleGoogleSignIn(googleUser);
                              }
                            } catch (error) {
                              print('❌ [LoginScreen] Erreur: $error');
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $error')),
                              );
                            }
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Color(0xFF777777),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteNames.signup),
                        child: Text(
                          l10n.signUp,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3E754E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (loginViewModel.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3E754E)),
                  ),
                ),
              ),
          ],
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
