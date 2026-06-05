import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/login_model.dart';
import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/view/forgot_password_screen.dart';
import 'package:sharebridge/view/signup_screen.dart';
//import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      backgroundColor: Color(0XFF435944),
      appBar: AppBar(
        backgroundColor: Color(0XFF435944),
      ),
      body: Column(// By default every widget will be in centre
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello!", style: TextStyle(
                  color: Colors.white,
                  fontWeight:FontWeight.w700,
                  fontSize: 52,

                )),
                Text("Welcome to ShareBridge", style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: Container(
              width: 393,
              decoration: BoxDecoration(
                  color: Color(0XFFd1e8bf),
                  borderRadius: BorderRadius.circular(37)
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Login", style: TextStyle(
                      color: Color(0XFF435944),
                      fontWeight: FontWeight.w600,
                      fontSize: 40,
                    )),

                    SizedBox(
                      height: 20,
                    ),

                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Icon(Icons.email_outlined),
                          ),
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text("Email", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
                          ),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !visibility,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Icon(Icons.lock_outline),
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
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))
                        ),

                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(onTap: (){

                            // Navigator.pushReplacement(context, newRoute)
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),));
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen(),));

                          }, child: Text("Forgot Password", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 17),)

                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 500, height: 57,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0XFF435944), foregroundColor: Colors.white),
                        onPressed: () async {
                          // ✅ Step 1: Check if fields are empty
                          if (emailController.text.trim().isEmpty ||
                              passwordController.text.trim().isEmpty) {
                            Fluttertoast.showToast(msg: "All text must be filled");
                            return; // stop execution here
                          }

                          // ✅ Step 2: Proceed with login if not empty
                          final userId = await viewModel.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          if (userId.isNotEmpty) {
                            Fluttertoast.showToast(msg: "Login successful");
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(builder: (_) => DashboardScreen()),
                            // );
                          } else {
                            Fluttertoast.showToast(msg: "Login Failed");
                          }
                        },
                        child: viewModel.loading ? CircularProgressIndicator() : Text("Login",style: TextStyle(fontSize: 20),),
                      ),
                    ),


                    SizedBox(
                      height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have account?", style: TextStyle(color: Colors.grey, fontSize: 17),),
                        GestureDetector(
                          onTap: (){
                            // Navigator.pushReplacement(context, newRoute)
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupScreen(),));
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen(),));

                          },
                          child: Text(" Sign up", style: TextStyle(color: Colors.blue, fontSize: 17),),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

