import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/view/browse_screen.dart';
import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/view/edit_profile_screen.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/view/review.dart';
import 'package:sharebridge/view/user.dart';
import 'package:sharebridge/view/user_profile.dart';

import 'firebase_options.dart';


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
        title: "sharebridge",
        debugShowCheckedModeBanner: false,
        home: BrowseScreen()

    );
  }
}