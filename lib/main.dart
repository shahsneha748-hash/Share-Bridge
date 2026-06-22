import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/repo/notification_repo.dart';
import 'package:sharebridge/repo/notification_repo_impl.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';
import 'package:sharebridge/repo/saved_items_repo_impl.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/homescreentest.dart';
import 'package:sharebridge/view/login_screen.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import 'package:sharebridge/viewmodel/saved_items_view_model.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Register repos first
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        Provider<NotificationRepo>(create: (_) => NotificationRepoImpl()),
        Provider<SavedItemRepo>(create: (_) => SavedItemRepositoryImpl()),

        // ViewModels depend on repos
        ChangeNotifierProvider(
          create: (context) =>
              UserViewModel(
                userRepo: context.read<UserRepo>(),
                notificationRepo: context.read<NotificationRepo>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              NotificationViewModel(
                repo: context.read<NotificationRepo>(),
                userRepo: context.read<UserRepo>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SavedItemViewModel(savedItemRepo: context.read<SavedItemRepo>()),
        ),
      ],
      child: const MyHomePage(),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Share-Bridge",
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}





