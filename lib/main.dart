import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/notification_service.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
import 'package:sharebridge/view/notification_screen.dart';
// import 'package:sharebridge/view/saved_items.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'firebase_options.dart';
import 'package:sharebridge/view/splash_screen.dart';


// Future<void> _backgroundMessageHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  await notificationService.initFCM();

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  runApp(const MyHomePage());
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        // provider ko object banako   . UserRepo initiliatize first after viewmodel

        ChangeNotifierProvider(create: (context) =>
            UserViewModel(userRepo: context.read<UserRepo>()),
        ),
      ],
      child: MaterialApp( //we wrapped with multi provider becuase our app ma multiple view model huna sakcha so that's y we put it.
        title: "Share-Bridge",
        debugShowCheckedModeBanner: false,
        home: NotificationScreen(),
      ),
    );
  }
}
  Future<void> handleBackgroundMessage(RemoteMessage message) async{
    print("Message: ${message.notification?.title}");

}



