import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/constants/colors.dart';
import 'package:sharebridge/components/app_header.dart';
import 'package:sharebridge/components/filter_chip_button.dart';
import 'package:sharebridge/components/category_pill.dart';
import 'package:sharebridge/components/browse_item_card.dart';
import 'package:sharebridge/repo/browse_repo_impl.dart';
import 'package:sharebridge/repo/item_detail_repo_impl.dart';
import 'package:sharebridge/view/item_detail_demo.dart';
import 'package:sharebridge/view/saved_items.dart';
import 'package:sharebridge/viewmodel/browse_view_model.dart';
import 'package:sharebridge/viewmodel/item_detail_view_model.dart';

class BrowseScreen extends StatelessWidget {
  final String? initialCategory;

  const BrowseScreen({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BrowseViewModel(BrowseRepoImpl(), initialCategory: initialCategory),
      child: _BrowseView(initialCategory: initialCategory),
    );
  }
}

class _BrowseView extends StatefulWidget {
  final String? initialCategory;
  const _BrowseView({this.initialCategory});

  @override
  State<_BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<_BrowseView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void didUpdateWidget(covariant _BrowseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      context.read<BrowseViewModel>().updateInitialCategory(widget.initialCategory);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openItemDetail(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailDemoScreen(
          item: item,
          uid: FirebaseAuth.instance.currentUser!.uid,
        ),
      ),
    );
  }


  void _toggleFavorite(BuildContext context, Map<String, dynamic> item) async {
    final browseVm = context.read<BrowseViewModel>();
    final wasSaved = browseVm.isFavorite(item["title"]);

    // Toggle locally
    browseVm.toggleFavorite(item["title"]);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (!wasSaved) {
      // Add to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("saved_items")
          .doc(item["id"])
          .set({
        "id": item["id"],
        "title": item["title"],
        "image": item["image"],
        "category": item["category"],
        "miles": item["miles"],
        "addedTime": item["addedTime"],
        "createdAt": FieldValue.serverTimestamp(),
      });

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to saved'),
          backgroundColor: AppColors.darkGreen,
          duration: Duration(seconds: 1),
        ),
      );

      // 👉 Use root navigator and delay navigation
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const SavedItemsScreen()),
        );
      });

    } else {
      // Remove from Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("saved_items")
          .doc(item["id"])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from saved'),
          backgroundColor: AppColors.darkGreen,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }



  void _openFilterSheet(BuildContext context) {
    final vm = context.read<BrowseViewModel>();
    String tempCategory = vm.selectedCategory;
    String tempDistance = vm.distanceFilter;
    bool tempAvailable = vm.availableOnly;
    String tempSort = vm.sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Widget pill(String text, bool active, VoidCallback onTap) {
              return GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? AppColors.darkGreen : AppColors.backgroundGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Category',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['All', 'Food', 'Clothes', 'Stationery', 'Others']
                            .map((c) => pill(
                          c,
                          tempCategory == c,
                              () => setSheetState(() => tempCategory = c),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Distance',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: ['1 km', '5 km', 'Anywhere']
                            .map((d) => pill(
                          d,
                          tempDistance == d,
                              () => setSheetState(() => tempDistance = d),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Status',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          pill('Available only', tempAvailable,
                                  () => setSheetState(() => tempAvailable = true)),
                          pill('Show all', !tempAvailable,
                                  () => setSheetState(() => tempAvailable = false)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Sort by',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: ['Newest', 'Nearest', 'Available']
                            .map((s) => pill(
                          s,
                          tempSort == s,
                              () => setSheetState(() => tempSort = s),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          vm.applyFilters(
                            category: tempCategory,
                            distance: tempDistance,
                            available: tempAvailable,
                            sort: tempSort,
                          );
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Show ${vm.previewCount(category: tempCategory, distance: tempDistance, available: tempAvailable)} results',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            tempCategory = 'All';
                            tempDistance = 'Anywhere';
                            tempAvailable = false;
                            tempSort = 'Newest';
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: const Text(
                            'Reset all filters',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.darkGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BrowseViewModel>();
    final items = vm.filteredItems;

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
              const AppHeader(title: 'Browse'),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(30),
                            border:
                            Border.all(color: Colors.grey.shade300, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search all items',
                                    hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) => vm.setSearchQuery(v),
                                ),
                              ),
                              if (vm.searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    vm.setSearchQuery('');
                                  },
                                  child: const Icon(Icons.close,
                                      color: Colors.grey, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            FilterChipButton(
                              icon: Icons.tune,
                              label: 'Filters',
                              active: true,
                              onTap: () => _openFilterSheet(context),
                            ),
                            const SizedBox(width: 8),
                            FilterChipButton(
                              label: 'Nearest',
                              active: vm.sortBy == 'Nearest',
                              onTap: vm.toggleSortNearest,
                            ),
                            const SizedBox(width: 8),
                            FilterChipButton(
                              label: 'Available only',
                              active: vm.availableOnly,
                              onTap: vm.toggleAvailableOnly,
                            ),
                            const SizedBox(width: 8),
                            FilterChipButton(
                              label: 'Today',
                              active: vm.todayOnly,
                              onTap: vm.toggleTodayOnly,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            'All',
                            'Food',
                            'Clothes',
                            'Stationery',
                            'Others'
                          ].map((label) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CategoryPill(
                                label: label,
                                active: vm.selectedCategory == label,
                                onTap: () => vm.setCategory(label),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${items.length} items nearby',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.swap_vert,
                                    size: 16, color: AppColors.darkGreen),
                                const SizedBox(width: 4),
                                Text(
                                  vm.sortBy,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                     
                      Expanded(
                        child: items.isEmpty
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 56, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                'No items match your filters',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemBuilder: (ctx, i) {
                              final item = items[i];
                              final title = item['title'].toString();
                              return BrowseItemCard(
                                item: item,
                                isSaved: vm.isFavorite(title),
                                onTap: () => _openItemDetail(context, item),
                                onFavoriteTap: () =>
                                    _toggleFavorite(context, item),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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