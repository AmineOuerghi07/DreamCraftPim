// view/screens/OTPVerificationScreen.dart
import 'package:flutter/material.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _sentOtp;
  bool _canResendOtp = true;
  String? _userId; // Declare userId variable

  // Resend OTP function
  Future<void> _resendOtp() async {
    if (!_canResendOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait before resending OTP')),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/account/forgot-password-otp-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email}), // Dynamic email
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        if (responseBody.containsKey('otp')) {
          setState(() {
            _sentOtp = responseBody['otp'];
          });
          print("New stored OTP: $_sentOtp");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
          setState(() {
            _canResendOtp = false;
          });
          Future.delayed(Duration(seconds: 30), () {
            setState(() {
              _canResendOtp = true;
            });
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  bool _isLoading = false;

  // Send OTP function
  Future<void> _sendOtp() async {
    var response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/account/forgot-password-otp-email'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': widget.email}),
    );

    print("Raw Response: ${response.body}"); // <-- Check raw response

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseBody = json.decode(response.body);

      print("Response from server: $responseBody");  // <-- Ensure 'otp' is in response

      if (responseBody.containsKey('otp')) {
        setState(() {
          _sentOtp = responseBody['otp'];
          _userId = responseBody['userId']; // Assuming 'userId' is returned in the response
        });
        print("New stored OTP: $_sentOtp");

        print("OTP set to: $_sentOtp");  // <-- Check OTP value

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      } else {
        print("No OTP key found in response.");
      }
    } else {
      print("Failed to send OTP. Status code: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

 void _verifyOtp() {
  if (_sentOtp == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP not sent yet. Please request OTP.')),
    );
    return;
  }

  if (_otpController.text == _sentOtp) {
    if (_userId != null) {
      // Navigate to ResetPasswordScreen with the userId
      context.push('${RouteNames.resetPassword}?userId=$_userId');

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing. Cannot proceed.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect OTP. Please try again.')),
    );
  }
}

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Send OTP when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Verification Email",
              style: TextStyle(
                color: Color(0xFF3E754E),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please enter the code we just sent to your email",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              controller: _otpController,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3DED5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
               onCompleted: (pin) {
                _verifyOtp(); // Verify OTP when completed
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _resendOtp,
              child: const Text(
                "Resend Code",
                style: TextStyle(
                  color: Color(0xFF3E754E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E754E),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _verifyOtp,
              child: const Center(
                child: Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
