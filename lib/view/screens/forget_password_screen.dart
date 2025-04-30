import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:pim_project/view/screens/PhoneNumberScreen.dart';
import 'package:pim_project/view/screens/email_verification_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              l10n.forgetPassword,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E754E),
              ),
            ),
            SizedBox(height: 10),
            Text(
              l10n.selectContact,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmailVerificationScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFD3DED5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.black54),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.email,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF5B5A5A))),
                        Text(l10n.sendToEmail,
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF777777))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFD3DED5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Colors.black54),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.phoneNumber,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF5B5A5A))),
                        Text(l10n.sendToPhone,
                            style: TextStyle(
                                fontSize: 14, color: Color(0xFF777777))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // OR Divider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(child: Divider(thickness: 1, endIndent: 10)),
                Text("ou",
                    style: TextStyle(color: Colors.black54, fontSize: 14)),
                const Expanded(child: Divider(thickness: 1, indent: 10)),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text.rich(
                TextSpan(
                  text: l10n.didYouRemember,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF777777),
                  ),
                  children: [
                    TextSpan(
                      text: l10n.signIn,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF3E754E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
