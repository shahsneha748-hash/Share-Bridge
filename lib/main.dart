import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/repo/block_repo.dart';
import 'package:sharebridge/repo/block_repo_impl.dart';
import 'package:sharebridge/repo/create_donation_repo.dart';
import 'package:sharebridge/repo/create_donation_repo_impl.dart';
import 'package:sharebridge/repo/create_donation_repo_impl.dart';
import 'package:sharebridge/repo/image_repo.dart';
import 'package:sharebridge/repo/image_repo_impl.dart';
import 'package:sharebridge/repo/my_donation_repo_impl.dart';
import 'package:sharebridge/repo/notification_repo.dart';
import 'package:sharebridge/repo/notification_repo_impl.dart';
import 'package:sharebridge/repo/profile_repo.dart';
import 'package:sharebridge/repo/profile_repo_impl.dart';
import 'package:sharebridge/repo/request_system_repo.dart';
import 'package:sharebridge/repo/request_system_repo_impl.dart';
import 'package:sharebridge/repo/review_repo_impl.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';
import 'package:sharebridge/repo/saved_items_repo_impl.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
import 'package:sharebridge/repo/volunteer_repo.dart';
import 'package:sharebridge/repo/volunteer_repo_impl.dart';
import 'package:sharebridge/repo/volunteer_request_repo_impl.dart';
import 'package:sharebridge/repo/volunteer_task_repo.dart';
import 'package:sharebridge/repo/volunteer_task_repo_impl.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/admin_navigation_screen.dart';
import 'package:sharebridge/view/chat_list_screen.dart';
import 'package:sharebridge/view/confirmation_screen.dart';
import 'package:sharebridge/view/create_donation_screen.dart';
import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/view/request_system_screen.dart';
import 'package:sharebridge/view/splash_screen.dart';
import 'package:sharebridge/view/user.dart';
import 'package:sharebridge/view/user_profile.dart';
import 'package:sharebridge/view/volunteer_intro_screen.dart';
import 'package:sharebridge/view/volunteer_verification_screen.dart';
import 'package:sharebridge/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:sharebridge/viewmodel/block_view_model.dart';
import 'package:sharebridge/viewmodel/create_donation_view_model.dart';
import 'package:sharebridge/view/login_screen.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/view/signup_screen.dart';
import 'package:sharebridge/viewmodel/my_donation_view_model.dart';
import 'package:sharebridge/viewmodel/my_profile_viewmodel.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import 'package:sharebridge/viewmodel/other_profile_view_model.dart';
import 'package:sharebridge/viewmodel/request_system_view_model.dart';
import 'package:sharebridge/viewmodel/review_view_model.dart';
import 'package:sharebridge/viewmodel/saved_items_view_model.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'package:sharebridge/viewmodel/volunteer_request_viewmodel.dart';
import 'package:sharebridge/viewmodel/volunteer_task_viewmodel.dart';
import 'package:sharebridge/viewmodel/volunteer_view_model.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        Provider<NotificationRepo>(create: (_) => NotificationRepoImpl()),
        Provider<SavedItemRepo>(create: (_) => SavedItemRepoImpl(firestore: FirebaseFirestore.instance)),
        Provider<ProfileRepo>(create: (_) => ProfileRepoImpl()),
        Provider<BlockRepo>(create: (_) => BlockRepoImpl()),

        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<CreateDonationRepository>(
          create: (context) =>
              CreateDonationRepoImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<ImageRepo>(create: (_) => ImageRepoImpl()),

        Provider<RequestSystemRepo>(
          create: (_) => RequestSystemRepoImpl(),
        ),

        ChangeNotifierProvider(
          create: (context) => UserViewModel(
            userRepo: context.read<UserRepo>(),
            notificationRepo: context.read<NotificationRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationViewModel(
            repo: context.read<NotificationRepo>(),
            userRepo: context.read<UserRepo>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SavedItemViewModel(
            repo: context.read<SavedItemRepo>(),
            uid: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => CreateDonationViewModel(
            context.read<CreateDonationRepository>(),
            context.read<ImageRepo>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => RequestSystemViewModel(
            repository: context.read<RequestSystemRepo>(),
          ),
        ),

        Provider<VolunteerRepo>(
          create: (_) => VolunteerRepoImpl(),
        ),


        ChangeNotifierProvider(
          create: (_) => VolunteerViewModel(
            VolunteerRepoImpl(),
            ImageRepoImpl(),
          ),
        ),


        ChangeNotifierProvider(
          create: (_) => ReviewViewModel(
            repository: ReviewRepoImpl(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => MyProfileViewModel(profileRepo: ProfileRepoImpl(), imageRepo: ImageRepoImpl()),
        ),

        ChangeNotifierProvider(
          create: (_) => MyDonationsViewModel(repository: MyDonationsRepoImpl()),
        ),

        ChangeNotifierProvider(
          create: (context) => OtherProfileViewModel(
            profileRepo: context.read<ProfileRepo>(),
            blockRepo: context.read<BlockRepo>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => AdminDashboardViewModel(),
        ),

        ChangeNotifierProvider(
          create: (_) => BlockViewModel(
            repo: BlockRepoImpl(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => VolunteerRequestViewModel(
            VolunteerRequestRepoImpl(),
          ),
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
      navigatorKey: navigatorKey,
      title: "Share-Bridge",
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const AdminNavigationScreen(),
      },
      home: LoginScreen(),

    );

  }
}
