import 'package:flutter/material.dart';
import 'package:pim_project/model/services/user_service.dart';

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
      return response;
    } catch (e) {
      isLoading = false;
      print("Error sending OTP: $e");
      return false;
    }
  }
}
