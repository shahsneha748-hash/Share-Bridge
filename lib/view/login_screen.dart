import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/view/signup_screen.dart';
import 'package:sharebridge/view/forgot_password_screen.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'package:sharebridge/view/admin_navigation_screen.dart';

import '../repo/notification_repo.dart';
import '../repo/user_repo.dart';
import '../viewmodel/notification_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool visibility = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    return Scaffold(
      backgroundColor: const Color(0XFF435944),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0XFF435944),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hello!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 52,
                    ),
                  ),
                  Text(
                    "Welcome to ShareBridge",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            Container(
              width: 393,
              height: 730,
              decoration: BoxDecoration(
                color: Color(0XFFd1e8bf),
                borderRadius: BorderRadius.circular(37),
              ),
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                            color: Color(0XFF435944),
                            fontWeight: FontWeight.w600,
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(width: 15),
                        Image.asset('assets/images/loogo1.png', height: 70, width: 75),
                      ],
                    ),

                    SizedBox(height: 20),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon:  Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Icon(Icons.email_outlined),
                        ),
                        hint:  Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Email",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:  BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    TextFormField(
                      controller: passwordController,
                      obscureText: !visibility,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Icon(Icons.lock_outline),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              visibility = !visibility;
                            });
                          },
                          icon: Icon(
                            visibility ? Icons.visibility_rounded : Icons.visibility_off,
                          ),
                        ),
                        hint: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFF435944),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            Fluttertoast.showToast(msg: "All fields must be filled");
                            return;
                          }

                          try {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            final settings = await FirebaseMessaging.instance.getNotificationSettings();
                            if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
                              await FirebaseMessaging.instance.requestPermission();
                            }

                            final uid = FirebaseAuth.instance.currentUser!.uid;

                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .get();

                            final role = userDoc.data()?['role'];

                            // Ban check
                            final isBanned = userDoc.data()?['isBanned'] as bool? ?? false;

                            if (isBanned) {
                              await FirebaseAuth.instance.signOut();

                              if (context.mounted) {
                                Fluttertoast.showToast(
                                  msg: "Your account has been restricted. Contact support.",
                                );
                              }
                              return;
                            }

                            // Show success ONLY if user is not banned
                            Fluttertoast.showToast(msg: "Login successful");

                            final token = await FirebaseMessaging.instance.getToken();
                            if (token != null) {
                              await FirebaseFirestore.instance.collection('users').doc(uid).set({
                                'fcmToken': token,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                            }

                            if (role == 'admin') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminNavigationScreen(),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (context) => NotificationViewModel(
                                      repo: context.read<NotificationRepo>(),
                                      userRepo: context.read<UserRepo>(),
                                    ),
                                    child: const NavigationScreen(),
                                  ),
                                ),
                              );
                            }

                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              Fluttertoast.showToast(msg: "Incorrect email");
                            } else if (e.code == 'wrong-password') {
                              Fluttertoast.showToast(msg: "Incorrect password");
                            } else {
                              Fluttertoast.showToast(msg: "Login failed");
                            }
                          }
                        },
                        child: viewModel.loading
                            ? const CircularProgressIndicator()
                            : const Text("Login", style: TextStyle(fontSize: 20)),
                      ),
                    ),

                    SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have account?",
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            " Sign up",
                            style: TextStyle(color: Colors.blue, fontSize: 17),
                          ),
                        ),
                      ],
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