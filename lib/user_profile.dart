import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static const Color darkGreen = Color(0xFF3D5C35);
  static const Color bgGreen = Color(0xFFB5C9AE);
  static const Color cream = Color(0xFFF0EAD6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textGrey = Color(0xFF6B6B6B);

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: darkGreen,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack(context, 'Signed out successfully');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Contact')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showSnack(context, 'Profile updated');
                },
                child: const Text('Save', style: TextStyle(color: white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGreen,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                color: white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildProfileAvatar(context),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showEditProfile(context),
                        child: const Text(
                          'Olivia Sharma',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showSnack(context, 'Email tapped'),
                        child: const Text(
                          'contact@gmail.com',
                          style: TextStyle(fontSize: 14, color: textGrey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(context),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              context: context,
                              title: 'History',
                              icon: Icons.history,
                              onTap: () => _showSnack(context, 'Opening History...'),
                            ),
                            const SizedBox(height: 14),
                            _buildMenuItem(
                              context: context,
                              title: 'Notifications',
                              icon: Icons.notifications_none,
                              onTap: () => _showSnack(context, 'Opening Notifications...'),
                            ),
                            const SizedBox(height: 14),
                            _buildMenuItem(
                              context: context,
                              title: 'Privacy & Settings',
                              icon: Icons.lock_outline,
                              onTap: () => _showSnack(context, 'Opening Privacy & Settings...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSignOutButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: cream, size: 20),

          ),
          const Expanded(
            child: Center(
              child: Text(
                'Profile',
                style: TextStyle(
                  color: cream,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showEditProfile(context),
            child: const Icon(Icons.edit, color: cream, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSnack(context, 'Change profile photo'),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cream, width: 3),
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/image/user.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: white,
                border: Border.all(color: cream, width: 1.5),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _showSnack(context, 'Contact: 123456789'),
          child: _buildInfoItem(label: 'CONTACT', value: '123456789'),
        ),
        Container(
          width: 1,
          height: 30,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
        GestureDetector(
          onTap: () => _showSnack(context, 'Status: Donor'),
          child: _buildInfoItem(label: 'STATUS', value: 'Donor'),
        ),
      ],
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textGrey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, color: textDark)),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cream,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: darkGreen.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: darkGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: textDark, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSignOutDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: darkGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: darkGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context: context, icon: Icons.home_outlined, label: 'Home', isActive: false),
          _buildNavItem(context: context, icon: Icons.search, label: 'Browse', isActive: false),
          _buildNavItem(context: context, icon: Icons.add, label: 'Post', isActive: false, isCircle: true),
          _buildNavItem(context: context, icon: Icons.menu, label: 'My Items', isActive: false),
          _buildNavItem(context: context, icon: Icons.person, label: 'Profile', isActive: true),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    bool isCircle = false,
  }) {
    return GestureDetector(
      onTap: () => _showSnack(context, 'Navigating to $label...'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: isCircle
                ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
            )
                : isActive
                ? BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.circular(12),
            )
                : null,
            child: Icon(
              icon,
              size: 22,
              color: isActive ? white : textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? darkGreen : textGrey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}