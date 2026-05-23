import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});
  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _firstNameController   = TextEditingController();
  final _lastNameController    = TextEditingController();
  final _locationController    = TextEditingController();
  final _itemNameController    = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expiresController     = TextEditingController();

  String     _condition = '';
  String     _category  = '';
  List<File> _photos    = [];
  bool       _submitted = false;

  // ── Colors ───────────────────────────────────────────────
  static const kHeader  = Color(0xFF3D5A3E);
  static const kInputBg = Color(0xFFD6E8D0);
  static const kBorder  = Color(0xFFB0CBA8);
  static const kChipOn  = Color(0xFFC2D9BB);
  static const kPageBg  = Color(0xFFF2F5F0);
  static const kText    = Color(0xFF1A2A1A);
  static const kSub     = Color(0xFF5A7050);
  static const kWhite   = Colors.white;

  final _categories = [
    {'id': 'food',       'label': 'Food',       'icon': Icons.restaurant},
    {'id': 'stationery', 'label': 'Stationery', 'icon': Icons.edit},
    {'id': 'clothes',    'label': 'Clothes',    'icon': Icons.checkroom},
    {'id': 'other',      'label': 'Other',      'icon': Icons.apps_rounded},
  ];
  final _conditions = ['New', 'Gently Used', 'Used'];

  @override
  void dispose() {
    _firstNameController.dispose();  _lastNameController.dispose();
    _locationController.dispose();   _itemNameController.dispose();
    _descriptionController.dispose(); _expiresController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kHeader, onPrimary: kWhite),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final day = picked.day.toString().padLeft(2, '0');
      setState(() => _expiresController.text = '${months[picked.month - 1]} $day, ${picked.year}');
    }
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() => _photos = picked.take(5).map((x) => File(x.path)).toList());
    }
  }

  bool get _canSubmit =>
      _firstNameController.text.isNotEmpty &&
          _itemNameController.text.isNotEmpty &&
          _category.isNotEmpty;

  InputDecoration _inputDecor(String hint, {Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kSub.withValues(alpha: 0.9), fontSize: 14),
    filled: true,
    fillColor: kInputBg,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: kBorder, width: 1.5)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: kBorder, width: 1.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: kHeader, width: 2)),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
  );

  Widget _radioChip(String label, String val, String selected, VoidCallback onTap) {
    final active = selected == val;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kChipOn : kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? kSub : kBorder, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: active ? kHeader : kSub, width: 1.5),
              color: active ? kHeader : kWhite,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 13, color: kText,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          )),
        ]),
      ),
    );
  }

  Widget _catChip(Map<String, dynamic> cat, String selected, VoidCallback onTap) {
    final active = selected == cat['id'];
    final icon   = cat['icon'] as IconData;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kChipOn : kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? kSub : kBorder, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: active ? kHeader : kSub, width: 1.5),
              color: active ? kHeader : kWhite,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: active ? kHeader : kSub),
          const SizedBox(width: 5),
          Text(cat['label'] as String, style: TextStyle(
            fontSize: 13, color: kText,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _successScreen();

    final topPadding = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: kPageBg,
      body: Column(children: [

        // ── Dark Green Header (full top like dashboard) ──
        Container(
          width: double.infinity,
          color: kHeader,
          padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, 18),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: kWhite, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Create Donation',
              style: TextStyle(color: kWhite, fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ]),
        ),

        // ── Body ──
        Expanded(
          child: Container(
            color: kWhite,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Donor Name
                _label('Donor Name'),
                Row(children: [
                  Expanded(child: TextField(
                    controller: _firstNameController,
                    onChanged: (_) => setState((){}),
                    style: const TextStyle(color: kText, fontSize: 14),
                    decoration: _inputDecor('First'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(
                    controller: _lastNameController,
                    style: const TextStyle(color: kText, fontSize: 14),
                    decoration: _inputDecor('Last'),
                  )),
                ]),
                const SizedBox(height: 18),

                // Pickup Location
                _label('Pickup Location'),
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: kText, fontSize: 14),
                  decoration: _inputDecor('Enter pickup location'),
                ),
                const SizedBox(height: 18),

                // Item Name
                _label('Item Name'),
                TextField(
                  controller: _itemNameController,
                  onChanged: (_) => setState((){}),
                  style: const TextStyle(color: kText, fontSize: 14),
                  decoration: _inputDecor('Enter item name'),
                ),
                const SizedBox(height: 18),

                // Condition
                _label('Condition'),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _conditions.map((c) => _radioChip(
                    c, c, _condition, () => setState(() => _condition = c),
                  )).toList(),
                ),
                const SizedBox(height: 18),

                // Category
                _label('Category'),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _categories.map((cat) => _catChip(
                    cat, _category,
                        () => setState(() {
                      _category = cat['id'] as String;
                      if (_category != 'food') _expiresController.clear();
                    }),
                  )).toList(),
                ),
                const SizedBox(height: 18),

                // Expires — food only
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: _category == 'food'
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Expires'),
                    GestureDetector(
                      onTap: _pickExpiry,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _expiresController,
                          style: const TextStyle(color: kText, fontSize: 14),
                          decoration: _inputDecor('Select expiry date',
                              suffix: const Icon(Icons.calendar_today_rounded, color: kHeader, size: 18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ])
                      : const SizedBox.shrink(),
                ),

                // Description
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _label('Description/Details'),
                  Text('${_descriptionController.text.length}/200',
                      style: TextStyle(fontSize: 11,
                          color: _descriptionController.text.length > 180 ? Colors.red : kSub)),
                ]),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3, maxLength: 200,
                  onChanged: (_) => setState((){}),
                  style: const TextStyle(color: kText, fontSize: 14),
                  decoration: _inputDecor('Describe the item...').copyWith(counterText: ''),
                ),
                const SizedBox(height: 18),

                // Upload Photos
                Row(children: [
                  _label('Upload Photos'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: kHeader, borderRadius: BorderRadius.circular(20)),
                    child: Text('${_photos.length}/5',
                        style: const TextStyle(fontSize: 10, color: kWhite, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 6),
                _photos.isEmpty
                    ? GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kInputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder, width: 1.5),
                    ),
                    child: Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: kChipOn, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_photo_alternate_outlined, color: kHeader, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Add item photos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                        SizedBox(height: 2),
                        Text('up to 5 images JPG or PNG', style: TextStyle(fontSize: 11, color: kSub)),
                      ]),
                    ]),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: _photos.length < 5 ? _photos.length + 1 : _photos.length,
                  itemBuilder: (ctx, i) {
                    if (i == _photos.length && _photos.length < 5) {
                      return GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kInputBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorder),
                          ),
                          child: const Center(child: Icon(Icons.add_rounded, color: kHeader, size: 24)),
                        ),
                      );
                    }
                    return Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_photos[i], fit: BoxFit.cover,
                            width: double.infinity, height: double.infinity),
                      ),
                      Positioned(top: 3, right: 3,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(9)),
                              child: const Icon(Icons.close_rounded, color: kWhite, size: 12),
                            ),
                          )),
                    ]);
                  },
                ),
                const SizedBox(height: 28),

                // Post Donation button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _canSubmit ? () => setState(() => _submitted = true) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: kHeader,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Post Donation',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                color: kWhite, letterSpacing: 0.4)),
                      ),
                    ),
                  ),
                ),

              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _successScreen() => Scaffold(
    backgroundColor: kPageBg,
    body: Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: kInputBg, shape: BoxShape.circle,
              border: Border.all(color: kSub, width: 3),
            ),
            child: const Icon(Icons.check_rounded, color: kHeader, size: 38),
          ),
          const SizedBox(height: 16),
          const Text('Donation Posted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kHeader)),
          const SizedBox(height: 8),
          Text('Thank you, ${_firstNameController.text}!\nYour donation has been posted.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: kSub, height: 1.5)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => setState(() {
              _submitted = false;
              _firstNameController.clear(); _lastNameController.clear();
              _locationController.clear();  _itemNameController.clear();
              _descriptionController.clear(); _expiresController.clear();
              _condition = ''; _category = ''; _photos = [];
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: kHeader, borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text('Create Another',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kWhite)),
              ),
            ),
          ),
        ]),
      ),
    ),
  );
}