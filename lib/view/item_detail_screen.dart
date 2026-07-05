import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/constants/colors.dart';
import 'package:sharebridge/repo/item_detail_repo_impl.dart';
import 'package:sharebridge/repo/review_repo_impl.dart'; // added: concrete ReviewRepo impl
import 'package:sharebridge/view/donation_chat_screen.dart';
import 'package:sharebridge/view/review.dart';
import 'package:sharebridge/view/user_report_screen.dart';
import 'package:sharebridge/viewmodel/item_detail_view_model.dart';
import 'package:sharebridge/viewmodel/review_view_model.dart';
import 'package:sharebridge/utils/chat_helper.dart';
import '../model/notification_model.dart';
import '../service/notification_service.dart';
import '../viewmodel/notification_view_model.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemDetailViewModel(ItemDetailRepoImpl(), item),
      child: const _ItemDetailView(),
    );
  }
}

class _ItemDetailView extends StatefulWidget {
  const _ItemDetailView();

  @override
  State<_ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<_ItemDetailView> {
  bool _isDonorBlocked = false;
  bool _isWishlisted = false;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.darkGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareItem(Map<String, dynamic> item) {
    final title = item['itemName'] ?? 'an item';
    final location = item['location'] ?? '';
    Share.share(
      'Check out "$title" on Share Bridge!${location.isNotEmpty ? '\n📍 $location' : ''}',
    );
  }

  Future<void> _handleMessageTap(BuildContext context) async {
    if (_isDonorBlocked) {
      _snack(context, 'Unblock this donor to send a message');
      return;
    }

    final vm = context.read<ItemDetailViewModel>();
    final item = vm.item;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final donorId = item['donorId'] ?? '';
    final donorName = item['donorName'] ?? 'Donor';
    final donationId = item['id'] ?? '';
    final donationTitle = item['title'] ?? '';

    if (donorId.isEmpty) {
      _snack(context, 'Donor information not available');
      return;
    }

    if (donorId == currentUser.uid) {
      _snack(context, 'This is your own donation');
      return;
    }

    final chatId = await ChatHelper.openChat(
      otherUserId: donorId,
      otherUserName: donorName,
      donationId: donationId,
      donationTitle: donationTitle,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationChatScreen(
            chatId: chatId,
            otherUserId: donorId,
            otherUserName: donorName,
            itemName: donationTitle,
          ),
        ),
      );
    }
  }

  void _showMoreMenu(BuildContext context) {
    final vm = context.read<ItemDetailViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.flag_outlined,
                        color: AppColors.darkGreen),
                    title: const Text('Report'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserReportScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      _isWishlisted
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AppColors.darkGreen,
                    ),
                    title: Text(
                      _isWishlisted
                          ? 'Remove from wishlist'
                          : 'Add to wishlist',
                    ),
                    onTap: () {
                      final newState = !_isWishlisted;
                      setState(() => _isWishlisted = newState);
                      setSheetState(() => _isWishlisted = newState);
                      Navigator.pop(ctx);
                      _snack(
                        context,
                        newState
                            ? 'Added to your wishlist'
                            : 'Removed from your wishlist',
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.block,
                      color: _isDonorBlocked
                          ? AppColors.darkGreen
                          : Colors.redAccent,
                    ),
                    title: Text(
                      _isDonorBlocked ? 'Unblock donor' : 'Block donor',
                      style: TextStyle(
                        color: _isDonorBlocked
                            ? AppColors.darkGreen
                            : Colors.redAccent,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (_isDonorBlocked) {
                        await vm.blockDonor();
                        setState(() => _isDonorBlocked = false);
                        _snack(context, 'Donor unblocked');
                      } else {
                        await vm.blockDonor();
                        setState(() => _isDonorBlocked = true);
                        _snack(context,
                            'Donor blocked. You can no longer message them.');
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestDialog(BuildContext context) {
    final vm = context.read<ItemDetailViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Request this item?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'A request will be sent to ${vm.item['donorName'] ?? 'the donor'}. They will review and respond shortly.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              final notifVm = context.read<NotificationViewModel>();
              final currentUid = FirebaseAuth.instance.currentUser!.uid;
              final senderInfo = await notifVm.getUserById(currentUid);
              final receiverId = vm.item['donorId'] ?? '';
              final receiverInfo = await notifVm.getUserById(receiverId);

              final model = NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: currentUid,
                senderName: senderInfo.fullName,
                profilePicture: senderInfo.profilePicture,
                receiverId: receiverId,
                receiverName: receiverInfo.fullName,
                type: NotificationType.request,
                body:
                '${senderInfo.fullName} has requested for your donation',
                createdAt: DateTime.now(),
                isRead: false,
                postId: vm.item['id'] ?? '',
              );

              final success = await notifVm.sendNotification(model);

              if (success) {
                await NotificationService.display(
                  body: model.body,
                  createdAt: model.createdAt,
                  payload: 'request_system_screen',
                  buildContext: context,
                );
                Fluttertoast.showToast(msg: 'Notification sent successfully');
              } else {
                Fluttertoast.showToast(msg: 'Failed to send notification');
              }
            },
            child: const Text('Send Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenMaps(BuildContext context) async {
    final vm = context.read<ItemDetailViewModel>();
    final opened = await vm.openInMaps();
    if (!opened) {
      _snack(context, 'Location not available for this item');
    }
  }

  void _openFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullImageView(imageUrl: imageUrl),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openReview(BuildContext context, Map<String, dynamic> item) {
    final donationId = item['id'] ?? '';
    final targetUserId = item['donorId'] ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          // Fix: ReviewViewModel requires a ReviewRepo — it was previously
          // constructed with no arguments, which fails to compile because
          // `repository` is a required named parameter.
          create: (_) => ReviewViewModel(repository: ReviewRepoImpl())
            ..getReviewsForUser(targetUserId),
          child: RatingsReviewsPage(
            donationId: donationId,
            targetUserId: targetUserId,
            reviewType: 'donor',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemDetailViewModel>();
    final item = vm.item;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.darkGreen,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.cream,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.darkGreen, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Item Detail',
                          style: TextStyle(
                              color: AppColors.cream,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _shareItem(item),
                        icon: const Icon(Icons.share,
                            color: AppColors.cream, size: 22),
                      ),
                      IconButton(
                        onPressed: () => _showMoreMenu(context),
                        icon: const Icon(Icons.more_vert,
                            color: AppColors.cream, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroImage(
                      item: item,
                      available: vm.available,
                      showExpiry: vm.showExpiry,
                      onImageTap: (url) => _openFullImage(context, url),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        child: _DonorCard(
                          item: item,
                          isBlocked: _isDonorBlocked,
                          onReviewTap: () => _openReview(context, item),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader('Description'),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGreen,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.paleGreen, width: 1),
                            ),
                            child: Text(
                              item['description'] ??
                                  'No description provided.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.descriptionText,
                                height: 1.55,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          if (vm.features.isNotEmpty)
                            _FeatureGrid(features: vm.features),

                          const SizedBox(height: 22),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const _SectionHeader('Pickup Location'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundGreen,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.paleGreen,
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.near_me,
                                        size: 12,
                                        color: AppColors.darkGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item['distance'] ?? '—'} away',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.darkGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundGreen,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.paleGreen, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.location_on,
                                      color: AppColors.darkGreen,
                                      size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ADDRESS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.lightGreen,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['location'] ??
                                            'Location not set',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.darkText,
                                          fontWeight: FontWeight.bold,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          _MapPreview(
                              onTap: () => _handleOpenMaps(context)),

                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _BottomActionBar(
              available: vm.available,
              isBlocked: _isDonorBlocked,
              onMessageTap: _isDonorBlocked
                  ? null
                  : () => _handleMessageTap(context),
              onRequestTap: vm.available && !_isDonorBlocked
                  ? () => _showRequestDialog(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full Screen Image Viewer ──────────────────────────────────────────────────

class _FullImageView extends StatelessWidget {
  final String imageUrl;
  const _FullImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;

  const _FloatingBadge({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool available;
  final bool showExpiry;
  final ValueChanged<String> onImageTap;

  const _HeroImage({
    required this.item,
    required this.available,
    required this.showExpiry,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final List images = item['images'] ?? [];
    final String? imageUrl = images.isNotEmpty ? images[0] : null;

    return Stack(
      children: [
        GestureDetector(
          onTap: imageUrl != null ? () => onImageTap(imageUrl) : null,
          child: SizedBox(
            width: double.infinity,
            height: 320,
            child: imageUrl != null
                ? Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.paleGreen,
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: AppColors.darkGreen, size: 60),
                  ),
                ),
              ),
            )
                : Container(
              color: AppColors.paleGreen,
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    color: AppColors.darkGreen, size: 60),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.darkText.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _FloatingBadge(
                icon: available ? Icons.check_circle : Icons.cancel,
                text: available ? 'Available' : 'Taken',
                bg: AppColors.darkText.withOpacity(0.85),
                fg: Colors.white,
              ),
              if (showExpiry) ...[
                const SizedBox(height: 8),
                _FloatingBadge(
                  icon: Icons.access_time,
                  text: 'Expiring ${item['expires']}',
                  bg: AppColors.expiryBg,
                  fg: AppColors.expiryText,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 36,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.paleGreen.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['subcategory']?.toString().toUpperCase() ??
                        item['category']?.toString().toUpperCase() ??
                        'GENERAL',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['title'] ?? 'Item',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                    shadows: [
                      Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DonorCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isBlocked;
  final VoidCallback onReviewTap;

  const _DonorCard({
    required this.item,
    required this.isBlocked,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isBlocked ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.paleGreen, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkText.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.darkGreen,
                  child: Text(
                    (item['donorName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.onlineDot,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.backgroundGreen, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['donorName'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.darkText),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.ratingStar, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${item['donorRating'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText),
                      ),
                      Text(
                        '  ·  ${item['donorDonations'] ?? '0'} donations',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.lightGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isBlocked)
              GestureDetector(
                onTap: onReviewTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final List<Map<String, dynamic>> features;
  const _FeatureGrid({required this.features});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < features.length; i += 2) {
      final left = features[i];
      final right = i + 1 < features.length ? features[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: _FeatureChip(feature: left)),
              const SizedBox(width: 10),
              Expanded(
                child: right != null
                    ? _FeatureChip(feature: right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _FeatureChip extends StatelessWidget {
  final Map<String, dynamic> feature;
  const _FeatureChip({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.paleGreen, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature['icon'] as IconData,
                size: 18, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  feature['label'] as String,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.lightGreen,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  feature['value'].toString(),
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final VoidCallback onTap;
  const _MapPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.paleGreen, width: 1),
          ),
          child: Stack(
            children: [
              CustomPaint(
                  size: Size.infinite, painter: _MapDecorPainter()),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundGreen.withOpacity(0.35),
                ),
              ),
              const Center(
                child: Icon(Icons.location_pin,
                    color: AppColors.darkGreen, size: 42),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkText.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions,
                            size: 15, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Open in Maps',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mapGridLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double y = 20; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 20; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final road = Paint()
      ..color = AppColors.mapRoadLine
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.3),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BottomActionBar extends StatelessWidget {
  final bool available;
  final bool isBlocked;
  final VoidCallback? onMessageTap;
  final VoidCallback? onRequestTap;

  const _BottomActionBar({
    required this.available,
    required this.isBlocked,
    required this.onMessageTap,
    required this.onRequestTap,
  });

  static const double _buttonHeight = 54;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onMessageTap,
                child: Container(
                  height: _buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isBlocked
                        ? Colors.grey.shade200
                        : AppColors.backgroundGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isBlocked
                            ? Colors.grey.shade300
                            : AppColors.paleGreen,
                        width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isBlocked
                            ? Icons.block
                            : Icons.chat_bubble_outline,
                        color: isBlocked
                            ? Colors.grey.shade500
                            : AppColors.darkText,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBlocked ? 'Blocked' : 'Message',
                        style: TextStyle(
                            color: isBlocked
                                ? Colors.grey.shade500
                                : AppColors.darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: onRequestTap,
                child: Container(
                  height: _buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: onRequestTap != null
                        ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.darkGreen,
                        AppColors.darkText,
                      ],
                    )
                        : null,
                    color: onRequestTap == null
                        ? Colors.grey.shade400
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: onRequestTap != null
                        ? [
                      BoxShadow(
                        color: AppColors.darkText.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volunteer_activism,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isBlocked
                            ? 'Donor Blocked'
                            : (onRequestTap != null
                            ? 'Request Item'
                            : 'Not Available'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
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
}