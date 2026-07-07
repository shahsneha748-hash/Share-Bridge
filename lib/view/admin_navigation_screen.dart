import 'package:flutter/material.dart';
import 'admin_dashboard_view.dart';
import 'users_admin_screen.dart';
import 'donation_admin_screen.dart';
import 'admin_report_screen.dart';
import 'admin_volunteer_screen.dart';
import 'settings_admin_screen.dart';

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const UsersAdminScreen(),
    const DonationAdminScreen(),
    const AdminReportScreen(),
    const AdminVolunteerScreen(),
    const SettingsAdminScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Called when user swipes
  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  // Called when user taps a bottom nav tab
  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      _NavTab(icon: Icons.dashboard_outlined,          label: 'Dashboard'),
      _NavTab(icon: Icons.people_outline,              label: 'Users'),
      _NavTab(icon: Icons.card_giftcard_outlined,      label: 'Donations'),
      _NavTab(icon: Icons.bar_chart,                   label: 'Reports'),
      _NavTab(icon: Icons.volunteer_activism_outlined, label: 'Volunteers'),
      _NavTab(icon: Icons.settings_outlined,           label: 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFD1E8BF), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final isActive = _selectedIndex == e.key;
            final tab = e.value;
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTabTapped(e.key),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        tab.icon,
                        size: 22,
                        color: isActive
                            ? const Color(0xFF6B9757)
                            : const Color(0xFFAECDA3),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: isActive
                              ? const Color(0xFF6B9757)
                              : const Color(0xFF888780),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  _NavTab({required this.icon, required this.label});
}