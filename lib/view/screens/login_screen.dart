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
    
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.shortestSide >= 600;
    
    // Calculate responsive dimensions
    final double headerHeight = isTablet 
        ? screenSize.height * 0.35 
        : screenSize.height * 0.3;
    final double horizontalPadding = isTablet 
        ? screenSize.width * 0.1
        : screenSize.width * 0.08;
    final double textFieldHeight = isTablet ? 60.0 : 50.0;
    
    // Text sizes
    final double titleFontSize = isTablet ? 32.0 : 28.0;
    final double subTitleFontSize = isTablet ? 16.0 : 14.0;
    final double inputFontSize = isTablet ? 18.0 : 16.0;
    final double buttonFontSize = isTablet ? 18.0 : 16.0;
    final double smallTextFontSize = isTablet ? 16.0 : 14.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with curved image
                  Stack(
                    children: [
                      ClipPath(
                        clipper: ResponsiveWaveClipper(),
                        child: SizedBox(
                          height: headerHeight,
                          width: double.infinity,
                          child: Image.asset(
                            "assets/images/plantelogin.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  
                  // Welcome Text
                  Text(
                    l10n.welcomeBack,
                    style: GoogleFonts.roboto(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3E754E),
                    ),
                  ),
                  Text(
                    l10n.loginToAccount,
                    style: GoogleFonts.roboto(
                      fontSize: subTitleFontSize,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.025),

                  // Email Input
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.03,
                    ),
                    height: textFieldHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAE5DD),
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                    child: TextField(
                      controller: emailController,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.roboto(
                        fontSize: inputFontSize,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.email,
                          color: const Color(0xFF777777),
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                          size: isTablet ? 24 : 20,
                        ),
                        border: InputBorder.none,
                        hintText: l10n.email,
                        hintStyle: GoogleFonts.roboto(
                          fontSize: inputFontSize,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),

                  // Password Input
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.03,
                    ),
                    height: textFieldHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAE5DD),
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: obscureText,
                      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.roboto(
                        fontSize: inputFontSize,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.lock,
                          color: const Color(0xFF777777),
                          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                          size: isTablet ? 24 : 20,
                        ),
                        border: InputBorder.none,
                        hintText: l10n.password,
                        hintStyle: GoogleFonts.roboto(
                          fontSize: inputFontSize,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF777777),
                            size: isTablet ? 24 : 20,
                          ),
                          onPressed: togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),

                  // Remember Me & Forgot Password
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding * 0.8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Transform.scale(
                              scale: isTablet ? 1.2 : 1.0,
                              child: Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                                shape: const CircleBorder(),
                                activeColor: const Color(0xFF4F6656),
                              ),
                            ),
                            Text(
                              l10n.rememberMe,
                              style: GoogleFonts.roboto(
                                fontSize: smallTextFontSize,
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
                              fontSize: smallTextFontSize,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3E754E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.025),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: isTablet ? 60 : 50,
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: ElevatedButton(
                      onPressed: loginViewModel.isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E754E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                      ),
                      child: Text(
                        loginViewModel.isLoading ? l10n.connexion : l10n.login,
                        style: GoogleFonts.roboto(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),

                  // Or continue with
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenSize.width * 0.25,
                        height: 1,
                        color: const Color(0xFFDAE5DD),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.orContinueWith,
                        style: GoogleFonts.roboto(
                          fontSize: smallTextFontSize,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: screenSize.width * 0.25,
                        height: 1,
                        color: const Color(0xFFDAE5DD),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.025),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isTablet ? 60 : 50,
                        height: isTablet ? 60 : 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFDAE5DD),
                          ),
                          borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
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
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            color: const Color(0xFF777777),
                            size: isTablet ? 24 : 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.025),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: GoogleFonts.roboto(
                          fontSize: smallTextFontSize,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteNames.signup),
                        child: Text(
                          l10n.signUp,
                          style: GoogleFonts.roboto(
                            fontSize: smallTextFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3E754E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add extra padding at the bottom for scrolling
                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
            if (loginViewModel.isLoading)
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
}

// Responsive Wave Clipper
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