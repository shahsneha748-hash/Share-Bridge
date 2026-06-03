import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
// import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/view/saved_items.dart';
import 'package:sharebridge/view/splash_screen.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
// import 'package:sharebridge/view/splash_screen.dart';
import 'firebase_options.dart';
// import 'package:sharebridge/view/forgot_password_screen.dart';
// import 'package:sharebridge/view/login_screen.dart';
//import 'package:sharebridge/view/notification_screen.dart';
// import 'package:sharebridge/view/signup_screen.dart';
// import 'package:sharebridge/view/review.dart';
// import 'package:sharebridge/view/user.dart';
// import 'package:sharebridge/view/user_profile.dart';
// import 'package:sharebridge/view/splash_screen.dart';

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
    return MultiProvider(
      providers: [
        Provider<UserRepo>(create: (_) => UserRepoImpl()),          // provider ko object banako   . UserRepo initiliatize first after viewmodel

        ChangeNotifierProvider(create: (context) =>
        UserViewModel(userRepo: context.read<UserRepo>()),
        ),
        ],
      child: MaterialApp(               //we wrapped with multi provider becuase our app ma multiple view model huna sakcha so that's y we put it.
        title: "Share-Bridge",
        debugShowCheckedModeBanner: false,
        home: SavedItemsScreen(),
      ),
    );
  }
}



