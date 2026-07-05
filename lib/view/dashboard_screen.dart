import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/constants/colors.dart';
import 'package:sharebridge/repo/dashboard_repo_impl.dart';
import 'package:sharebridge/components/app_header.dart';
import 'package:sharebridge/components/category_card.dart';
import 'package:sharebridge/view/item_detail_screen.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/view/volunteer_intro_screen.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import '../viewmodel/dashboard_view_model.dart';

class DashboardScreen extends StatefulWidget {
  final void Function({String? category})? onGoToBrowse;

  const DashboardScreen({super.key, this.onGoToBrowse});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // One-time setup on first load goes here (e.g. mark notifications
    // as seen, fetch a badge count, log analytics, etc.)
  }

  @override
  void dispose() {
    // Clean up any controllers/subscriptions started in initState here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(DashboardRepoImpl()),
      child: _DashboardView(onGoToBrowse: widget.onGoToBrowse),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _DashboardView extends StatelessWidget {
  final void Function({String? category})? onGoToBrowse;

  const _DashboardView({this.onGoToBrowse});

  void _showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.darkGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _goToBrowse(BuildContext context, {String? category}) {
    if (onGoToBrowse != null) {
      onGoToBrowse!(category: category);
    } else {
      _showSnackbar(context, 'Browse — Coming Soon');
    }
  }

  void _openItemDetail(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)
      ),
    );
  }

  void _openVolunteer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VolunteerIntroScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  Widget _notificationBell(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (context, vm, child) {
        return GestureDetector(
          onTap: () => _openNotifications(context),
          child: Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: AppColors.darkGreen,
                  size: 26,
                ),
              ),
              // Show badge only if unreadCount > 0
              if (vm.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cream, width: 2),
                    ),
                    child: Text(
                      vm.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkGreen,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Share Bridge',
                trailing: _notificationBell(context),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        _SearchBar(onTap: () => _goToBrowse(context)),

                        const SizedBox(height: 26),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _VolunteerBanner(
                            onTap: () => _openVolunteer(context),
                          ),
                        ),

                        const SizedBox(height: 26),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Browse by Category',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: CategoryCard(
                                  icon: Icons.restaurant,
                                  label: 'Food',
                                  onTap: () =>
                                      _goToBrowse(context, category: 'Food'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CategoryCard(
                                  icon: Icons.edit,
                                  label: 'Stationery',
                                  onTap: () => _goToBrowse(context,
                                      category: 'Stationery'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CategoryCard(
                                  icon: Icons.checkroom,
                                  label: 'Clothes',
                                  onTap: () => _goToBrowse(context,
                                      category: 'Clothes'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'New Arrivals',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _goToBrowse(context),
                                child: const Text(
                                  'View all →',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: Builder(builder: (context) {
                            if (vm.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(color: AppColors.darkGreen),
                              );
                            }
                            if (vm.featuredItems.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No items available.',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: vm.featuredItems.length,
                              itemBuilder: (context, index) {
                                final item = vm.featuredItems[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index == vm.featuredItems.length - 1 ? 0 : 12,
                                  ),
                                  child: _FeaturedCard(
                                    item: item,
                                    onTap: () => _openItemDetail(context, item),
                                  ),
                                );
                              },
                            );
                          }),
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

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.grey, size: 22),
              SizedBox(width: 10),
              Text(
                'Search for donations...',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Volunteer Banner ─────────────────────────────────────────────────────────

class _VolunteerBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _VolunteerBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Volunteer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Up for volunteering?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Lend a hand with pickups, deliveries, or donation drives in your community.',
              style: TextStyle(
                color: AppColors.paleGreen,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Get involved',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured Card ─────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _FeaturedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List images = item['images'] ?? [];
    final bool available = item['isDonated'] != true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: images.isNotEmpty
                          ? Image.network(
                        images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: AppColors.paleGreen,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.darkGreen,
                                size: 36,
                              ),
                            ),
                          );
                        },
                      )
                          : Container(
                        color: AppColors.paleGreen,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.darkGreen,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: available
                            ? AppColors.darkGreen
                            : Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        available ? 'Available' : 'Taken',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['itemName'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          item['location'] ?? 'No location',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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