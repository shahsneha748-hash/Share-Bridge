import 'package:flutter/material.dart';

void main() => runApp(const ShareBridgeApp());

// COLORS
class AppColors {
  static const Color headerGreen  = Color(0xFF3A6B1E);
  static const Color medGreen     = Color(0xFF3A6B1E);
  static const Color accentGreen  = Color(0xFF4A7C35);
  static const Color lightSage    = Color(0xFFD4E8C2);
  static const Color softSage     = Color(0xFFE8F2DC);
  static const Color paleGreen    = Color(0xFFF0F7E8);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color textDark     = Color(0xFF1A2E1A);
  static const Color textMid      = Color(0xFF3D5C3D);
  static const Color textLight    = Color(0xFF6B8F6B);
  static const Color border       = Color(0xFFC8DDB8);
  static const Color urgent       = Color(0xFFC0392B);
  static const Color urgentBg     = Color(0xFFFDECEA);
  static const Color accepted     = Color(0xFF27AE60);
  static const Color acceptedBg   = Color(0xFFE8F8EE);
  static const Color pendingColor = Color(0xFFE67E22);
  static const Color pendingBg    = Color(0xFFFEF5EC);
  static const Color iconYellow   = Color(0xFFFFD93D);
  static const Color iconOrange   = Color(0xFFFF9A3C);
  static const Color iconCyan     = Color(0xFF4DD9E0);
  static const Color iconPink     = Color(0xFFFF6B9D);
  static const Color iconLime     = Color(0xFFA8E063);
}

// MODEL
enum RequestStatus { pending, accepted, rejected }

class DonationRequest {
  final int id;
  final String name;
  final String category;
  final String message;
  RequestStatus status;
  String? scheduledTime;

  DonationRequest({
    required this.id,
    required this.name,
    required this.category,
    required this.message,
    this.status = RequestStatus.pending,
    this.scheduledTime,
  });

  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';

  String get tagLabel {
    switch (status) {
      case RequestStatus.accepted: return 'ACCEPTED';
      case RequestStatus.rejected: return 'REJECTED';
      default:                     return 'PENDING';
    }
  }

  Color get tagColor {
    switch (status) {
      case RequestStatus.accepted: return AppColors.accepted;
      case RequestStatus.rejected: return AppColors.textLight;
      default:                     return AppColors.pendingColor;
    }
  }

  Color get tagBg {
    switch (status) {
      case RequestStatus.accepted: return AppColors.acceptedBg;
      case RequestStatus.rejected: return const Color(0xFFF5F5F5);
      default:                     return AppColors.pendingBg;
    }
  }
}

// APP ROOT
class ShareBridgeApp extends StatelessWidget {
  const ShareBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.paleGreen,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.medGreen),
        useMaterial3: true,
      ),
      home: const RequestSystemScreen(),
    );
  }
}

// MAIN SCREEN
class RequestSystemScreen extends StatefulWidget {
  const RequestSystemScreen({super.key});

  @override
  State<RequestSystemScreen> createState() => _RequestSystemScreenState();
}

class _RequestSystemScreenState extends State<RequestSystemScreen> {
  int _tab = 0;

  final List<DonationRequest> _requests = [
    DonationRequest(
      id: 1, name: 'Sarah Joshi', category: 'Food',
      message: 'Our local shelter is running low on rice, lentils and canned vegetables for the weekend outreach program.',
      status: RequestStatus.pending,
    ),
    DonationRequest(
      id: 2, name: 'Marcus Lama', category: 'Stationery',
      message: 'Requesting spare notebooks, pencils and pens for the after-school tutoring center.',
      status: RequestStatus.accepted,
      scheduledTime: 'Scheduled for drop-off: Oct 24, 2:00 PM',
    ),
    DonationRequest(
      id: 3, name: 'Elena Gurung', category: 'Clothes',
      message: 'Collecting warm clothes and jackets for the community winter drive starting next week.',
      status: RequestStatus.pending,
    ),
    DonationRequest(
      id: 4, name: 'Rina Shrestha', category: 'Food',
      message: 'Need dry ration supplies for a family affected by recent flooding in our area.',
      status: RequestStatus.pending,
    ),
    DonationRequest(
      id: 5, name: 'Dev Karki', category: 'Stationery',
      message: 'Looking for school bags and stationery kits for underprivileged students in grade 1-5.',
      status: RequestStatus.rejected,
    ),
  ];

  void _accept(int id) => setState(() {
    final r = _requests.firstWhere((r) => r.id == id);
    r.status = RequestStatus.accepted;
    r.scheduledTime = 'Scheduled for drop-off: Oct 24, 2:00 PM';
  });
  void _reject(int id) => setState(() =>
  _requests.firstWhere((r) => r.id == id).status = RequestStatus.rejected);
  void _cancel(int id) => setState(() {
    final r = _requests.firstWhere((r) => r.id == id);
    r.status = RequestStatus.pending;
    r.scheduledTime = null;
  });
  void _add(DonationRequest req) => setState(() => _requests.add(req));

  void _openPost() => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => NewRequestSheet(onSubmit: _add),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleGreen,
      appBar: AppBar(
        backgroundColor: AppColors.headerGreen,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.white, size: 18),
          ),
        ),
        title: const Text('ShareBridge',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.white), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          // 0: Home
          HomeTab(requests: _requests, onAccept: _accept, onReject: _reject, onCancel: _cancel, onTabChange: (t) => setState(() => _tab = t)),
          // 1: Browse
          BrowseTab(requests: _requests, onAccept: _accept, onReject: _reject, onCancel: _cancel),
          // 2: Post (placeholder — opens modal)
          const SizedBox(),
          // 3: My Items
          MyItemsTab(requests: _requests, onAccept: _accept, onReject: _reject, onCancel: _cancel),
          // 4: Profile
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(5, (i) {
              final isPost = i == 2;
              final labels   = ['Home', 'Browse', 'Post', 'My Items', 'Profile'];
              final icons    = [Icons.home_outlined, Icons.search_outlined, Icons.add, Icons.inventory_2_outlined, Icons.person_outline];
              final actIcons = [Icons.home, Icons.search, Icons.add, Icons.inventory_2, Icons.person];
              final colors   = [AppColors.medGreen, AppColors.medGreen, AppColors.white, AppColors.medGreen, AppColors.medGreen];
              final active   = _tab == i;

              return Expanded(
                child: InkWell(
                  onTap: () => isPost ? _openPost() : setState(() => _tab = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (isPost)
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.medGreen,
                            boxShadow: const [BoxShadow(color: Color(0x663A6B1E), blurRadius: 10, offset: Offset(0, 3))],
                          ),
                          child: const Icon(Icons.add, color: AppColors.white, size: 26),
                        )
                      else ...[
                        Icon(active ? actIcons[i] : icons[i],
                            color: active ? colors[i] : AppColors.textLight, size: 22),
                        const SizedBox(height: 3),
                        Text(labels[i], style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.medGreen : AppColors.textLight,
                        )),
                        if (active)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            width: 18, height: 2,
                            decoration: BoxDecoration(color: AppColors.medGreen, borderRadius: BorderRadius.circular(2)),
                          ),
                      ],
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════
class AvatarCircle extends StatelessWidget {
  final String letter;
  final double size;
  const AvatarCircle({super.key, required this.letter, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppColors.medGreen, AppColors.accentGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: const [BoxShadow(color: Color(0x4D3A6B1E), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Center(child: Text(letter, style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: size * 0.42))),
    );
  }
}

class TagChip extends StatelessWidget {
  final String label; final Color color; final Color bg;
  const TagChip({super.key, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withAlpha(76))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    );
  }
}

class GreenButton extends StatelessWidget {
  final String label; final VoidCallback onTap; final bool outline; final IconData? icon;
  const GreenButton({super.key, required this.label, required this.onTap, this.outline = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: outline ? AppColors.white : AppColors.medGreen,
            border: Border.all(color: outline ? AppColors.border : AppColors.medGreen, width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, color: outline ? AppColors.textMid : AppColors.white, size: 15), const SizedBox(width: 5)],
            Text(label, style: TextStyle(color: outline ? AppColors.textMid : AppColors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}

class SageInput extends StatelessWidget {
  final String label, hint; final TextEditingController controller; final int maxLines; final int? maxLength;
  const SageInput({super.key, required this.label, required this.hint, required this.controller, this.maxLines = 1, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid)),
        const SizedBox(height: 6),
        TextField(
          controller: controller, maxLines: maxLines, maxLength: maxLength,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
            filled: true, fillColor: AppColors.softSage,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.medGreen, width: 1.8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            counterStyle: const TextStyle(color: AppColors.textLight, fontSize: 10),
          ),
        ),
      ]),
    );
  }
}

// REQUEST CARD (shared by Home + Browse)
class RequestCard extends StatelessWidget {
  final DonationRequest req;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onReject;
  final VoidCallback onTap;
  const RequestCard({super.key, required this.req, required this.onAccept, required this.onReject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x122E4F2E), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AvatarCircle(letter: req.avatarLetter),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(req.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
              Row(children: [
                const Icon(Icons.favorite, color: AppColors.textLight, size: 11),
                const SizedBox(width: 3),
                Text(req.category, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ]),
            ])),
            TagChip(label: req.tagLabel, color: req.tagColor, bg: req.tagBg),
          ]),
          const SizedBox(height: 8),
          Text('"${req.message}"', style: const TextStyle(fontSize: 12, color: AppColors.textMid, fontStyle: FontStyle.italic, height: 1.5)),
          if (req.scheduledTime != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today, color: AppColors.textLight, size: 12),
              const SizedBox(width: 4),
              Text(req.scheduledTime!, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ]),
          ],
          if (req.status == RequestStatus.pending) ...[
            const SizedBox(height: 12),
            Row(children: [
              GreenButton(label: 'Accept', onTap: () => onAccept(req.id), icon: Icons.check_circle_outline),
              const SizedBox(width: 10),
              GreenButton(label: 'Reject', onTap: () => onReject(req.id), outline: true, icon: Icons.cancel_outlined),
            ]),
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HOME TAB — greeting, community impact, category boxes, featured cards
// ═══════════════════════════════════════════════════════════
class HomeTab extends StatelessWidget {
  final List<DonationRequest> requests;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onReject;
  final ValueChanged<int> onCancel;
  final ValueChanged<int> onTabChange;
  const HomeTab({super.key, required this.requests, required this.onAccept, required this.onReject, required this.onCancel, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final accepted = requests.where((r) => r.status == RequestStatus.accepted).length;
    final featured = requests.where((r) => r.status == RequestStatus.pending).take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border, width: 1.5)),
          child: const Row(children: [
            SizedBox(width: 14),
            Icon(Icons.search, color: AppColors.textLight, size: 18),
            SizedBox(width: 8),
            Expanded(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 11),
              child: Text('Search for donations...', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // Community Impact banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.headerGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Community Impact', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.accentGreen, borderRadius: BorderRadius.circular(20)),
                child: const Text('This Week', style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            Text('$accepted items shared nearby',
                style: const TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (accepted / 10).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.accentGreen,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.iconYellow),
              ),
            ),
            const SizedBox(height: 4),
            const Text('Goal: 10 items', style: TextStyle(color: AppColors.lightSage, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 20),

        // Browse by Category
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Browse by Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
          GestureDetector(
            onTap: () => onTabChange(1),
            child: const Text('View all →', style: TextStyle(fontSize: 12, color: AppColors.medGreen, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _catBox(Icons.restaurant_outlined, 'Food',       AppColors.white, AppColors.white),
          const SizedBox(width: 10),
          _catBox(Icons.edit_outlined,       'Stationery', AppColors.white, AppColors.white),
          const SizedBox(width: 10),
          _catBox(Icons.checkroom_outlined,  'Clothes',    AppColors.white, AppColors.white),
        ]),
        const SizedBox(height: 20),

        // Featured Nearby
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Featured Nearby', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
          GestureDetector(
            onTap: () => onTabChange(1),
            child: const Text('See all →', style: TextStyle(fontSize: 12, color: AppColors.medGreen, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        ...featured.map((r) => RequestCard(
          req: r, onAccept: onAccept, onReject: onReject,
          onTap: () => showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (_) => RequestDetailSheet(req: r, onAccept: onAccept, onReject: onReject, onCancel: onCancel),
          ),
        )),
      ],
    );
  }

  Widget _catBox(IconData icon, String label, Color iconColor, Color cardColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(children: [
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(
              color: AppColors.headerGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMid)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BROWSE TAB — search + filter + all requests
// ═══════════════════════════════════════════════════════════
class BrowseTab extends StatefulWidget {
  final List<DonationRequest> requests;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onReject;
  final ValueChanged<int> onCancel;
  const BrowseTab({super.key, required this.requests, required this.onAccept, required this.onReject, required this.onCancel});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  final _search = TextEditingController();
  String _cat = 'All';
  final _cats = ['All', 'Food', 'Stationery', 'Clothes', 'Others'];

  List<DonationRequest> get _filtered => widget.requests.where((r) =>
  (_cat == 'All' || r.category == _cat) &&
      (r.name.toLowerCase().contains(_search.text.toLowerCase()) ||
          r.message.toLowerCase().contains(_search.text.toLowerCase()))
  ).toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        const Text('Browse Donations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Search by name or keyword...',
            hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 18),
            filled: true, fillColor: AppColors.softSage,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.medGreen, width: 1.8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _cats[i]; final active = _cat == c;
              return GestureDetector(
                onTap: () => setState(() => _cat = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.lightSage : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppColors.medGreen : AppColors.border, width: 1.5),
                  ),
                  child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? AppColors.medGreen : AppColors.textLight)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: Text('No requests found.', style: TextStyle(color: AppColors.textLight))),
          )
        else
          ..._filtered.map((r) => RequestCard(
            req: r, onAccept: widget.onAccept, onReject: widget.onReject,
            onTap: () => showModalBottomSheet(
              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (_) => RequestDetailSheet(req: r, onAccept: widget.onAccept, onReject: widget.onReject, onCancel: widget.onCancel),
            ),
          )),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MY ITEMS TAB — user's own requests by status
// ═══════════════════════════════════════════════════════════
class MyItemsTab extends StatelessWidget {
  final List<DonationRequest> requests;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onReject;
  final ValueChanged<int> onCancel;
  const MyItemsTab({super.key, required this.requests, required this.onAccept, required this.onReject, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final pending  = requests.where((r) => r.status == RequestStatus.pending).toList();
    final accepted = requests.where((r) => r.status == RequestStatus.accepted).toList();
    final rejected = requests.where((r) => r.status == RequestStatus.rejected).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('My Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('Track your donation requests', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
        const SizedBox(height: 16),

        // Stats row
        Row(children: [
          _statPill(Icons.hourglass_empty,  AppColors.iconOrange,   '${pending.length}',  'Pending',  AppColors.pendingBg),
          const SizedBox(width: 8),
          _statPill(Icons.check_circle,     AppColors.accepted,     '${accepted.length}', 'Accepted', AppColors.acceptedBg),
          const SizedBox(width: 8),
          _statPill(Icons.cancel,           AppColors.textLight,    '${rejected.length}', 'Rejected', const Color(0xFFF5F5F5)),
        ]),
        const SizedBox(height: 20),

        if (pending.isNotEmpty)  _section('Pending', pending,  AppColors.pendingColor, context),
        if (accepted.isNotEmpty) _section('Accepted', accepted, AppColors.accepted,    context),
        if (rejected.isNotEmpty) _section('Rejected', rejected, AppColors.textLight,   context),

        if (requests.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 1.5)),
            child: const Column(children: [
              Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textLight),
              SizedBox(height: 10),
              Text('No requests yet.', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
              SizedBox(height: 4),
              Text('Tap + to post one!', style: TextStyle(color: AppColors.medGreen, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
      ],
    );
  }

  Widget _section(String title, List<DonationRequest> items, Color color, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8)),
      const SizedBox(height: 8),
      ...items.map((r) => RequestCard(
        req: r, onAccept: onAccept, onReject: onReject,
        onTap: () => showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => RequestDetailSheet(req: r, onAccept: onAccept, onReject: onReject, onCancel: onCancel),
        ),
      )),
      const SizedBox(height: 8),
    ]);
  }

  Widget _statPill(IconData icon, Color color, String value, String label, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 1.5)),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// REQUEST DETAIL SHEET
// ═══════════════════════════════════════════════════════════
class RequestDetailSheet extends StatefulWidget {
  final DonationRequest req;
  final ValueChanged<int> onAccept;
  final ValueChanged<int> onReject;
  final ValueChanged<int> onCancel;
  const RequestDetailSheet({super.key, required this.req, required this.onAccept, required this.onReject, required this.onCancel});

  @override
  State<RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends State<RequestDetailSheet> {
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  Widget _row(IconData icon, Color iconColor, String key, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: iconColor), const SizedBox(width: 8),
      Text('$key  ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMid)),
      Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, color: AppColors.textLight))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final r = widget.req;
    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(18, 0, 18, 30), children: [
          Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          Row(children: [
            AvatarCircle(letter: r.avatarLetter, size: 48), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
              Row(children: [const Icon(Icons.favorite, size: 12, color: AppColors.textLight), const SizedBox(width: 3),
                Text(r.category, style: const TextStyle(fontSize: 12, color: AppColors.textLight))]),
            ])),
            TagChip(label: r.tagLabel, color: r.tagColor, bg: r.tagBg),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.softSage, borderRadius: BorderRadius.circular(12)),
            child: Text('"${r.message}"', style: const TextStyle(fontSize: 13, color: AppColors.textMid, fontStyle: FontStyle.italic, height: 1.6)),
          ),
          const SizedBox(height: 14),
          _row(Icons.info_outline,         AppColors.iconCyan,   'Status',    r.tagLabel),
          if (r.scheduledTime != null) _row(Icons.calendar_today, AppColors.iconYellow, 'Pickup', r.scheduledTime!),
          _row(Icons.location_on_outlined, AppColors.iconPink,   'Location',  '123 Main St, Shelter Hall A'),
          _row(Icons.access_time,          AppColors.iconOrange, 'Requested', 'Oct 22, 10:30 AM'),
          const Divider(color: AppColors.border, height: 28),
          SageInput(label: 'Send a Message', hint: 'Type your message...', controller: _msgCtrl, maxLines: 3, maxLength: 200),
          Row(children: [GreenButton(label: _sent ? '✔ Sent' : 'Send Message', onTap: () => setState(() => _sent = true), icon: Icons.send)]),
          const Divider(color: AppColors.border, height: 28),
          if (r.status == RequestStatus.pending)
            Row(children: [
              GreenButton(label: 'Accept', onTap: () { widget.onAccept(r.id); Navigator.pop(context); }, icon: Icons.check_circle_outline),
              const SizedBox(width: 10),
              GreenButton(label: 'Reject', onTap: () { widget.onReject(r.id); Navigator.pop(context); }, outline: true, icon: Icons.cancel_outlined),
            ]),
          if (r.status == RequestStatus.accepted)
            Row(children: [GreenButton(label: 'Cancel Request', onTap: () { widget.onCancel(r.id); Navigator.pop(context); }, outline: true, icon: Icons.undo)]),
          const SizedBox(height: 10),
          Row(children: [GreenButton(label: 'Back', onTap: () => Navigator.pop(context), outline: true, icon: Icons.arrow_back)]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// NEW REQUEST SHEET (opened by + button)
// ═══════════════════════════════════════════════════════════
class NewRequestSheet extends StatefulWidget {
  final ValueChanged<DonationRequest> onSubmit;
  const NewRequestSheet({super.key, required this.onSubmit});

  @override
  State<NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends State<NewRequestSheet> {
  final _name = TextEditingController();
  final _item = TextEditingController();
  final _location = TextEditingController();
  final _pickup = TextEditingController();
  final _message = TextEditingController();
  String _cat = 'Food';
  final _cats = ['Food', 'Clothes', 'Stationery', 'Other'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: ListView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(18, 0, 18, MediaQuery.of(context).viewInsets.bottom + 30),
          children: [
            Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.headerGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('📋 Request an Item', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
            const SizedBox(height: 16),
            SageInput(label: 'Requester Name', hint: 'Full name', controller: _name),
            SageInput(label: 'Item You Need', hint: 'e.g. Rice, Winter Jacket, Notebook', controller: _item),
            const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _cats.map((c) {
                final active = _cat == c;
                return GestureDetector(
                  onTap: () => setState(() => _cat = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.lightSage : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.medGreen : AppColors.border, width: 1.5),
                    ),
                    child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.medGreen : AppColors.textLight)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            SageInput(label: 'Pickup Location', hint: 'Enter pickup location', controller: _location),
            SageInput(label: 'Preferred Pickup Time', hint: 'e.g. Oct 24, 2:00 PM', controller: _pickup),
            SageInput(label: 'Reason / Details', hint: 'Why do you need this item?', controller: _message, maxLines: 4, maxLength: 200),
            Row(children: [
              GreenButton(
                label: 'Submit Request', icon: Icons.send,
                onTap: () {
                  widget.onSubmit(DonationRequest(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: _name.text.isEmpty ? 'Anonymous' : _name.text,
                    category: _cat,
                    message: _message.text.isEmpty ? _item.text : _message.text,
                    scheduledTime: _pickup.text.isEmpty ? null : 'Preferred pickup: ${_pickup.text}',
                  ));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 10),
              GreenButton(label: 'Cancel', onTap: () => Navigator.pop(context), outline: true),
            ]),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PROFILE TAB
// ═══════════════════════════════════════════════════════════
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = <List<Object>>[
      [Icons.inventory_2_outlined,    AppColors.iconYellow, 'My Requests',        '7 submitted'],
      [Icons.check_box_outlined,      AppColors.iconLime,   'Items Received',     '5 confirmed'],
      [Icons.location_on_outlined,    AppColors.iconPink,   'Preferred Location', 'Kathmandu, NP'],
      [Icons.notifications_outlined,  AppColors.iconCyan,   'Notifications',      'Enabled'],
      [Icons.calendar_today_outlined, AppColors.iconOrange, 'Member Since',       'Jan 2026'],
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const SizedBox(height: 20),
        const Center(child: AvatarCircle(letter: 'R', size: 72)),
        const SizedBox(height: 10),
        const Center(child: Text('Ram Sah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark))),
        const Center(child: Text('ShareBridge Volunteer', style: TextStyle(fontSize: 13, color: AppColors.textLight))),
        const SizedBox(height: 24),
        ...rows.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1.5)),
          child: Row(children: [
            Icon(r[0] as IconData, color: r[1] as Color, size: 20), const SizedBox(width: 12),
            Expanded(child: Text(r[2] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid))),
            Text(r[3] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ]),
        )),
      ],
    );
  }
}