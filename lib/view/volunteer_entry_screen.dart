import 'package:flutter/material.dart';
import 'volunteer_navigation_screen.dart';

class VolunteerEntryScreen extends StatefulWidget {
  const VolunteerEntryScreen({super.key});

  @override
  State<VolunteerEntryScreen> createState() => _VolunteerEntryScreenState();
}

class _VolunteerEntryScreenState extends State<VolunteerEntryScreen> {

  @override
  void initState() {
    super.initState();
    _goToMain();
  }

  void _goToMain() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VolunteerMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}