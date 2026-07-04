import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/repo/create_donation_repo.dart';
import 'package:sharebridge/repo/create_donation_repo_imp.dart';
import 'package:sharebridge/repo/image_repo.dart';
import 'package:sharebridge/repo/image_repo_impl.dart';
import 'package:sharebridge/repo/notification_repo.dart';
import 'package:sharebridge/repo/notification_repo_impl.dart';
import 'package:sharebridge/repo/request_system_repo.dart';
import 'package:sharebridge/repo/request_system_repo_impl.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';
import 'package:sharebridge/repo/saved_items_repo_impl.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/confirmation_screen.dart';
import 'package:sharebridge/view/create_donation_screen.dart';
import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import 'package:sharebridge/view/request_system_screen.dart';
import 'package:sharebridge/viewmodel/create_donation_view_model.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import 'package:sharebridge/viewmodel/request_system_view_model.dart';
import 'package:sharebridge/viewmodel/saved_items_view_model.dart';
import 'package:sharebridge/viewmodel/user_view_model.dart';
import 'firebase_options.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        // Register repos first
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        Provider<NotificationRepo>(create: (_) => NotificationRepoImpl()),
        Provider<SavedItemRepo>(create: (_) => SavedItemRepoImpl(firestore: FirebaseFirestore.instance)),

        // Create Donation repos
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<CreateDonationRepository>(
          create: (context) =>
              CreateDonationRepoImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<ImageRepo>(create: (_) => ImageRepoImpl()),

        // Request System repo
        Provider<DonationRequestRepository>(
          create: (_) => DonationRequestRepositoryImpl(),
        ),

        // ViewModels depend on repos
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

        // Create Donation ViewModel
        ChangeNotifierProvider(
          create: (context) => CreateDonationViewModel(
            context.read<CreateDonationRepository>(),
            context.read<ImageRepo>(),
          ),
        ),

        // Request System ViewModel
        ChangeNotifierProvider(
          create: (_) => RequestSystemViewModel(
            repository: DonationRequestRepositoryImpl(),
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
      title: "Share-Bridge",
      debugShowCheckedModeBanner: false,
      home: const CreateDonationScreen(),
    );
  }
}