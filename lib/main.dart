import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'firebase_options.dart';
// import 'package:sharebridge/view/forgot_password_screen.dart';
// import 'package:sharebridge/view/login_screen.dart';
// import 'package:sharebridge/view/notification_screen.dart';
// import 'package:sharebridge/view/signup_screen.dart';
// import 'package:sharebridge/view/review.dart';
// import 'package:sharebridge/view/user.dart';
// import 'package:sharebridge/view/user_profile.dart';
import 'package:sharebridge/view/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyHomePage());
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "Share-Bridge",
      debugShowCheckedModeBanner: false,
      home: NotificationScreen(),
    );
  }
}



