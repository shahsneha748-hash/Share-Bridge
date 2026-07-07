import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/settings_admin_viewmodel.dart';
import 'admin_dashboard_view.dart';
import 'package:sharebridge/view/login_screen.dart';
import '../constants/colors.dart';

class SettingsAdminScreen extends StatelessWidget {
  const SettingsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsAdminViewModel()..loadSettings(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsAdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: vm.isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(vm),
                  const SizedBox(height: 20),
                  _sectionLabel('Account'),
                  _buildAccountSection(context, vm),
                  const SizedBox(height: 20),
                  _sectionLabel('Notifications'),
                  _buildNotificationsSection(vm),
                  const SizedBox(height: 20),
                  _sectionLabel('App info'),
                  _buildAppInfoSection(),
                  const SizedBox(height: 20),
                  _sectionLabel('Danger zone'),
                  _buildLogoutButton(context, vm),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20, right: 16, bottom: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Settings',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── SECTION LABEL ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.dark,
            letterSpacing: 0.7,
          )),
    );
  }

  // ── PROFILE CARD ───────────────────────────────────────────────────────────

  Widget _buildProfileCard(SettingsAdminViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(vm.profile!.initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vm.profile!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    )),
                const SizedBox(height: 3),
                Text(vm.profile!.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(vm.profile!.role,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successText,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACCOUNT SECTION ────────────────────────────────────────────────────────

  Widget _buildAccountSection(
      BuildContext context, SettingsAdminViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.person_outline,
            iconBg: AppColors.blueBg,
            iconColor: AppColors.blueText,
            title: 'Edit profile',
            subtitle: 'Update your name and email',
            onTap: () => _showEditProfile(context, vm),
          ),
          const Divider(height: 1, color: Color(0xFFEDF2E7),
              indent: 56),
          _SettingsTile(
            icon: Icons.lock_outline,
            iconBg: AppColors.amberBg,
            iconColor: AppColors.amberText,
            title: 'Change password',
            subtitle: 'Update your login password',
            onTap: () => _showChangePassword(context),
          ),
        ],
      ),
    );
  }

  // ── NOTIFICATIONS SECTION ──────────────────────────────────────────────────

  Widget _buildNotificationsSection(SettingsAdminViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: [
          _ToggleTile(
            icon: Icons.notifications_outlined,
            iconBg: AppColors.successBg,
            iconColor: AppColors.successText,
            title: 'Push notifications',
            subtitle: 'Receive alerts on this device',
            value: vm.notificationsEnabled,
            onChanged: vm.toggleNotifications,
          ),
          const Divider(height: 1, color: Color(0xFFEDF2E7),
              indent: 56),
          _ToggleTile(
            icon: Icons.email_outlined,
            iconBg: AppColors.blueBg,
            iconColor: AppColors.blueText,
            title: 'Email alerts',
            subtitle: 'Get important updates via email',
            value: vm.emailAlertsEnabled,
            onChanged: vm.toggleEmailAlerts,
          ),
          const Divider(height: 1, color: Color(0xFFEDF2E7),
              indent: 56),
          _ToggleTile(
            icon: Icons.flag_outlined,
            iconBg: AppColors.dangerBg,
            iconColor: AppColors.dangerText,
            title: 'Flagged content alerts',
            subtitle: 'Notified when content is reported',
            value: vm.flaggedContentAlerts,
            onChanged: vm.toggleFlaggedAlerts,
          ),
        ],
      ),
    );
  }

  // ── APP INFO SECTION ───────────────────────────────────────────────────────

  Widget _buildAppInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.info_outline,
            iconBg: AppColors.light2,
            iconColor: AppColors.primary,
            title: 'App version',
            value: 'v1.0.0',
          ),
          const Divider(height: 1, color: Color(0xFFEDF2E7),
              indent: 56),
          _InfoTile(
            icon: Icons.shield_outlined,
            iconBg: AppColors.light2,
            iconColor: AppColors.primary,
            title: 'Admin since',
            value: 'Jan 2024',
          ),
          const Divider(height: 1, color: Color(0xFFEDF2E7),
              indent: 56),
          _InfoTile(
            icon: Icons.people_outline,
            iconBg: AppColors.light2,
            iconColor: AppColors.primary,
            title: 'Platform',
            value: 'ShareBridge',
          ),
        ],
      ),
    );
  }

  // ── LOGOUT BUTTON ──────────────────────────────────────────────────────────

  Widget _buildLogoutButton(
      BuildContext context, SettingsAdminViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _confirmLogout(context, vm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout,
                    size: 18, color: AppColors.dangerText),
                SizedBox(width: 8),
                Text('Log out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerText,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── DIALOGS ────────────────────────────────────────────────────────────────

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Coming soon!',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, SettingsAdminViewModel vm) {
    final nameController = TextEditingController(text: vm.profile?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit profile',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Full name',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: AppColors.primary, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.light2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(vm.profile?.email ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              Navigator.pop(ctx);
              final success = await vm.updateProfile(newName);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: success
                      ? AppColors.primary
                      : AppColors.dangerText,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Row(
                    children: [
                      Icon(
                        success
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: Colors.white, size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        success
                            ? 'Profile updated successfully'
                            : 'Failed to update profile',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final currentPwController = TextEditingController();
        final newPwController     = TextEditingController();
        final confirmPwController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Change password',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(
                controller: currentPwController,
                label: 'Current password',
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: newPwController,
                label: 'New password',
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: confirmPwController,
                label: 'Confirm new password',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Password updated successfully',
                            style: TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Update',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(
      BuildContext context, SettingsAdminViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
          'You will be signed out of the admin panel.',
          style: TextStyle(
              fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── REUSABLE TILE WIDGETS ─────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, value;

  const _InfoTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                )),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const _PasswordField({
    required this.controller,
    required this.label,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(
            fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
            color: AppColors.textMuted,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}