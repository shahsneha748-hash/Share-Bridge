import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/volunteer_history_screen.dart';
import 'package:sharebridge/view/volunteer_my_task_screen.dart' hide VolunteerTaskViewModel;
import '../components/break_toggle_bar.dart';
import '../model/volunteer_model.dart';
import '../repo/volunteer_repo.dart';
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
    return const _VolunteerMainScaffold();
  }
}

class _VolunteerMainScaffold extends StatefulWidget {
  const _VolunteerMainScaffold();
  @override
  State<_VolunteerMainScaffold> createState() => _VolunteerMainScaffoldState();
}

class _VolunteerMainScaffoldState extends State<_VolunteerMainScaffold> {
  int currentIndex = 0;
  late PageController pageController;

  final screens = const [
    VolunteerHomeScreen(),
    MyTasksScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<VolunteerTaskViewModel>().listenFor(uid);
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        context.watch<VolunteerTaskViewModel>().pendingTasks.length;

    return Scaffold(
      body: PageView(
        controller: pageController,
        children: screens,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3A5C2E),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: _navIcon(Icons.home_outlined, isActive: currentIndex == 0),
            activeIcon: _navIcon(Icons.home, isActive: true),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _badge(_navIcon(Icons.assignment_outlined, isActive: currentIndex == 1), pendingCount),
            activeIcon: _badge(_navIcon(Icons.assignment, isActive: true), pendingCount),
            label: "My Tasks",
          ),
          BottomNavigationBarItem(
            icon: _navIcon(Icons.history_outlined, isActive: currentIndex == 2),
            activeIcon: _navIcon(Icons.history, isActive: true),
            label: "History",
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3A5C2E).withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon),
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
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}