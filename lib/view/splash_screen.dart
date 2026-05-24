import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 3), () {
      navigate();
    });

  }

  navigate() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get stored values
    final bool? isLoggedIn = prefs.getBool("isLoggedIn") ;

    if(isLoggedIn == true){
      // Navigator.pushReplacement(context, MaterialPageRoute(
      //     builder: (context) => DashboardScreen()),);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => LoginScreen()),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Image.asset("assets/images/logoo.png", height: 350, width: 350,)),
          SizedBox(height: 10,),
          CircularProgressIndicator(),
          Column(
            children: [
              Text("ShareBridge", style: TextStyle(fontSize: 45, color: Color(0XFF435944)),),
              Text("Guarantees that your acts of kindness will", style: TextStyle(fontSize: 20, color: Color(0XFF435944))),
              Text("not lose meaning.", style: TextStyle(fontSize: 20, color: Color(0XFF435944))),
              Text("Because sharing should be simple.", style: TextStyle(fontSize: 20, color: Color(0XFF435944)),
              )
            ],
          )
        ],
      ),

    );
  }
}
