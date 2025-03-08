// view_model/email_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/services/user_service.dart';
import 'package:pim_project/model/services/api_client.dart';

class EmailVerificationScreenViewModel extends ChangeNotifier {
  final UserService userService;

  EmailVerificationScreenViewModel({required this.userService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> sendOtpEmail(String email) async {
    try {
      isLoading = true;
      final response = await userService.sendOtpEmail(email);
      isLoading = false;
      return response.status == Status.COMPLETED;
    } catch (e) {
      isLoading = false;
      print("Error sending OTP: $e");
      return false;
    }
  }

  Future<bool> sendVerificationEmail(String email) async {
    // Implementation of sendVerificationEmail method
    // This method should return true if the email is sent successfully
    return false;
  }

  bool isValidVerificationCode(String code) {
    // Implementation of isValidVerificationCode method
    // This method should return true if the verification code is valid
    return false;
  }

  Future<bool> verifyCode(String userId, String code) async {
    // Implementation of verifyCode method
    // This method should return true if the code is verified successfully
    return false;
  }

  Future<bool> resendVerificationCode(String email) async {
    // Implementation of resendVerificationCode method
    // This method should return true if the verification code is resent successfully
    return false;
  }

  void _showErrorToast(String message) {
    // Implementation of _showErrorToast method
    // This method should show an error toast with the given message
  }
}
