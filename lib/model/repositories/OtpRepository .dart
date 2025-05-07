
import 'package:flutter/material.dart';
import 'package:pim_project/model/services/OtpService.dart';
class OtpRepository extends ChangeNotifier {
  final OtpService otpService;

  OtpRepository({required this.otpService});

 

  // Verify OTP request
  Future<bool> verifyOtp(String otp, String userId) async {
    try {
      final response = await otpService.verifyOtp(otp, userId);
      return response;
    } catch (e) {
      print("Error in verifying OTP: $e");
      return false;
    }
  }

}
