// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/repo/notification_repo.dart';
import 'package:sharebridge/repo/notification_repo_impl.dart';
import 'package:sharebridge/repo/profile_repo_impl.dart';
import 'package:sharebridge/repo/review_repo_impl.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';
import 'package:sharebridge/repo/saved_items_repo_impl.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
import 'package:sharebridge/repo/volunteer_repo.dart';
import 'package:sharebridge/repo/volunteer_repo_impl.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/view/edit_profile_screen.dart';
// import 'package:sharebridge/view/homescreentest.dart';
import 'package:sharebridge/view/login_screen.dart';
import 'package:sharebridge/view/my_review_screen.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/view/review.dart';
import 'package:sharebridge/view/signup_screen.dart';
import 'package:sharebridge/view/user.dart';
import 'package:sharebridge/view/user_profile.dart';
import 'package:sharebridge/view/user_setting_screen.dart';
import 'package:sharebridge/view/volunteer_entry_screen.dart';
import 'package:sharebridge/view/volunteer_home_screen.dart';
import 'package:sharebridge/view/volunteer_intro_screen.dart';
import 'package:sharebridge/view/volunteer_navigation_screen.dart';
import 'package:sharebridge/view/volunteer_pending%20screen.dart';
import 'package:sharebridge/view/volunteer_task_detail_screen.dart';
import 'package:sharebridge/view/volunteer_verification_screen.dart';
import 'package:sharebridge/viewmodel/my_profile_viewmodel.dart';
// import 'package:sharebridge/view/dashboard_screen.dart';
// import 'package:sharebridge/view/item_detail_screen.dart';
// import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import 'package:sharebridge/viewmodel/review_view_model.dart';
import 'package:sharebridge/viewmodel/saved_items_view_model.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'package:sharebridge/viewmodel/volunteer_view_model.dart';
import 'firebase_options.dart';
import 'package:sharebridge/repo/volunteer_task_repo.dart';
import 'package:sharebridge/repo/volunteer_task_repo_impl.dart';
import 'package:sharebridge/viewmodel/volunteer_task_viewmodel.dart';

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
          child: const NotificationScreen(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SavedItemViewModel(savedItemRepo: context.read<SavedItemRepo>()),
        ),

        Provider<VolunteerRepo>(
          create: (_) => VolunteerRepoImpl(),
        ),

        Provider<VolunteerTaskRepo>(
          create: (_) => VolunteerTaskRepoImpl(),
        ),

        ChangeNotifierProvider(
          create: (context) => VolunteerViewModel(
            context.read<VolunteerRepo>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => VolunteerTaskViewModel(
            context.read<VolunteerTaskRepo>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ReviewViewModel(
            repository: ReviewRepoImpl(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => MyProfileViewModel(profileRepo: ProfileRepoImpl()),
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
      home: MyProfileScreen (),
    );
  }
}





