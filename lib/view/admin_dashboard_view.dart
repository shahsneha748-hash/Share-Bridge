import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_dashboard_viewmodel.dart';
import '../model/admin_model.dart';
import 'placeholder_screen.dart';
import 'admin_report_screen.dart';
import 'users_admin_screen.dart';
import 'donation_admin_screen.dart';
import 'settings_admin_screen.dart';
import 'stats_admin_screen.dart';
import 'admin_notification_screen.dart';
import '../constants/colors.dart';



class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;

  final List<String> _tabTitles = [
    'Dashboard',
    'Users',
    'Donations',
    'Reports',
    'Settings',
  ];

  void _navigateTo(String title) {
    Widget screen;
    switch (title) {
      case 'Reports':
        screen = const AdminReportScreen();
        break;
      case 'Users':
        screen = const UsersAdminScreen();
        break;
      case 'Donations':
        screen = const DonationAdminScreen();
        break;
      case 'Settings':
        screen = const SettingsAdminScreen();
        break;
      default:
        screen = PlaceholderScreen(title: title);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: controller.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Overview · Today'),
                  _buildStatGrid(controller.stats!),
                  _sectionLabel('Quick actions'),
                  _buildQuickActions(),
                  _sectionLabel('Flagged content'),
                  _buildFlaggedSection(controller),
                  _sectionLabel('Donations by category'),
                  _buildCategoryChart(controller.categories),
                  _sectionLabel('Top donors this month'),
                  _buildDonorLeaderboard(controller.topDonors),
                  _sectionLabel('Recent activity'),
                  _buildActivityFeed(controller.activityFeed),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }

  // ── TOP BAR ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning 👋',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminNotificationScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ── SECTION LABEL ───────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.dark,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  // ── STAT GRID ───────────────────────────────────────────────────────────────

  Widget _buildStatGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7, // FIX: increased further to eliminate 7.1px overflow
      padding: EdgeInsets.zero,
      children: [
        GestureDetector(
          onTap: () => _navigateTo('Donations'),
          child: _StatCard(
            icon: Icons.card_giftcard_outlined,
            iconBg: AppColors.light2,
            iconColor: AppColors.successText,
            value: stats.totalDonations.toString(),
            label: 'Total donations',
            delta: '+12 today',
            deltaColor: AppColors.successText,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateTo('Users'),
          child: _StatCard(
            icon: Icons.people_outline,
            iconBg: AppColors.light3,
            iconColor: const Color(0xFF4a6830),
            value: stats.activeUsers.toString(),
            label: 'Active users',
            delta: '+23 new',
            deltaColor: AppColors.successText,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateTo('Donations'),
          child: _StatCard(
            icon: Icons.schedule,
            iconBg: AppColors.amberBg,
            iconColor: AppColors.amberText,
            value: stats.pendingRequests.toString(),
            label: 'Pending requests',
            delta: 'needs action',
            deltaColor: AppColors.dangerText,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateTo('Reports'),
          child: _StatCard(
            icon: Icons.flag_outlined,
            iconBg: AppColors.dangerBg,
            iconColor: AppColors.dangerText,
            value: stats.flaggedPosts.toString(),
            label: 'Flagged posts',
            delta: 'review now',
            deltaColor: AppColors.dangerText,
          ),
        ),
      ],
    );
  }

  // ── QUICK ACTIONS ───────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.add,
        label: 'Add\ncategory',
        destination: 'Manage Categories',
      ),
      _QuickAction(
        icon: Icons.bar_chart,
        label: 'Statistics',
        destination: 'Statistics',
      ),
      _QuickAction(
        icon: Icons.campaign_outlined,
        label: 'Announce',
        destination: 'Send Announcement',
      ),

    ];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final a = actions[i];
          return Material(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (a.destination == 'Statistics') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatsAdminScreen()),
                  );
                }
              },
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.light2, width: 0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // FIX: prevents column from expanding beyond content
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.light2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(a.icon, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── FLAGGED POSTS ───────────────────────────────────────────────────────────

  Widget _buildFlaggedSection(AdminDashboardViewModel controller) {
    if (controller.flaggedPosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.light2, width: 0.5),
        ),
        child: const Center(
          child: Text(
            'No flagged posts — all clear!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dangerBorder, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX
        children: controller.flaggedPosts
            .map((post) => _FlagCard(
          post: post,
          onRemove: () => controller.removePost(post.id),
          onKeep: () => controller.keepPost(post.id),
        ))
            .toList(),
      ),
    );
  }

  // ── CATEGORY CHART ──────────────────────────────────────────────────────────

  Widget _buildCategoryChart(List<CategoryStat> categories) {
    final barColors = [
      AppColors.primary,
      AppColors.light1,
      AppColors.light3,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX
        children: categories.asMap().entries.map((entry) {
          final i   = entry.key;
          final cat = entry.value;
          final color = barColors[i % barColors.length]; // FIX: safe index with modulo
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    cat.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: cat.percentage,
                      minHeight: 8,
                      backgroundColor: AppColors.light2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${(cat.percentage * 100).toInt()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.successText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── DONOR LEADERBOARD ───────────────────────────────────────────────────────

  Widget _buildDonorLeaderboard(List<TopDonor> donors) {
    const medals = ['🥇', '🥈', '🥉'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX
        children: donors.map((donor) {
          final medalIndex = (donor.rank - 1).clamp(0, medals.length - 1); // FIX: safe index
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Text(
                  medals[medalIndex],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.light1,
                  child: Text(
                    donor.initials,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.successText,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    donor.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Text(
                  '${donor.itemCount} items',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── ACTIVITY FEED ───────────────────────────────────────────────────────────

  Widget _buildActivityFeed(List<ActivityItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX
        children: items.map((item) => _ActivityRow(item: item)).toList(),
      ),
    );
  }

  // ── BOTTOM NAV ──────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final tabs = [
      _NavTab(icon: Icons.dashboard_outlined,     label: 'Dashboard'),
      _NavTab(icon: Icons.people_outline,         label: 'Users'),
      _NavTab(icon: Icons.card_giftcard_outlined, label: 'Donations'),
      _NavTab(icon: Icons.bar_chart,              label: 'Reports'),
      _NavTab(icon: Icons.settings_outlined,      label: 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.light2, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final isActive = _selectedTab == e.key;
            final tab      = e.value;
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (e.key == 0) {
                      setState(() => _selectedTab = 0);
                    } else {
                      setState(() => _selectedTab = e.key);
                      _navigateTo(_tabTitles[e.key]);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // FIX
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        tab.icon,
                        size: 22,
                        color: isActive ? AppColors.primary : AppColors.light1,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textMuted,
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

// ── SMALL PRIVATE WIDGETS ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String value, label, delta;
  final Color deltaColor;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            delta,
            style: TextStyle(
              fontSize: 10,
              color: deltaColor,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagCard extends StatelessWidget {
  final FlaggedPost post;
  final VoidCallback onRemove, onKeep;

  const _FlagCard({
    required this.post,
    required this.onRemove,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dangerBorder, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.dangerBg,
              child: Text(
                post.initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dangerText,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // FIX
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: AppColors.dangerBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          post.reason,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.dangerText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Posted by ${post.postedBy} · '
                        '${post.reportCount} reports · ${post.timeAgo}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SmallButton(
                        label: 'Remove post',
                        bg: AppColors.dangerBg,
                        fg: AppColors.dangerText,
                        border: AppColors.dangerBorder,
                        onTap: onRemove,
                      ),
                      const SizedBox(width: 6),
                      _SmallButton(
                        label: 'Keep',
                        bg: AppColors.successBg,
                        fg: AppColors.successText,
                        border: AppColors.light2,
                        onTap: onKeep,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color bg, fg, border;
  final VoidCallback onTap;

  const _SmallButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Text(label, style: TextStyle(fontSize: 10, color: fg)),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityItem item;
  const _ActivityRow({required this.item});

  Color get _dotBg {
    switch (item.type) {
      case ActivityType.donation:  return AppColors.successBg;
      case ActivityType.newUser:   return AppColors.blueBg;
      case ActivityType.pending:   return AppColors.amberBg;
      case ActivityType.flagged:   return AppColors.dangerBg;
      case ActivityType.confirmed: return AppColors.successBg;
    }
  }

  Color get _dotFg {
    switch (item.type) {
      case ActivityType.donation:  return AppColors.successText;
      case ActivityType.newUser:   return AppColors.blueText;
      case ActivityType.pending:   return AppColors.amberText;
      case ActivityType.flagged:   return AppColors.dangerText;
      case ActivityType.confirmed: return AppColors.successText;
    }
  }

  IconData get _dotIcon {
    switch (item.type) {
      case ActivityType.donation:  return Icons.card_giftcard_outlined;
      case ActivityType.newUser:   return Icons.person_add_outlined;
      case ActivityType.pending:   return Icons.schedule;
      case ActivityType.flagged:   return Icons.flag_outlined;
      case ActivityType.confirmed: return Icons.check;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: _dotBg, shape: BoxShape.circle),
            child: Icon(_dotIcon, size: 13, color: _dotFg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // FIX
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  _NavTab({required this.icon, required this.label});
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String destination;
  _QuickAction({
    required this.icon,
    required this.label,
    required this.destination,
  });
}
