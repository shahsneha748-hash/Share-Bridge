import 'package:flutter/material.dart';
import 'package:sharebridge/forgot_password_screen.dart';
import 'package:sharebridge/login_screen.dart';
import 'package:sharebridge/signup_screen.dart';
import 'package:sharebridge/splash_screen.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Share-Bridge",
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),

    );
  }
}
