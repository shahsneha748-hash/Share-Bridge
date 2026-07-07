import 'package:flutter/material.dart';

import 'package:sharebridge/view/chat_list_screen.dart';
import 'package:sharebridge/view/create_donation_screen.dart';
import 'package:sharebridge/view/dashboard_screen.dart';
import 'package:sharebridge/view/browse_screen.dart';
import 'package:sharebridge/view/user_profile.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late int currentIndex;
  late PageController pageController;

  String? _browseInitialCategory;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
    pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToBrowse({String? category}) {
    setState(() {
      _browseInitialCategory = category;
    });

    pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          DashboardScreen(onGoToBrowse: _goToBrowse),
          BrowseScreen(initialCategory: _browseInitialCategory),
          const CreateDonationScreen(),
          const ChatListScreen(),
          const MyProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
        selectedItemColor: const Color(0xFF3A5C2E),
        unselectedItemColor: const Color(0xFF5F7A45),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        items: [
          _navItem(Icons.home, 'Home', 0),
          _navItem(Icons.search, 'Browse', 1),
          _navItem(Icons.add, 'Post', 2),
          _navItem(Icons.chat, 'Chat', 3),
          _navItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem(
      IconData icon,
      String label,
      int index,
      ) {
    final bool active = currentIndex == index;
    final bool isPost = index == 2;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF3A5C2E)
              : (isPost
              ? const Color(0xFFF5F0E8)
              : Colors.transparent),
          borderRadius: isPost
              ? BorderRadius.circular(23)
              : BorderRadius.circular(12),
          border: isPost && !active
              ? Border.all(
            color: const Color(0xFFD0DEC0),
            width: 1.5,
          )
              : null,
        ),
        child: Icon(
          icon,
          color: active
              ? Colors.white
              : (isPost
              ? const Color(0xFF3A5C2E)
              : const Color(0xFF8FAF6E)),
          size: 26,
        ),
      ),
    );
  }
}