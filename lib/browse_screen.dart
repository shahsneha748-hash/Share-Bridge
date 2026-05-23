import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/item_data.dart';
import 'package:project/item_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialCategory;

  const BrowseScreen({super.key, this.initialCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Newest';
  String _distanceFilter = 'Anywhere';
  bool _availableOnly = false;
  bool _todayOnly = false;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void didUpdateWidget(covariant BrowseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null &&
        widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredItems {
    var list = List<Map<String, dynamic>>.from(sharedItems);

    if (_selectedCategory != 'All') {
      list = list.where((i) => i['category'] == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((i) {
        return i['title']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_availableOnly) {
      list = list.where((i) => i['available'] == true).toList();
    }

    if (_todayOnly) {
      list = list.where((i) {
        final exp = i['expires']?.toString() ?? '';
        return exp.contains('h');
      }).toList();
    }

    if (_distanceFilter != 'Anywhere') {
      final maxKm = _distanceFilter == '1 km' ? 1.0 : 5.0;
      list = list.where((i) {
        final d = _parseDistance(i['distance']);
        final km = d * 1.6;
        return km <= maxKm;
      }).toList();
    }

    if (_sortBy == 'Nearest') {
      list.sort((a, b) => _parseDistance(a['distance'])
          .compareTo(_parseDistance(b['distance'])));
    } else if (_sortBy == 'Newest') {
      list.sort((a, b) => (a['expires'] ?? 'zz')
          .toString()
          .compareTo((b['expires'] ?? 'zz').toString()));
    } else if (_sortBy == 'Available') {
      list.sort((a, b) {
        if (a['available'] == b['available']) return 0;
        return a['available'] == true ? -1 : 1;
      });
    }

    return list;
  }

  double _parseDistance(dynamic d) {
    if (d == null) return 999;
    final s = d.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 999;
  }

  void _openItemDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item),
      ),
    ).then((_) => setState(() {}));
  }

  void _toggleFavorite(String title) {
    final wasFav = Favorites.isFavorite(title);
    setState(() {
      Favorites.toggle(title);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text(wasFav ? 'Removed from favorites' : 'Saved to favorites'),
        backgroundColor: const Color(0xFF3A5C2E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openFilterSheet() {
    String tempCategory = _selectedCategory;
    String tempDistance = _distanceFilter;
    bool tempAvailable = _availableOnly;
    String tempSort = _sortBy;

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF3A5C2E)
                        : const Color(0xFFEFF5E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF1A2E0A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
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
                          color: Color(0xFF1A2E0A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Category',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2E0A))),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All',
                          'Food',
                          'Clothes',
                          'Stationery',
                          'Others'
                        ]
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
                              color: Color(0xFF1A2E0A))),
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
                              color: Color(0xFF1A2E0A))),
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
                              color: Color(0xFF1A2E0A))),
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
                          setState(() {
                            _selectedCategory = tempCategory;
                            _distanceFilter = tempDistance;
                            _availableOnly = tempAvailable;
                            _sortBy = tempSort;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A5C2E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Show ${_previewCount(tempCategory, tempDistance, tempAvailable)} results',
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
                              color: Color(0xFF3A5C2E),
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

  int _previewCount(String cat, String dist, bool avail) {
    var list = List<Map<String, dynamic>>.from(sharedItems);
    if (cat != 'All') {
      list = list.where((i) => i['category'] == cat).toList();
    }
    if (avail) {
      list = list.where((i) => i['available'] == true).toList();
    }
    if (dist != 'Anywhere') {
      final maxKm = dist == '1 km' ? 1.0 : 5.0;
      list = list.where((i) {
        final d = _parseDistance(i['distance']) * 1.6;
        return d <= maxKm;
      }).toList();
    }
    return list.length;
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredItems;

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
              // ===== HEADER (just title, like Home) =====
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
                          'Browse',
                          style: TextStyle(
                            color: Color(0xFFF5F0E8),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Find what you need nearby',
                          style: TextStyle(
                            color: Color(0xFFD4E8C2),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ===== WHITE CONTENT =====
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),

                      // SEARCH BAR (now in white area, like Home)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            children: [
                              const Icon(Icons.search,
                                  color: Colors.grey, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: false,
                                  decoration: const InputDecoration(
                                    hintText: 'Search all items',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) {
                                    setState(() => _searchQuery = v);
                                  },
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Icon(Icons.close,
                                      color: Colors.grey, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Filter chips row
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _filterChip(
                              icon: Icons.tune,
                              label: 'Filters',
                              active: true,
                              onTap: _openFilterSheet,
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              label: 'Nearest',
                              active: _sortBy == 'Nearest',
                              onTap: () => setState(() => _sortBy =
                              _sortBy == 'Nearest' ? 'Newest' : 'Nearest'),
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              label: 'Available only',
                              active: _availableOnly,
                              onTap: () => setState(
                                      () => _availableOnly = !_availableOnly),
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              label: 'Today',
                              active: _todayOnly,
                              onTap: () =>
                                  setState(() => _todayOnly = !_todayOnly),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Category row
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _categoryPill('All'),
                            const SizedBox(width: 8),
                            _categoryPill('Food'),
                            const SizedBox(width: 8),
                            _categoryPill('Clothes'),
                            const SizedBox(width: 8),
                            _categoryPill('Stationery'),
                            const SizedBox(width: 8),
                            _categoryPill('Others'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Item count + sort
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${items.length} items nearby',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2E0A),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.swap_vert,
                                    size: 16, color: Color(0xFF3A5C2E)),
                                const SizedBox(width: 4),
                                Text(
                                  _sortBy,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3A5C2E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // GRID
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
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
                            itemBuilder: (ctx, i) => _itemCard(items[i]),
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

  Widget _filterChip({
    IconData? icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3A5C2E) : const Color(0xFFEFE9D5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: active ? Colors.white : const Color(0xFF1A2E0A)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF1A2E0A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryPill(String label) {
    final bool active = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3A5C2E) : const Color(0xFFEFF5E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF1A2E0A),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final bool available = item['available'] == true;
    final String title = item['title'].toString();
    final bool isFav = Favorites.isFavorite(title);

    return GestureDetector(
      onTap: () => _openItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4E8C2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: available
                          ? const Color(0xFFD4E8C2)
                          : const Color(0xFFFDD7D7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      available ? 'Available' : 'Taken',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: available
                            ? const Color(0xFF2D5016)
                            : Colors.redAccent,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleFavorite(title),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFav),
                        size: 20,
                        color:
                        isFav ? Colors.redAccent : const Color(0xFF3A5C2E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFD4E8C2),
                    child: Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
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
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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