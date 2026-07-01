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
    final viewModel = context.watch<UserViewModel>();


    return Scaffold(
      backgroundColor: const Color(0XFF435944),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0XFF435944),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0XFFd1e8bf),
                            borderRadius: BorderRadius.circular(37),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    const Text(
                                      "Signup",
                                      style: TextStyle(
                                        color: Color(0XFF435944),
                                        fontSize: 38,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Image.asset('assets/images/loogo1.png', height: 70, width: 75),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Join us today",
                                  style: TextStyle(
                                    color: Color(0XFF435944),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),


                                // Form fields
                                _buildField(nameController, "Full Name"),
                                _buildField(addressController, "Address"),
                                _buildField(emailController, "Email", icon: Icons.email_outlined),
                                _buildField(phoneController, "Phone", icon: Icons.phone_android_outlined),
                                _buildPassword(passwordController, "Password", visibility, () {
                                  setState(() => visibility = !visibility);
                                }),
                                _buildPassword(confirmPasswordController, "Confirm Password", visibility1, () {
                                  setState(() => visibility1 = !visibility1);
                                }),


                                const Spacer(), // 👈 pushes button to bottom


                                // Signup Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 57,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0XFF435944),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      // Validation
                                      if (emailController.text.trim().isEmpty ||
                                          passwordController.text.trim().isEmpty ||
                                          confirmPasswordController.text.trim().isEmpty ||
                                          nameController.text.trim().isEmpty ||
                                          addressController.text.trim().isEmpty ||
                                          phoneController.text.trim().isEmpty) {
                                        Fluttertoast.showToast(msg: "All text must be filled");
                                        return;
                                      }
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
                                        final userId = await viewModel.signup(
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );


                                        if (userId.isEmpty) {
                                          Fluttertoast.showToast(msg: viewModel.error.toString());
                                          return;
                                        }


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


                                        final success = await viewModel.addUser(model);
                                        if (success) {
                                          Fluttertoast.showToast(msg: "Signup successful");
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                                          );
                                        } else {
                                          Fluttertoast.showToast(msg: "Signup failed");
                                        }
                                      } catch (e) {
                                        Fluttertoast.showToast(msg: "Signup failed: $e");
                                      }
                                    },
                                    child: viewModel.loading
                                        ? const CircularProgressIndicator()
                                        : const Text("Create Account", style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  // Helpers
  Widget _buildField(TextEditingController controller, String hint, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }


  Widget _buildPassword(TextEditingController controller, String hint, bool visible, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(visible ? Icons.visibility_rounded : Icons.visibility_off),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(25),
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

