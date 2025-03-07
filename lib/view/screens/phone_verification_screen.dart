import 'package:flutter/material.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  String? otpReceived; // Variable to hold OTP received

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Correctly extracting OTP using GoRouter
    final extra = GoRouterState.of(context).extra;
    if (extra is String) {
      otpReceived = extra; // Ensure it's a String
    } else {
      otpReceived = null; // Handle the case where no OTP is provided
    }
  }

 Future<void> verifyOtp(String enteredOtp, BuildContext context) async {
  print("🔍 Entered OTP: $enteredOtp");
  print("🔍 Received OTP: $otpReceived");

  if (enteredOtp == otpReceived) {
    context.push(RouteNames.resetPassword);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect OTP')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          "Forget Password",
          style: TextStyle(
            color: Color(0xFF3E754E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Code has been sent to +216 ******88",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3DED5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onCompleted: (pin) {
                verifyOtp(pin, context); // Verify OTP on completion
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                print("Resend Code");
              },
              child: const Text(
                "Resend Code",
                style: TextStyle(
                  color: Color(0xFF3E754E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E754E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  verifyOtp('manualOtp', context);
                },
                child: const Text(
                  "Verify",
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
