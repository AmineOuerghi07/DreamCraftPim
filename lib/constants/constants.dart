// constants/constants.dart
import 'package:flutter/material.dart';


const String plantIllnessBaseURL = "http://127.0.0.1:8000/";
class AppConstants {
  static const double padding = 16.0;
  static const double margin = 12.0;
  static const double borderRadius = 8.0;
  static const double appBarHeight = 56.0;
  static const Color primaryColor = Color(0xFF6200EA);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const String  chatBaseUrl = "http://192.168.43.232:8001";
  //
  static const String baseUrl = "http://192.168.43.232:3000"; 




  // API Endpoints
  static const String signInEndpoint = "$baseUrl/sign-in";
  static const String landsEndpoint = "$baseUrl/lands";
  static const String regionsEndpoint = "$baseUrl/regions";
  static const String usersEndpoint = "$baseUrl/users";

   static const String imagesbaseURL = "http://192.168.43.232:3000/uploads/";
}
