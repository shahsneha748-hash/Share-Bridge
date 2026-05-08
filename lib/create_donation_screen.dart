import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final TextEditingController _firstNameController =
  TextEditingController(text: 'Ram');
  final TextEditingController _lastNameController =
  TextEditingController(text: 'sah');
  final TextEditingController _pickupLocationController =
  TextEditingController(text: 'Imadol-5');
  final TextEditingController _itemNameController =
  TextEditingController(text: 'Grocery Essentials Bundle');
  final TextEditingController _descriptionController = TextEditingController(
      text: 'Vegetables, fruits, bread, water & Pantry Staples');

  String _selectedCondition = '';
  String _selectedCategory = '';
  DateTime? _expiryDate;
  File? _selectedImage;

  final Color _darkGreen = const Color(0xFF3B5240);
  final Color _lightGreen = const Color(0xFFD6E8CF);
  final Color _bgColor = const Color(0xFFF0F4EE);

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkGreen,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera);
                    if (image != null) {
                      setState(() => _selectedImage = File(image.path));
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _lightGreen,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF7A9A72), width: 1.5),
                        ),
                        child: Icon(Icons.camera_alt,
                            color: _darkGreen, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text('Camera',
                          style: TextStyle(
                              fontSize: 13,
                              color: _darkGreen,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                // Gallery option
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => _selectedImage = File(image.path));
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _lightGreen,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF7A9A72), width: 1.5),
                        ),
                        child: Icon(Icons.photo_library,
                            color: _darkGreen, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text('Gallery',
                          style: TextStyle(
                              fontSize: 13,
                              color: _darkGreen,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _darkGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _submitDonation() {
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✓ Donation submitted successfully!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF3B5240),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _darkGreen,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // ── Auto-expanding text field ──────────────────────────────
  Widget _buildTextField(TextEditingController controller,
      {String hint = '', int maxLines = 1, bool autoExpand = false}) {
    return TextField(
      controller: controller,
      maxLines: autoExpand ? null : maxLines,
      minLines: autoExpand ? 2 : maxLines,
      keyboardType:
      autoExpand ? TextInputType.multiline : TextInputType.text,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2A3A2A)),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _lightGreen,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRadioOption(
      String label, String selected, ValueChanged<String> onTap) {
    final bool isSelected = selected == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _lightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _darkGreen : const Color(0xFFB8D1B0),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? _darkGreen
                      : const Color(0xFF7A9A72),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _darkGreen,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A3A2A),
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
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Create Donation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Donor Name ─────────────────────────────────────
            _buildLabel('Donor Name'),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(_firstNameController,
                        hint: 'First')),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(_lastNameController,
                        hint: 'Last')),
              ],
            ),
            const SizedBox(height: 22),

            // ── Pickup Location ────────────────────────────────
            _buildLabel('Pickup Location'),
            _buildTextField(_pickupLocationController,
                hint: 'Enter pickup location'),
            const SizedBox(height: 22),

            // ── Item Name ──────────────────────────────────────
            _buildLabel('Item Name'),
            _buildTextField(_itemNameController,
                hint: 'Enter item name'),
            const SizedBox(height: 22),

            // ── Expiry Date ────────────────────────────────────
            _buildLabel('Expiry Date'),
            GestureDetector(
              onTap: _pickExpiryDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: _darkGreen),
                    const SizedBox(width: 10),
                    Text(
                      _expiryDate == null
                          ? 'Select expiry date'
                          : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _expiryDate == null
                            ? Colors.grey
                            : const Color(0xFF2A3A2A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ── Condition ──────────────────────────────────────
            _buildLabel('Condition'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['New', 'Gently Used', 'Used']
                  .map((c) => _buildRadioOption(
                  c,
                  _selectedCondition,
                      (val) =>
                      setState(() => _selectedCondition = val)))
                  .toList(),
            ),
            const SizedBox(height: 22),

            // ── Category ───────────────────────────────────────
            _buildLabel('Category'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Food', 'Stationery', 'Clothes']
                  .map((c) => _buildRadioOption(
                  c,
                  _selectedCategory,
                      (val) =>
                      setState(() => _selectedCategory = val)))
                  .toList(),
            ),
            const SizedBox(height: 22),

            // ── Description ────────────────────────────────────
            _buildLabel('Description/Details'),
            _buildTextField(
              _descriptionController,
              hint: 'Describe the item...',
              autoExpand: true,
            ),
            const SizedBox(height: 22),

            // ── Upload Photos ──────────────────────────────────
            _buildLabel('Upload Photos'),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF7A9A72),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined,
                        color: Color(0xFF5A7A52), size: 28),
                    SizedBox(height: 4),
                    Text(
                      '[ add item ]',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A7A52),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Submit Button ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  '[Submit Donation]',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _pickupLocationController.dispose();
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}