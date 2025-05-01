// view_model/login_view_model.dart
import 'package:flutter/material.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

String user_id = "";

class LoginViewModel with ChangeNotifier {
  final UserRepository userRepository;
  bool isLoading = false;
  String? errorMessage;
  User? currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginViewModel({required this.userRepository});

  // Regular email/password login
  Future<bool> login(String email, String password, bool rememberMe) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    print('🔐 Login attempt with email: $email, Remember Me: $rememberMe');

    try {
      final response = await userRepository.login(email, password);

      if (response.status == Status.COMPLETED && response.data != null) {
        currentUser = response.data;
        print('✅ Login successful for user ID: ${response.data!.userId}');
        
        // Save user data and update MyApp.userId
        await UserPreferences.setUserId(response.data!.userId);
        MyApp.userId = response.data!.userId;
        
        // Save additional user data if remember me is checked
        if (rememberMe) {
          print('💾 Saving user credentials with Remember Me enabled');
          await UserPreferences.setUser(response.data!);
          await UserPreferences.setRememberMe(true);
        } else {
          print('🧹 Remember Me disabled, clearing saved credentials');
          // If remember me is not checked, only keep the current session data
          await UserPreferences.clear();
          await UserPreferences.setUserId(response.data!.userId); // Keep the current session ID
          await UserPreferences.setRememberMe(false);
        }
        
        return true;
      } else {
        errorMessage = response.message ?? "Une erreur inconnue s'est produite.";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur de connexion : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    try {
      print('🔍 [LoginStatus] Vérification du statut de connexion');
      final rememberMe = await UserPreferences.getRememberMe();
      final userId = await UserPreferences.getUserId();
      final token = await UserPreferences.getToken();
      
      print('📊 [LoginStatus] État actuel:');
      print('   - Remember Me: $rememberMe');
      print('   - User ID: $userId');
      print('   - Token: ${token != null ? "Présent" : "Absent"}');
      
      if (rememberMe && userId != null && userId.isNotEmpty && token != null && token.isNotEmpty) {
        print('✅ [LoginStatus] Utilisateur connecté');
        currentUser = await UserPreferences.getUser();
        MyApp.userId = userId;
        notifyListeners();
        return true;
      } else {
        print('❌ [LoginStatus] Aucun utilisateur connecté');
        await UserPreferences.clear();
        return false;
      }
    } catch (e) {
      print('❌ [LoginStatus] Erreur: $e');
      await UserPreferences.clear();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('🔐 [Logout] Début de la déconnexion');
      
      // Réinitialiser l'ID utilisateur global
      MyApp.userId = "";
      
      // Effacer toutes les préférences utilisateur
      await UserPreferences.clear();
      
      // Réinitialiser l'état du ViewModel
      currentUser = null;
      isLoading = false;
      errorMessage = null;
      
      // Forcer la réinitialisation de l'état de connexion
      await UserPreferences.setRememberMe(false);
      await UserPreferences.setToken("");
      await UserPreferences.setUserId("");
      
      // Désactiver la connexion automatique Google
      await _googleSignIn.signOut();
      
      print('✅ [Logout] Déconnexion réussie');
      notifyListeners();
    } catch (e) {
      print('❌ [Logout] Erreur lors de la déconnexion: $e');
      _showErrorToast("Erreur lors de la déconnexion : ${e.toString()}");
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle(String googleToken, String email, String fullname, String image) async {
    print('🔐 [Google Login] Début du processus de connexion');
    isLoading = true;
    notifyListeners();

    try {
      final response = await userRepository.googleLogin(googleToken, email, fullname, image);
      print('✅ [Google Login] Réponse reçue du repository');

      if (response.status == Status.COMPLETED && response.data != null) {
        currentUser = response.data;
        await UserPreferences.setUserId(currentUser!.userId);
        await UserPreferences.setToken(googleToken);
        await UserPreferences.setUser(currentUser!);
        MyApp.userId = currentUser!.userId;
        return true;
      } else {
        errorMessage = response.message ?? "Échec de la connexion avec Google";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur de connexion Google : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Password Reset Request
  Future<bool> requestPasswordReset(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.sendOtpByEmail(email);

      if (response.status == Status.COMPLETED) {
        _showSuccessToast("Code de réinitialisation envoyé à votre email");
        return true;
      } else {
        errorMessage = response.message ?? "Échec de l'envoi du code de réinitialisation";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur d'envoi : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String userId, String newPassword, String confirmPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.resetPassword(userId, newPassword, confirmPassword);

      if (response.status == Status.COMPLETED) {
        _showSuccessToast("Mot de passe réinitialisé avec succès");
        return true;
      } else {
        errorMessage = response.message ?? "Échec de la réinitialisation du mot de passe";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur de réinitialisation : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp, String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.verifyOtp(otp, userId);

      if (response.status == Status.COMPLETED) {
        _showSuccessToast("Code vérifié avec succès");
        return true;
      } else {
        errorMessage = response.message ?? "Code invalide ou expiré";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur de vérification : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods for showing toasts
  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}
