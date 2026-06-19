import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/create_donation_screen.dart';

import 'firebase_options.dart';
import 'view/request_system_screen.dart';
import 'repo/request_system_repo.dart';
import 'viewmodel/request_system_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RequestSystemViewModel(RequestSystemRepo()),
        ),
      ],
      child: MaterialApp(
        title: 'sharebridge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const RequestSystemScreen()
      ),
    );
  }
}