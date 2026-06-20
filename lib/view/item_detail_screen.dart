import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isFollowing = false;

  // Theme palette
  static const Color cDarkGreen = Color(0xFF3A5C2E);
  static const Color cDeepGreen = Color(0xFF1A2E0A);
  static const Color cMidGreen = Color(0xFF5F7A45);
  static const Color cSoftGreen = Color(0xFFEFF5E8);
  static const Color cMintGreen = Color(0xFFD4E8C2);
  static const Color cBeige = Color(0xFFF5F0E8);

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: cDarkGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openInMaps() async {
    final item = widget.item;
    final double? lat = (item['mapLat'] as num?)?.toDouble();
    final double? lng = (item['mapLng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      _snack('Location not available for this item');
      return;
    }

    final Uri googleMapsApp = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final Uri geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsApp)) {
        await launchUrl(googleMapsApp, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else {
        _snack('Could not open Maps. Please install Google Maps.');
      }
    } catch (e) {
      _snack('Error opening Maps');
    }
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: cDarkGreen),
                title: const Text('Report this item'),
                onTap: () {
                  Navigator.pop(ctx);
                  _snack('Reported. Thank you for keeping us safe.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline, color: cDarkGreen),
                title: const Text('Save for later'),
                onTap: () {
                  Navigator.pop(ctx);
                  _snack('Saved to your bookmarks');
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: const Text('Block donor',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  _snack('Donor blocked');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Request this item?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'A request will be sent to ${widget.item['donorName'] ?? 'the donor'}. They will review and respond shortly.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cDarkGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _snack('Request sent to donor!');
            },
            child: const Text('Send Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool available = item['available'] == true;

    final bool showExpiry = (item['category'] == 'Food') &&
        (item['expires'] != null) &&
        (item['expires'].toString().isNotEmpty);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: cDarkGreen,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        // ===== Back to clean WHITE background =====
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              color: cDarkGreen,
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
                            color: cBeige,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: cDarkGreen, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Item Detail',
                          style: TextStyle(
                            color: cBeige,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _snack('Sharing link copied!'),
                        icon: const Icon(Icons.share, color: cBeige, size: 22),
                      ),
                      IconButton(
                        onPressed: _showMoreMenu,
                        icon: const Icon(Icons.more_vert,
                            color: cBeige, size: 22),
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
                    // ===== HERO IMAGE (UNCHANGED) =====
                    _heroImage(item, available, showExpiry),

                    // ===== DONOR CARD overlapping hero =====
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        child: _donorCard(item),
                      ),
                    ),

                    // ===== BODY CONTENT =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== DESCRIPTION =====
                          _sectionHeader('Description'),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cSoftGreen,
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: cMintGreen, width: 1),
                            ),
                            child: Text(
                              item['description'] ??
                                  'No description provided.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3D4A35),
                                height: 1.55,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ===== DETAILS =====
                          _featureGrid(item),

                          const SizedBox(height: 22),

                          // ===== PICKUP LOCATION =====
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _sectionHeader('Pickup Location'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: cSoftGreen,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: cMintGreen, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.near_me,
                                        size: 12, color: cDarkGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item['distance'] ?? '—'} away',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: cDarkGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Address card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cSoftGreen,
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: cMintGreen, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color: cDarkGreen, size: 18),
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
                                          color: cMidGreen,
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
                                          color: cDeepGreen,
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

                          // Map preview
                          _mapPreview(),

                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _bottomActionBar(available),
          ],
        ),
      ),
    );
  }

  // ===== HERO IMAGE (UNCHANGED) =====
  Widget _heroImage(
      Map<String, dynamic> item, bool available, bool showExpiry) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 320,
          child: Image.asset(
            item['image'],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: cMintGreen,
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    color: cDarkGreen, size: 60),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  cDeepGreen.withValues(alpha: 0.85),
                ],
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
              _floatingBadge(
                icon: available ? Icons.check_circle : Icons.cancel,
                text: available ? 'Available' : 'Taken',
                bg: cDeepGreen.withValues(alpha: 0.85),
                fg: Colors.white,
              ),
              if (showExpiry) ...[
                const SizedBox(height: 8),
                _floatingBadge(
                  icon: Icons.access_time,
                  text: 'Expiring ${item['expires']}',
                  bg: const Color(0xFFFFE9E9),
                  fg: const Color(0xFFD64545),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cMintGreen.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['subcategory']?.toString().toUpperCase() ??
                      item['category']?.toString().toUpperCase() ??
                      'GENERAL',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: cDeepGreen,
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
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== Clean section header — no accent bar =====
  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: cDeepGreen,
      ),
    );
  }

  Widget _floatingBadge({
    required IconData icon,
    required String text,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===== DONOR CARD — solid soft green (not gradient), lighter Follow button =====
  Widget _donorCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cSoftGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cMintGreen, width: 1),
        boxShadow: [
          BoxShadow(
            color: cDeepGreen.withValues(alpha: 0.06),
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
                backgroundColor: cDarkGreen,
                child: Text(
                  (item['donorName'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: cSoftGreen, width: 2),
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
                    color: cDeepGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Color(0xFFE5B83A), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${item['donorRating'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cDeepGreen,
                      ),
                    ),
                    Text(
                      '  ·  ${item['donorDonations'] ?? '0'} donations',
                      style: const TextStyle(
                        fontSize: 12,
                        color: cMidGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lighter Follow button — medium green instead of dark
          GestureDetector(
            onTap: () {
              setState(() => _isFollowing = !_isFollowing);
              _snack(_isFollowing
                  ? 'Following ${item['donorName'] ?? 'donor'}'
                  : 'Unfollowed');
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: _isFollowing ? Colors.white : cDarkGreen,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cDarkGreen, width: 1.4),
              ),
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: TextStyle(
                  color: _isFollowing ? cDarkGreen : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureGrid(Map<String, dynamic> item) {
    final features = <Map<String, dynamic>>[];
    if (item['portion'] != null) {
      features.add({
        'icon': Icons.group,
        'label': 'Portion',
        'value': item['portion'],
      });
    }
    if (item['weight'] != null) {
      features.add({
        'icon': Icons.scale,
        'label': 'Weight',
        'value': item['weight'],
      });
    }
    if (item['tag'] != null) {
      features.add({
        'icon': Icons.local_offer_outlined,
        'label': 'Tag',
        'value': item['tag'],
      });
    }
    if (item['condition'] != null) {
      features.add({
        'icon': Icons.verified_outlined,
        'label': 'Condition',
        'value': item['condition'],
      });
    }

    if (features.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (int i = 0; i < features.length; i += 2) {
      final left = features[i];
      final right = i + 1 < features.length ? features[i + 1] : null;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: _featureChip(left)),
              const SizedBox(width: 10),
              Expanded(
                child: right != null
                    ? _featureChip(right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _featureChip(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cSoftGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cMintGreen, width: 1),
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
            child: Icon(f['icon'] as IconData,
                size: 18, color: cDarkGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  f['label'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: cMidGreen,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  f['value'].toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: cDeepGreen,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _mapPreview() {
    return GestureDetector(
      onTap: _openInMaps,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cBeige,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cMintGreen, width: 1),
          ),
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _MapDecorPainter(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cSoftGreen.withValues(alpha: 0.35),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.location_pin,
                  color: cDarkGreen,
                  size: 42,
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _openInMaps,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cDarkGreen,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: cDeepGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.directions,
                            size: 15, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Open in Maps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

  Widget _bottomActionBar(bool available) {
    const double buttonHeight = 54;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: cDeepGreen.withValues(alpha: 0.08),
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
                onTap: () => _snack('Messaging — Coming Soon'),
                child: Container(
                  height: buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cSoftGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cMintGreen, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_bubble_outline,
                          color: cDeepGreen, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Message',
                        style: TextStyle(
                          color: cDeepGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
                onTap: available ? _showRequestDialog : null,
                child: Container(
                  height: buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: available
                        ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cDarkGreen, cDeepGreen],
                    )
                        : null,
                    color: available ? null : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: available
                        ? [
                      BoxShadow(
                        color: cDeepGreen.withValues(alpha: 0.3),
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
                        available ? 'Request Item' : 'Not Available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

class _MapDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCFC9B2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double y = 20; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 20; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final road = Paint()
      ..color = const Color(0xFFA8A083)
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