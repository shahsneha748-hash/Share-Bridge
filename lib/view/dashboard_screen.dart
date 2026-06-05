import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharebridge/view/item_data.dart';
import 'package:sharebridge/view/item_detail_screen.dart';



class DashboardScreen extends StatefulWidget {
  final void Function({String? category})? onGoToBrowse;

  const DashboardScreen({super.key, this.onGoToBrowse});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> get featuredItems {
    final available =
    sharedItems.where((i) => i['available'] == true).toList();
    available.sort((a, b) {
      final da = _parseDistance(a['distance']);
      final db = _parseDistance(b['distance']);
      return da.compareTo(db);
    });
    return available.take(4).toList();
  }

  double _parseDistance(dynamic d) {
    if (d == null) return 999;
    final s = d.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 999;
  }

  void _info(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF3A5C2E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _goToBrowse({String? category}) {
    if (widget.onGoToBrowse != null) {
      widget.onGoToBrowse!(category: category);
    } else {
      _info('Browse — Coming Soon');
    }
  }

  void _openItemDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3A5C2E),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF3A5C2E),
        body: SafeArea(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                color: const Color(0xFF3A5C2E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Share Bridge',
                          style: TextStyle(
                            color: Color(0xFFF5F0E8),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hello, friend 👋',
                          style: TextStyle(
                            color: Color(0xFFD4E8C2),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _info('Notifications — Coming Soon'),
                      child: Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F0E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Color(0xFF3A5C2E),
                              size: 26,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFF5F0E8),
                                    width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // WHITE CONTENT
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        // SEARCH (tap → opens Browse tab)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () => _goToBrowse(),
                            child: Container(
                              height: 48,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.2),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.search,
                                      color: Colors.grey, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    'Search for donations...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // IMPACT BANNER
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _impactBanner(),
                        ),

                        const SizedBox(height: 26),

                        // CATEGORIES HEADER — no "View all" link here
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Browse by Category',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2E0A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _categoryCard(
                                      Icons.restaurant, 'Food')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _categoryCard(
                                      Icons.edit, 'Stationery')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _categoryCard(
                                      Icons.checkroom, 'Clothes')),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // FEATURED NEARBY — "View all →" link (renamed from "See all")
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Featured Nearby',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2E0A),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _goToBrowse(),
                                child: const Text(
                                  'View all →',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3A5C2E),
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
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: featuredItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == featuredItems.length - 1
                                      ? 0
                                      : 12,
                                ),
                                child: _featuredCard(featuredItems[index]),
                              );
                            },
                          ),
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

  Widget _impactBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3A5C2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Impact',
                style: TextStyle(
                  color: Color(0xFFD4E8C2),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5F7A45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'This Week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${CommunityStats.itemsShared}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'items shared nearby',
                  style: TextStyle(
                    color: Color(0xFFD4E8C2),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: CommunityStats.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF5F7A45).withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD4E8C2)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Goal: ${CommunityStats.weeklyGoal} items',
            style: const TextStyle(
              color: Color(0xFFD4E8C2),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _goToBrowse(category: label),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4E8C2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF3A5C2E),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E0A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featuredCard(Map<String, dynamic> item) {
    final bool available = item['available'] == true;
    return GestureDetector(
      onTap: () => _openItemDetail(item),
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
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFD4E8C2),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF3A5C2E),
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: available
                            ? const Color(0xFF3A5C2E)
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
                    item['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E0A),
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
                      Text(
                        item['distance'] ?? '—',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
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