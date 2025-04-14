// view_model/login_view_model.dart
import 'package:flutter/material.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pim_project/model/domain/user.dart';

String user_id = "";

class LoginViewModel with ChangeNotifier {
  final UserRepository userRepository;
  bool isLoading = false;
  String? errorMessage;
  User? currentUser;

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
      print('🔍 Checking login status...');
      final rememberMe = await UserPreferences.getRememberMe();
      print('🔐 Remember Me status: $rememberMe');
      
      if (rememberMe) {
        print('🔄 Remember Me is enabled, attempting to retrieve saved user');
        final savedUser = await UserPreferences.getUser();
        if (savedUser != null) {
          print('✅ Auto-login successful for user ID: ${savedUser.userId}');
          currentUser = savedUser;
          notifyListeners();
          return true;
        } else {
          print('⚠️ No saved user found despite Remember Me being enabled');
        }
      } else {
        print('ℹ️ Remember Me is disabled, no auto-login attempted');
      }
      return false;
    } catch (e) {
      print("❌ Error checking login status: $e");
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await UserPreferences.clear();
      currentUser = null;
      notifyListeners();
    } catch (e) {
      _showErrorToast("Erreur lors de la déconnexion : ${e.toString()}");
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle(String googleToken) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.googleLogin(googleToken);

      if (response.status == Status.COMPLETED && response.data != null) {
        currentUser = response.data;
        
        // Save user data and update MyApp.userId
        await UserPreferences.setUserId(response.data!.userId);
        await UserPreferences.setToken(googleToken); // Save the token
        MyApp.userId = response.data!.userId;
        
        // Always save user data for Google sign-in
        await UserPreferences.setUser(response.data!);
        await UserPreferences.setRememberMe(true);
        
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
