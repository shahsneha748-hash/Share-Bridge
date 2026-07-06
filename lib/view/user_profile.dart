import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:sharebridge/constants/colors.dart'; // adjust path to match your project
import 'package:sharebridge/viewmodel/my_profile_viewmodel.dart';

import 'my_donation_screen.dart';
import 'my_review_screen.dart';
import 'user_setting_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyProfileViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyProfileViewModel>();
    final profile = vm.profile;

    return Scaffold(
      backgroundColor: AppColors.profileLight,
      body: SafeArea(
        child: (vm.loading && profile == null)
            ? const Center(child: CircularProgressIndicator(color: AppColors.profilePrimary))
            : Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<MyProfileViewModel>().fetchProfile(),
                color: AppColors.profilePrimary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      _buildProfileHeader(profile),
                      _buildBioCard(profile),
                      const SizedBox(height: 16),
                      _buildStatsRow(profile),
                      const SizedBox(height: 16),
                      _buildImpactCard(profile),
                      const SizedBox(height: 16),
                      _buildMenuSection(profile),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.darkGreen),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.darkGreen),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;

    if (!mounted) return;
    context.read<MyProfileViewModel>().updateProfilePicture(pickedFile.path);
  }


  void _openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.9),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4,
                        child: Image.network(imageUrl),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
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



  // ─────────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: AppColors.profilePrimary,
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
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE HEADER
  Widget _buildProfileHeader(profile) {
    final name = (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName : 'Guest User';
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final location = (profile?.address.isNotEmpty ?? false) ? profile!.address : 'Location not set';
    final phone = (profile?.phone.isNotEmpty ?? false) ? profile!.phone : 'Phone not set';
    final hasPic = profile?.profilePicture != null && profile!.profilePicture!.isNotEmpty;
    final isVerified = profile?.isVerified ?? false;
    final memberSinceYear = profile?.memberSinceYear ?? DateTime.now().year;

    return Container(
      color: AppColors.profilePrimary,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: hasPic ? () => _openFullScreenImage(profile!.profilePicture!) : null,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: const Color(0xFF4A7A44),
                    image: hasPic
                        ? DecorationImage(
                      image: NetworkImage(profile!.profilePicture!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: hasPic
                      ? null
                      : Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.onlineDot,
                      shape: BoxShape.circle,
                    ),
                    child: context.watch<MyProfileViewModel>().uploadingPhoto
                        ? const Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                        : const Icon(Icons.edit, color: AppColors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: isVerified ? const Color(0xFFFFD700) : Colors.white54,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  'Community Member · Since $memberSinceYear',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard(profile) {
    final bio = profile?.bio ?? '';
    final hasBio = bio.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkGreen,
                    AppColors.lightGreen,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "About Me",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Bio content
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: hasBio
                          ? AppColors.darkText
                          : AppColors.textMuted,
                      fontStyle:
                      hasBio ? FontStyle.normal : FontStyle.italic,
                    ),
                    child: Text(
                      hasBio
                          ? bio
                          : "No bio yet. Tell people a bit about yourself ",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // STATS ROW
  Widget _buildStatsRow(profile) {
    final totalDonations = profile?.totalDonations ?? 0;
    final stats = [
      {'label': 'Items Shared', 'value': '$totalDonations', 'icon': Icons.volunteer_activism},
      {'label': 'Received',     'value': '0', 'icon': Icons.card_giftcard},
      {'label': 'Wishlist',        'value': '0', 'icon': Icons.favorite_outline},
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
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.profilePrimary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(s['icon'] as IconData, color: AppColors.profilePrimary, size: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['value'] as String,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.profileTextDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
                    style: const TextStyle(fontSize: 11, color: AppColors.profileTextGrey),
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

  // IMPACT CARD
  Widget _buildImpactCard(profile) {
    final totalDonations = profile?.totalDonations ?? 0;
    const goal = 100;
    final progress = (totalDonations / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.profileDark, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Community Impact',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('This Month', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$totalDonations',
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1.1),
            ),
            const Text('items shared nearby', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.onlineDot),
              ),
            ),
            const SizedBox(height: 6),
            const Text('Goal: 100 items', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // MENU SECTION
  Widget _buildMenuSection(profile) {
    final totalDonations = profile?.totalDonations ?? 0;
    final rating = profile?.rating ?? 0;

    final sections = [
      {
        'title': 'Activity',
        'items': [
          {
            'icon': Icons.history,
            'label': 'My Donations',
            'subtitle': '$totalDonations items shared',
            'onTap': () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyDonationsScreen(uid: uid)));
              }
            },
          },
          {
            'icon': Icons.favorite_outline,
            'label': 'Wishlist',
            'subtitle': '0 saved',
            'onTap': () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved Items — coming soon')),
              );
            },
          },
          {
            'icon': Icons.star_outline,
            'label': 'Reviews',
            'subtitle': '${(rating as num).toStringAsFixed(1)} ★',
            'onTap': () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyReviewsScreen(uid: uid)));
              }
            },
          },
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.profileTextGrey, letterSpacing: 0.8),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: (section['items'] as List<Map<String, dynamic>>).asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isLast = i == (section['items'] as List).length - 1;
                    return Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.vertical(
                            top: i == 0 ? const Radius.circular(14) : Radius.zero,
                            bottom: isLast ? const Radius.circular(14) : Radius.zero,
                          ),
                          onTap: item['onTap'] as void Function()?,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.profilePrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(item['icon'] as IconData, color: AppColors.profilePrimary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['label'] as String,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.profileTextDark),
                                      ),
                                      if ((item['subtitle'] as String).isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item['subtitle'] as String,
                                          style: const TextStyle(fontSize: 12, color: AppColors.profileTextGrey),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.profileTextGrey, size: 18),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) const Divider(height: 1, indent: 64, color: AppColors.profileDivider),
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
}