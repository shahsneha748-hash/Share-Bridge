import 'package:flutter/material.dart';
// import 'package:sharebridge/view/forgot_password_screen.dart';
// import 'package:sharebridge/view/login_screen.dart';
// import 'package:sharebridge/view/notification_screen.dart';
// import 'package:sharebridge/view/signup_screen.dart';
import 'package:sharebridge/view/splash_screen.dart';

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
