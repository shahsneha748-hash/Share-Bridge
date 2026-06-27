import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/view/login_screen.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';

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
  bool visibility1 = false;


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();              // notify listeners leh listen gariraknu ko lagi watch rakheko (like error loading haru bhairakcha so) (we initialized it build bhitra)
    return Scaffold(
      backgroundColor: Color(0XFF435944),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0XFF435944),
      ),

      body:
        SafeArea(
          child: SingleChildScrollView(
            // 👇 ensures padding when keyboard is open
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),          child: Column(
              children: [
                SizedBox(height: 35),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Color(0XFFd1e8bf), borderRadius: BorderRadius.circular(37)),
            
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top:20, bottom: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
            
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 20),
                          child: Row(
                            children: [
                              Text("Signup", style: TextStyle(color: Color(0XFF435944), fontSize: 38, fontWeight: FontWeight.w600 )),
                              SizedBox(width: 15),
                              Image.asset('assets/images/loogo1.png', height: 70, width: 75),

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
                            obscureText: !visibility1,
                            decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Icon(Icons.lock_outlined),
                                ),
                                suffixIcon: IconButton(onPressed: (){
                                  setState(() {
                                    visibility1 = !visibility1;
                                  });
                                },
                                    icon: Icon(!visibility1 == false? Icons.visibility_off: Icons.visibility_rounded
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
                                onPressed: () async {
                                  // Step 1: Check if fields are empty
                                  if (emailController.text.trim().isEmpty ||
                                      passwordController.text.trim().isEmpty ||
                                      confirmPasswordController.text.trim().isEmpty ||
                                      nameController.text.trim().isEmpty ||
                                      addressController.text.trim().isEmpty ||
                                      phoneController.text.trim().isEmpty) {
                                    Fluttertoast.showToast(msg: "All text must be filled");
                                    return;
                                  }
            
                                  // Step 2: Validate inputs BEFORE signup
                                  if (confirmPasswordController.text != passwordController.text) {
                                    Fluttertoast.showToast(msg: "Confirm password must be same as password");
                                    return;
                                  }
                                  if (passwordController.text.length < 6) {
                                    Fluttertoast.showToast(msg: "Password must be at least 6 characters");
                                    return;
                                  }
                                  if (phoneController.text.length < 10) {
                                    Fluttertoast.showToast(msg: "Phone number must be at least 10 characters");
                                    return;
                                  }
            
                                  try {
                                    // Step 3: Attempt signup
                                    final userId = await viewModel.signup(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
            
                                    if (userId.isEmpty) {
                                      Fluttertoast.showToast(msg: viewModel.error.toString());
                                      return;
                                    }
            
                                    // Step 4: Build user model
                                    final model = UserModel(
                                      uid: userId,
                                      fullName: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      address: addressController.text.trim(),
                                      role: "user",
                                      isVerified: false,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      rating: 0.0,
                                      totalDonations: 0,
                                    );
            
                                    // Step 5: Save user profile
                                    final success = await viewModel.addUser(model);
                                    if (success) {
                                      Fluttertoast.showToast(msg: "Signup successful");
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginScreen()),
                                      );
                                    } else {
                                      Fluttertoast.showToast(msg: "Signup failed");
                                    }
                                  } catch (e) {
                                    Fluttertoast.showToast(msg: "Signup failed: $e");
                                  }
                                },
                              child: viewModel.loading ? CircularProgressIndicator() : Text("Create Account",style: TextStyle(fontSize: 20),),
                            ),
                          ),
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



// ⚡ In short (summary of the "Create Account button clicked logic" code above):
// Validate inputs → show toast if empty.
//
// Signup with FirebaseAuth → get uid.
//
// Create UserModel → store extra info.
//
// Save to Firestore → persist profile.
//
// Show toast + navigate → feedback + redirect.

