import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/volunteer_history_screen.dart';
import 'package:sharebridge/view/volunteer_my_task_screen.dart' hide VolunteerTaskViewModel;
import '../repo/volunteer_task_repo.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';
import 'volunteer_home_screen.dart';


class VolunteerMainScreen extends StatelessWidget {
  const VolunteerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to continue.')),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => VolunteerTaskViewModel(
        repo: context.read<VolunteerTaskRepo>(),
        volunteerId: uid,
      ),
      child: const _VolunteerMainScaffold(),
    );
  }
}

class _VolunteerMainScaffold extends StatefulWidget {
  const _VolunteerMainScaffold();

  @override
  State<_VolunteerMainScaffold> createState() => _VolunteerMainScaffoldState();
}

class _VolunteerMainScaffoldState extends State<_VolunteerMainScaffold> {
  int currentIndex = 0;

  final screens = const [
    VolunteerHomeScreen(),
    MyTasksScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Small red dot on "My Tasks" when something needs the volunteer's response.
    final pendingCount =
        context.watch<VolunteerTaskViewModel>().pendingTasks.length;

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF3A5C2E),
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _badge(const Icon(Icons.assignment_outlined), pendingCount),
            activeIcon: _badge(const Icon(Icons.assignment), pendingCount),
            label: "My Tasks",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }

  Widget _badge(Widget icon, int count) {
    if (count == 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}