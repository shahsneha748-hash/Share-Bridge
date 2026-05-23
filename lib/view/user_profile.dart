import 'package:flutter/material.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Brand Colors ──────────────────────────────────────────────
  static const Color kPrimary    = Color(0xFF2D5A27);
  static const Color kDark       = Color(0xFF1A3A15);
  static const Color kLight      = Color(0xFFF5F7F4);
  static const Color kCard       = Color(0xFFFFFFFF);
  static const Color kAccent     = Color(0xFF4CAF50);
  static const Color kTextDark   = Color(0xFF1C2B1A);
  static const Color kTextGrey   = Color(0xFF7A8A78);
  static const Color kDivider    = Color(0xFFE8EDE7);

  int _selectedIndex = 4; // Profile tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────
            _buildAppBar(),
            // ── Scrollable Body ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildImpactCard(),
                    const SizedBox(height: 16),
                    _buildMenuSection(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ── Bottom Nav ───────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: kPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PROFILE HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      color: kPrimary,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          // Avatar + edit button
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: const Color(0xFF4A7A44),
                ),
                child: const Center(
                  child: Text(
                    'D',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Daty Friend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Kathmandu, Nepal',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Member badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified, color: Color(0xFFFFD700), size: 15),
                SizedBox(width: 5),
                Text(
                  'Community Member · Since 2024',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Items Shared', 'value': '34', 'icon': Icons.volunteer_activism},
      {'label': 'Received',     'value': '12', 'icon': Icons.card_giftcard},
      {'label': 'Saved',        'value': '28', 'icon': Icons.bookmark_outline},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s['icon'] as IconData,
                        color: kPrimary, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['value'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kTextGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // IMPACT CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildImpactCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Community Impact',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '46',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const Text(
              'items shared nearby',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.46,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor:
                const AlwaysStoppedAnimation<Color>(kAccent),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Goal: 100 items',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MENU SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildMenuSection() {
    final sections = [
      {
        'title': 'Account',
        'items': [
          {'icon': Icons.person_outline,      'label': 'Edit Profile',         'subtitle': 'Update your info'},
          {'icon': Icons.location_on_outlined, 'label': 'My Location',          'subtitle': 'Kathmandu, Nepal'},
          {'icon': Icons.notifications_outlined,'label': 'Notifications',       'subtitle': 'Manage alerts'},
        ],
      },
      {
        'title': 'Activity',
        'items': [
          {'icon': Icons.history,              'label': 'My Donations',         'subtitle': '34 items shared'},
          {'icon': Icons.favorite_outline,     'label': 'Saved Items',          'subtitle': '28 saved'},
          {'icon': Icons.star_outline,         'label': 'Reviews',              'subtitle': '4.8 ★  (12 reviews)'},
        ],
      },
      {
        'title': 'Support',
        'items': [
          {'icon': Icons.help_outline,         'label': 'Help & FAQ',           'subtitle': 'Get assistance'},
          {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy',       'subtitle': ''},
          {'icon': Icons.info_outline,         'label': 'About Share Bridge',   'subtitle': 'v1.2.0'},
        ],
      },
    ];

    return Column(
      children: sections.map((section) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  section['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kTextGrey,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children:
                  (section['items'] as List<Map<String, dynamic>>)
                      .asMap()
                      .entries
                      .map((entry) {
                    final i    = entry.key;
                    final item = entry.value;
                    final isLast = i ==
                        (section['items'] as List).length - 1;
                    return Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.vertical(
                            top: i == 0
                                ? const Radius.circular(14)
                                : Radius.zero,
                            bottom: isLast
                                ? const Radius.circular(14)
                                : Radius.zero,
                          ),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: kPrimary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['label'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kTextDark,
                                        ),
                                      ),
                                      if ((item['subtitle'] as String)
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item['subtitle'] as String,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kTextGrey,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: kTextGrey,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            indent: 64,
                            color: kDivider,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT BUTTON
  // ─────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Log Out',
              style:
              TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined,       'activeIcon': Icons.home,         'label': 'Home'},
      {'icon': Icons.search,              'activeIcon': Icons.search,        'label': 'Browse'},
      {'icon': Icons.add_circle_outline,  'activeIcon': Icons.add_circle,   'label': 'Post'},
      {'icon': Icons.inventory_2_outlined,'activeIcon': Icons.inventory_2,  'label': 'My Items'},
      {'icon': Icons.person_outline,      'activeIcon': Icons.person,        'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final idx  = entry.key;
              final item = entry.value;
              final sel  = idx == _selectedIndex;

              // Centre "Post" button with accent circle
              if (idx == 2) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = idx),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['activeIcon'] as IconData,
                        color: Colors.white, size: 26),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = idx),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sel
                          ? item['activeIcon'] as IconData
                          : item['icon'] as IconData,
                      color: sel ? kPrimary : kTextGrey,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: sel
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: sel ? kPrimary : kTextGrey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}