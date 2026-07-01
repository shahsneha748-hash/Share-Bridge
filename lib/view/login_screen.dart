import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/view/homescreentest.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/view/signup_screen.dart';
import 'package:sharebridge/view/forgot_password_screen.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';

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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
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

              // Login form container
              Container(
                width: 393,
                height: 500,
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

                      // Email field
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

                      // Password field
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

                      // Forgot password link
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

                      // Login button
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
                              // 🔑 Step 1: Login with FirebaseAuth
                              await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                              Fluttertoast.showToast(msg: "Login successful");

                              // 🔑 Step 2: Get the logged-in user's UID
                              final uid = FirebaseAuth.instance.currentUser!.uid;

                              // 🔑 Step 3: Fetch user document from Firestore
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get();

                              final role = userDoc.data()?['role'];

                              // ✅ Navigate on success
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const Homescreentest(uid: '')),
                              );


                              // // 🔑 Step 4: Navigate based on role
                              // if (role == 'admin') {
                              //   Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(builder: (_) => const AdminNavigationScreen()),
                              //   );
                              // } else {
                              //   Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(builder: (_) => const NavigationScreen()),
                              //   );
                              // }

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

                      // Signup link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have account?",
                            style: TextStyle(color: Colors.grey, fontSize: 17),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
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
      ),
    );
  }
}


