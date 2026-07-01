import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFd1e8bf),
      appBar: AppBar(
          backgroundColor: Color(0XFF435944),
          centerTitle: true,
          title: Text("Email OTP", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w500),)),
      body:
      SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 25),
                  child: Image.asset("assets/images/safe_email1.png", height: 170, width: 165),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Enter your email"),
                  ),
                ),
                SizedBox(height: 30),
          //
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF435944),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () async{
                      // ✅ Step 1: Check if fields are empty
                      if (emailController.text.trim().isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter your email");
                        return; // stop execution here
                      }
                      final email = emailController.text.trim();

                      if (email.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter your email");
                        return;
                      }

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        Fluttertoast.showToast(msg: "Password reset email sent to $email");
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Error: Too many request send to reset password",
                        );
                      }
                    },
                    child: Text("Send OTP", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),))
                 ],
            ),
        ),
      ),
    );
  }
}
