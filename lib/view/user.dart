import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // ── Brand Colors ──────────────────────────────────────────────
  static const Color kPrimary = Color(0xFF2D5A27);
  static const Color kDark = Color(0xFF1A2F18);
  static const Color kBackground = Color(0xFFF8F7F3);
  static const Color kCard = Colors.white;
  static const Color kTextGrey = Color(0xFF6B7280);

  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          // ── APP BAR ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: kPrimary,
            elevation: 0,
            // ✅ Username shown when collapsed / scrolled down
            title: const Text(
              'Emma Watson',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              // collapseMode keeps the background from sliding oddly
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Cover Photo ───────────────────────────────────
                  Image.network(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1200',
                    fit: BoxFit.cover,
                  ),
                  // ── Gradient overlay ─────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // ── Avatar + Name (visible when expanded) ────────
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 30),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 42,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=500',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emma Watson',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Helping families through donations ❤️',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            // ✅ Three dots wired up as a real options menu
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'share':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share profile tapped')),
                      );
                      break;
                    case 'block':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Block user tapped')),
                      );
                      break;
                    case 'report':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report tapped')),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Share profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Block user'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 20, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Report', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── BODY ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── MESSAGE BUTTON ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Message',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── STATS ────────────────────────────────────────
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatCard(
                        title: 'Rating',
                        value: '4.9',
                        icon: Icons.star,
                      ),
                      _StatCard(
                        title: 'Donated',
                        value: '38',
                        icon: Icons.volunteer_activism,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── ABOUT SECTION ────────────────────────────────
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'Passionate about helping communities by donating clothes, books, furniture, and daily essentials. I believe even small acts of kindness can make a huge difference.',
                      style: TextStyle(
                        color: kTextGrey,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── DONATED ITEMS HEADER ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Donations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── DONATION CARDS ───────────────────────────────
                  const _DonationCard(
                    image:
                    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?q=80&w=1000',
                    title: 'Winter Clothes',
                    location: 'Kathmandu',
                    status: 'Available',
                  ),
                  const SizedBox(height: 16),
                  const _DonationCard(
                    image:
                    'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=1000',
                    title: 'Books for Students',
                    location: 'Lalitpur',
                    status: 'Donated',
                  ),
                  const SizedBox(height: 16),
                  const _DonationCard(
                    image:
                    'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?q=80&w=1000',
                    title: 'Food Supplies',
                    location: 'Bhaktapur',
                    status: 'Reserved',
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// ── STAT CARD ───────────────────────────────────────────────────
// ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2D5A27)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2F18),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// ── DONATION CARD ───────────────────────────────────────────────
// ────────────────────────────────────────────────────────────────
class _DonationCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String status;

  const _DonationCard({
    required this.image,
    required this.title,
    required this.location,
    required this.status,
  });

  // ── Status badge color ────────────────────────────────────────
  Color get _statusBgColor {
    switch (status) {
      case 'Donated':
        return const Color(0xFFE0F2FE);
      case 'Reserved':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFDDE8CF); // Available
    }
  }

  Color get _statusTextColor {
    switch (status) {
      case 'Donated':
        return const Color(0xFF0369A1);
      case 'Reserved':
        return const Color(0xFF92400E);
      default:
        return const Color(0xFF2D5A27); // Available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Image.network(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ── Status Badge ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}