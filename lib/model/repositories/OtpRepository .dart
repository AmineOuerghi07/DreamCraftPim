import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pim_project/model/services/OtpService.dart';
import 'package:pim_project/model/services/api_client.dart';
class OtpRepository extends ChangeNotifier {
  final OtpService otpService;

  OtpRepository({required this.otpService});

  // Send OTP request
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final response = await otpService.sendOtp(phoneNumber);
      return true; // Ajout d'un retour en cas de succès
    } catch (e) {
      print("Error in sending OTP: $e");
      return false;
    }
  }

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
