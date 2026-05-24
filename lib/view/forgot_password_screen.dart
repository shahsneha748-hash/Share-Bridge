import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:sharebridge/login_screen.dart';

Future<void> requestOtp(String email) async {
  final response = await http.post(
    Uri.parse("http://localhost:3000/request-otp"), // backend endpoint
    body: {"email": email},
  );

  if (response.statusCode == 200) {
    print("OTP sent to email!");
  } else {
    print("Failed to send OTP");
  }
}

Future<void> resetPassword(String email, String otp, String newPassword) async {
  final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

  final response = await http.post(
    Uri.parse("http://localhost:3000/reset-password"),
    body: {"email": email, "otp": otp, "newPassword": hashedPassword},
  );

  if (response.statusCode == 200) {
    // Update SharedPreferences locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("Password", hashedPassword);

    print("Password reset successful!");
  } else {
    print("Invalid OTP or reset failed");
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool otpSent = false; // track state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFd1e8bf),
      appBar: AppBar(
          backgroundColor: Color(0XFF435944),
          centerTitle: true,
          title: Text("Email OTP", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w500),)),
      body: Padding(
        padding: const EdgeInsets.only(top:20, bottom: 100),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 25),
              child: Image.asset("assets/images/lock.png", height: 65, width: 65),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Enter your email"),
              ),
            ),
            SizedBox(height: 30),
            // Show OTP + new password fields only after OTP is sent
            if (otpSent) ...[
              TextFormField(
                controller: otpController,
                decoration: InputDecoration(labelText: "Enter OTP"),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Enter new password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  resetPassword(
                    emailController.text,
                    otpController.text,
                    newPasswordController.text,
                  );
                },
                child: Text("Reset Password"),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: 350, height: 57,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF435944),
                      foregroundColor: Colors.white,),
                    onPressed: () async {
                      await requestOtp(emailController.text);
                      setState(() {
                        otpSent = true; // show OTP fields
                      });
                    },
                    child: Text("Send OTP"),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
