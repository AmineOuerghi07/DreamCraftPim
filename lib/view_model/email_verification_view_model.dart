// view_model/email_verification_view_model.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  bool isLoading = false;
  String? errorMessage;
  String? verificationCode;

  EmailVerificationViewModel({required this.userRepository});

  // Send verification email
  Future<bool> sendVerificationEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.sendOtpByEmail(email);

      if (response.status == Status.COMPLETED) {
        _showSuccessToast("Code de vérification envoyé à votre email");
        return true;
      } else {
        errorMessage = response.message ?? "Échec de l'envoi du code de vérification";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur lors de l'envoi : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP code
  Future<bool> verifyCode(String userId, String code) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await userRepository.verifyOtp(code, userId);

      if (response.status == Status.COMPLETED) {
        _showSuccessToast("Email vérifié avec succès");
        return true;
      } else {
        errorMessage = response.message ?? "Code de vérification invalide";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur lors de la vérification : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Resend verification code
  Future<bool> resendVerificationCode(String email) async {
    return sendVerificationEmail(email);
  }

  // Validate verification code format
  bool isValidVerificationCode(String code) {
    // Assuming the OTP is 6 digits
    return RegExp(r'^\d{6}$').hasMatch(code);
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