import 'package:flutter/material.dart';
import 'package:sharebridge/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

// Function to hash
String hashPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

bool checkPassword(String password, String hashed) {
  return BCrypt.checkpw(password, hashed);
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool visibility = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF435944),
      appBar: AppBar(
        backgroundColor: Color(0XFF435944),
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Container(
                width: 393,
                decoration: BoxDecoration(color: Color(0XFFd1e8bf), borderRadius: BorderRadius.circular(37)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text("Signup", style: TextStyle(color: Color(0XFF435944), fontSize: 38, fontWeight: FontWeight.w600 ))
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Row(
                          children: [
                            Text("Join us today", style: TextStyle(color: Color(0XFF435944), fontSize: 15, fontWeight: FontWeight.w500 ))
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              hint: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text("Full Name", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                              hint: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text("Address", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Icon(Icons.email_outlined),
                              ),
                              hint: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text("Email", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,  vertical: 10),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: !visibility,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Icon(Icons.lock_outlined),
                              ),
                              suffixIcon: IconButton(onPressed: (){
                                setState(() {
                                  visibility = !visibility;
                                });
                              },
                                  icon: Icon(!visibility == false? Icons.visibility_off: Icons.visibility_rounded
                                  )
                              ),
                              hint: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text("Password", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,  vertical: 10),
                        child: TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !visibility,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Icon(Icons.lock_outlined),
                              ),
                              suffixIcon: IconButton(onPressed: (){
                                setState(() {
                                  visibility = !visibility;
                                });
                              },
                                  icon: Icon(!visibility == false? Icons.visibility_off: Icons.visibility_rounded
                                  )
                              ),
                              hint: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text("Confirm Password", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent),borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left:10, right: 10, top: 10, bottom: 3),
                        child: TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Icon(Icons.phone_android_outlined),
                              ),
                              hint: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text("Phone", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                      ),

                      SizedBox(height: 15),
                      SizedBox(
                        width: 500, height: 57,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFF435944),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async{
                              // Obtain shared preferences.
                              final SharedPreferences prefs = await SharedPreferences.getInstance();

                              // Check if any field is empty
                              if (nameController.text.isEmpty ||
                                  addressController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  passwordController.text.isEmpty ||
                                  confirmPasswordController.text.isEmpty ||
                                  phoneController.text.isEmpty) {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("⚠️ Please fill in all fields")),
                                );
                                return; // stop execution here
                              }

                              // Hash both password and confirm password
                              final hashedPassword = hashPassword(passwordController.text);
                              final hashedConfirmPassword = hashPassword(confirmPasswordController.text);


                              // Save other fields normally
                              await prefs.setString("Full Name", nameController.text);
                              await prefs.setString("Address", addressController.text);
                              await prefs.setString("Email", emailController.text);
                              // Save hashed values instead of plain text
                              await prefs.setString("Password", hashedPassword);
                              await prefs.setString("Confirm Password", hashedConfirmPassword);
                              await prefs.setString("Phone", phoneController.text);

                              // Navigator.pushReplacement(context, newRoute)
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen(),));



                            },
                            child: Text("Create Account", style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

