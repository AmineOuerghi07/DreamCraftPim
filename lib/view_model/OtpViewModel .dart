import 'package:flutter/material.dart';

import '../model/repositories/OtpRepository .dart';

class OtpViewModel extends ChangeNotifier {
  late final OtpRepository  otpRepository;
  

   String? _sentOtp;

  String? get sentOtp => _sentOtp;

  void setOtp(String otp) {
    _sentOtp = otp;
    notifyListeners(); 
  }
  // Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await otpRepository.sendOtp(phoneNumber);
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  // Verify OTP
  Future<void> verifyOtp(String otp, String userId) async {
    try {
      await otpRepository.verifyOtp(otp, userId);
    } catch (e) {
      print('Error verifying OTP: $e');
    }
  }
}
