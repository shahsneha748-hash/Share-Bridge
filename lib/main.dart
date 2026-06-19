import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/repo/review_repo.dart';
import 'package:sharebridge/repo/review_repo_impl.dart';
import 'package:sharebridge/repo/volunteer_repo_impl.dart';
import 'package:sharebridge/view/edit_profile_screen.dart';
import 'package:sharebridge/view/review.dart';
import 'package:sharebridge/view/user.dart';
import 'package:sharebridge/view/user_profile.dart';
import 'package:sharebridge/view/volunteer_screen.dart';
import 'package:sharebridge/viewmodel/review_view_model.dart';
import 'package:sharebridge/viewmodel/volunteer_view_model.dart';

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
    return MultiProvider(
      providers: [
        Provider<ReviewRepository>(create: (_) => ReviewRepositoryImpl() ),

        ChangeNotifierProvider(
          create: (_) => ReviewViewModel(repository: context.read<ReviewRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => VolunteerViewModel(
            repo: VolunteerRepoImpl(
              firestore: FirebaseFirestore.instance,
            ),
          ),
        ),
      ],
      child: MaterialApp(
          title: "sharebridge",
          debugShowCheckedModeBanner: false,
          home: VolunteerScreen()


      ),
    );
  }
}