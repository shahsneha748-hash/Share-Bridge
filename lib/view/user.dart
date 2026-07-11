import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/constants/colors.dart'; // adjust path to match your project
import 'package:sharebridge/viewmodel/other_profile_view_model.dart';
import '../components/app_header.dart';
import '../components/volunteer_badge_section.dart';
import '../viewmodel/block_view_model.dart';
import 'donation_chat_screen.dart';
import 'my_donation_screen.dart';
import 'my_review_screen.dart';
import 'user_report_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtherProfileViewModel>().fetchProfile(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OtherProfileViewModel>();
    final profile = vm.profile;

    return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
    statusBarColor: AppColors.darkGreen,
    statusBarIconBrightness: Brightness.light,
    ),
    child: Scaffold(
    backgroundColor: AppColors.background,
    body: (vm.loading && profile == null)
            ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary))
            : (vm.error != null && profile == null)
            ? _buildErrorState(vm.error!)
            : Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
              color: AppColors.darkGreen,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.darkGreen,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        (profile?.fullName.isNotEmpty ?? false)
                            ? profile!.fullName
                            : 'Profile',
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showMoreOptionsSheet(context),
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context
                    .read<OtherProfileViewModel>()
                    .fetchProfile(widget.uid),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    children: [
                      _buildProfileHeader(profile),
                      const SizedBox(height: 20),
                      if (vm.isBlocked) ...[
                        _buildBlockedBanner(vm),
                        const SizedBox(height: 16),
                      ] else
                        _buildContactBar(profile),
                      const SizedBox(height: 20),
                      _buildBioCard(profile),
                      const SizedBox(height: 12),
                      _buildImpactCard(profile),
                      const SizedBox(height: 12),
                      if (!vm.isBlocked) ...[
                        VolunteerBadgesSection(uid: widget.uid),
                        const SizedBox(height: 12),
                      ],
                      _buildMenuSection(profile, isBlocked: vm.isBlocked),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () =>
                  context.read<OtherProfileViewModel>().fetchProfile(widget.uid),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptionsSheet(BuildContext context) {
    final vm = context.read<OtherProfileViewModel>();
    final isBlocked = vm.isBlocked;

    showModalBottomSheet(
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
                leading: const Icon(Icons.flag_outlined, color: AppColors.dangerText),
                title: const Text('Report user'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserReportScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  isBlocked ? Icons.person_add_alt_1 : Icons.block,
                  color: AppColors.dangerText,
                ),
                title: Text(isBlocked ? 'Unblock user' : 'Block user'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmToggleBlock(context, isBlocked: isBlocked);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmToggleBlock(BuildContext context, {required bool isBlocked}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBlocked ? 'Unblock this user?' : 'Block this user?'),
        content: Text(
          isBlocked
              ? "They'll be able to message you and see your listings again."
              : "They won't be able to message you, and you won't see each other's listings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
            child: Text(isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final blockVM = context.read<BlockViewModel>();

    final success = isBlocked
        ? await blockVM.unblockUser(
      FirebaseAuth.instance.currentUser!.uid,
      widget.uid,
    )
        : await blockVM.blockUser(
      FirebaseAuth.instance.currentUser!.uid,
      widget.uid,
      fullName: context.read<OtherProfileViewModel>().profile?.fullName,
      profilePicture: context.read<OtherProfileViewModel>().profile?.profilePicture,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isBlocked ? 'User unblocked' : 'User blocked')
              : 'Something went wrong. Please try again.',
        ),
      ),
    );
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
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
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

  // PROFILE HEADER — plain background, single accent color, no green block
  Widget _buildProfileHeader(profile) {
    final name =
    (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName : 'User';
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final location =
    (profile?.address.isNotEmpty ?? false) ? profile!.address : 'Location not set';
    final hasPic =
        profile?.profilePicture != null && profile!.profilePicture!.isNotEmpty;
    final isVerified = profile?.isVerified ?? false;
    final memberSinceYear = profile?.memberSinceYear ?? DateTime.now().year;
    final rating = (profile?.rating ?? 0) as num;

    return Column(
      children: [
        GestureDetector(
          onTap: hasPic ? () => _openFullScreenImage(profile!.profilePicture!) : null,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: AppColors.light2,
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
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 4),
            Text(location, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _headerChip(
              icon: Icons.verified,
              iconColor: isVerified ? AppColors.primary : AppColors.textMuted,
              label: 'Community Member Since $memberSinceYear',
            ),
            const SizedBox(width: 8),
            _headerChip(
              icon: Icons.star,
              iconColor: AppColors.ratingStar,
              label: rating.toStringAsFixed(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerChip({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // BLOCKED BANNER — shown instead of the Message button once blocked
  Widget _buildBlockedBanner(OtherProfileViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.block, color: AppColors.dangerText, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "You've blocked this user",
              style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: vm.blockActionInProgress
                ? null
                : () => _confirmToggleBlock(context, isBlocked: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerText),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  // CONTACT BAR
  Widget _buildContactBar(profile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final currentUserId =
              FirebaseAuth.instance.currentUser!.uid;

          final otherUserId = widget.uid;

          // Create same chat id for both users
          final chatId = currentUserId.compareTo(otherUserId) < 0
              ? '${currentUserId}_$otherUserId'
              : '${otherUserId}_$currentUserId';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationChatScreen(
                chatId: chatId,
                otherUserId: otherUserId,
                otherUserName: profile?.fullName ?? "User",
                itemName: "General Chat",
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text('Message'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBioCard(profile) {
    final bio = profile?.bio ?? '';
    final hasBio = bio.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                "About",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasBio ? bio : "This user hasn't added a bio yet.",
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: hasBio ? AppColors.textDark : AppColors.textMuted,
              fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // IMPACT CARD — light card, accent used only as a highlight, not a solid block
  Widget _buildImpactCard(profile) {
    final totalDonations = profile?.totalDonations ?? 0;
    const goal = 100;
    final progress = (totalDonations / goal).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Community Impact',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalDonations',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Text('items shared nearby',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.light2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Goal: 100 items', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  // MENU — Donations & Reviews rows, no section header, reuses
  // MyDonationsScreen/MyReviewsScreen with the *viewed* uid
  Widget _buildMenuSection(profile, {required bool isBlocked}) {
    final totalDonations = profile?.totalDonations ?? 0;
    final rating = profile?.rating ?? 0;
    final items = [
      {
        'icon': Icons.history,
        'label': 'Donations',
        'subtitle': '$totalDonations items shared',
        'onTap': isBlocked
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyDonationsScreen(uid: widget.uid)),
          );
        },
      },
      {
        'icon': Icons.star_outline,
        'label': 'Reviews',
        'subtitle': '${(rating as num).toStringAsFixed(1)} ★',
        'onTap': isBlocked
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyReviewsScreen(uid: widget.uid)),
          );
        },
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          final onTap = item['onTap'] as void Function()?;
          final disabled = onTap == null;
          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(14) : Radius.zero,
                  bottom: isLast ? const Radius.circular(14) : Radius.zero,
                ),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData,
                          color: disabled ? AppColors.textMuted : AppColors.primary, size: 19),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: disabled ? AppColors.textMuted : AppColors.textDark,
                              ),
                            ),
                            if ((item['subtitle'] as String).isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!disabled)
                        const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                    ],
                  ),
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 50, color: AppColors.borderLight),
            ],
          );
        }).toList(),
      ),
    );
  }
}

