import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pim_project/view/screens/phone_verification_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart'; 

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});

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
              "Forget Password",
              style: TextStyle(
                color: Color(0xFF3E754E),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your phone number we will send you confirmation code",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF777777),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            IntlPhoneField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD3DED5),
                hintText: "Phone Number",
                hintStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF777777),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              initialCountryCode: 'TN',
              dropdownIcon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF777777),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ), // Tunisia
              onChanged: (phone) {
                print("Phone Number: ${phone.completeNumber}");
              },
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
                  context.push(RouteNames.phoneVerification);
            },
                
              
              child: const Center(
                child: Text(
                  "Send",
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
