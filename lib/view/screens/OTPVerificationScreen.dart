import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart'; 

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key});

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
              "Please enter the code we just sent to email",
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
                decoration: BoxDecoration(
                  color: const Color(0xFFD3DED5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onCompleted: (pin) {
                print("Entered OTP: $pin");
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                print("Resend OTP");
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E754E),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
             onPressed: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResetPasswordScreen()),
                  );
                  */
                  context.push(RouteNames.resetPassword);
                                  },
              
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
