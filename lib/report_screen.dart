import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const Color _topBarColor = Color(0xFF2D5A14);
  static const Color _greenMedium = Color(0xFF4A7C26);
  static const Color _greenLight  = Color(0xFFEAF3DE);
  static const Color _bgColor     = Color(0xFFF9F9F9);
  static const Color _darkButton  = Color(0xFF2D3A28);
  static const Color _creamCard   = Color(0xFFF5F0E8);

  String _selectedType   = '';
  String _selectedReason = '';
  bool   _isAnonymous    = false;
  bool   _isSubmitting   = false;
  File?  _attachedImage;

  final TextEditingController _detailsController = TextEditingController();
  int _charCount = 0;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'label': 'A User',
      'icon': Icons.person_outline,
      'name': 'Ram Sah',
      'initial': 'R',
      'subtitle': '4.8 · Donor · Member since 2026',
      'stars': 4,
    },
    {
      'label': 'A Donation Post',
      'icon': Icons.list_alt_outlined,
      'name': 'Winter Clothes Drive',
      'initial': 'W',
      'subtitle': 'Clothing · Posted 2 days ago',
      'stars': 0,
    },
    {
      'label': 'A Volunteer',
      'icon': Icons.volunteer_activism_outlined,
      'name': 'Sita Sharma',
      'initial': 'S',
      'subtitle': '4.5 · Volunteer · Active since 2025',
      'stars': 4,
    },
  ];

  final List<String> _reasons = [
    'Fake listing',
    'Unsafe Item',
    'Harassment',
    'Spam/Fraud',
    'Inappropriate content',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _detailsController.addListener(() {
      setState(() => _charCount = _detailsController.text.length);
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedType.isNotEmpty &&
          _selectedReason.isNotEmpty &&
          _charCount >= 15;

  Map<String, dynamic>? get _selectedTypeData {
    try {
      return _reportTypes.firstWhere((t) => t['label'] == _selectedType);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Attach Evidence",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3DE),
                child: Icon(Icons.photo_library, color: Color(0xFF4A7C26)),
              ),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  setState(() => _attachedImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3DE),
                child: Icon(Icons.camera_alt, color: Color(0xFF4A7C26)),
              ),
              title: const Text("Take a Photo"),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  setState(() => _attachedImage = File(picked.path));
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: Color(0xFFEAF3DE), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF4A7C26), size: 40),
            ),
            const SizedBox(height: 16),
            const Text("Report Submitted!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Thank you for keeping ShareBridge safe. "
                  "Our team will review your report within 24 hours.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkButton,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("Done",
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bgColor,
      body: Column(
        children: [
          // ── TOP BAR ──────────────────────────────────────────
          Container(
            color: _topBarColor,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── SCROLLABLE BODY ───────────────────────────────────
          Expanded(
            child: Container(
              color: _bgColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 1. Warning banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline,
                              color: Color(0xFFE53935), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Report Responsibly",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE53935),
                                        fontSize: 14)),
                                SizedBox(height: 4),
                                Text(
                                  "False reports may result in your account "
                                      "being restricted. Only report genuine violations.",
                                  style: TextStyle(
                                      color: Color(0xFFE53935), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. What are you reporting?
                    const Text("What are you reporting?",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(_reportTypes.length, (index) {
                        final type = _reportTypes[index];
                        final bool isSelected = _selectedType == type['label'];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: index < _reportTypes.length - 1 ? 10 : 0),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedType = type['label']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? _greenMedium : _greenLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    Icon(type['icon'],
                                        color: isSelected
                                            ? Colors.white
                                            : _greenMedium,
                                        size: 26),
                                    const SizedBox(height: 8),
                                    Text(
                                      type['label'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // 3. Reporting card (shows only when type selected)
                    if (_selectedType.isNotEmpty) ...[
                      const Text("Reporting",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(_selectedType),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _creamCard,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _greenMedium,
                                child: Text(
                                  _selectedTypeData?['initial'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedTypeData?['name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if ((_selectedTypeData?['stars'] ?? 0) > 0)
                                          ...List.generate(
                                            5,
                                                (i) => Icon(Icons.star,
                                                size: 13,
                                                color: i < (_selectedTypeData?['stars'] ?? 0)
                                                    ? const Color(0xFFFFC107)
                                                    : Colors.grey.shade300),
                                          ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _selectedTypeData?['subtitle'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 4. Reason for report
                    const Text("Reason for report",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 12),
                    for (int i = 0; i < _reasons.length; i += 2) ...[
                      Row(
                        children: [
                          Expanded(child: _reasonChip(_reasons[i])),
                          const SizedBox(width: 10),
                          Expanded(
                            child: i + 1 < _reasons.length
                                ? _reasonChip(_reasons[i + 1])
                                : const SizedBox(),
                          ),
                        ],
                      ),
                      if (i + 2 < _reasons.length) const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 20),

                    // 5. Additional details
                    const Text("Additional details",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _charCount >= 15
                              ? _greenMedium
                              : const Color(0xFFC8E6C9),
                        ),
                      ),
                      child: TextField(
                        controller: _detailsController,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText:
                          "Describe what happened in detail. The more "
                              "context you provide, the faster our team can "
                              "review this report ..",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                          counterText: '',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _charCount >= 15 ? "✓ Good to go!" : "Min. 15 characters",
                            style: TextStyle(
                              fontSize: 12,
                              color: _charCount >= 15 ? _greenMedium : Colors.red,
                              fontWeight: _charCount >= 15
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          Text("$_charCount/500",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _charCount >= 15
                                      ? _greenMedium
                                      : Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 6. Attach evidence
                    const Text("Attach evidence (optional)",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 12),
                    _attachedImage != null
                        ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _attachedImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _attachedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    )
                        : GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFC8E6C9)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: _greenMedium, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              "Tap to attach a screenshot or photo",
                              style: TextStyle(
                                  color: _greenMedium,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 7. Anonymous toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _greenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.visibility_off_outlined,
                                color: _greenMedium, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Submit anonymously",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                                Text(
                                    "Your name won't be shown to the reported user",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAnonymous,
                            onChanged: (val) =>
                                setState(() => _isAnonymous = val),
                            activeColor: _greenMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 8. Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _canSubmit ? _darkButton : Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: _canSubmit ? 2 : 0,
                        ),
                        onPressed: _canSubmit ? _submitReport : null,
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          "Submit Report",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  ], // end Column children
                ),
              ),
            ),
          ),

        ], // end outer Column children
      ),
    );
  }

  Widget _reasonChip(String reason) {
    final bool isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? _darkButton : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? _darkButton : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            reason,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
