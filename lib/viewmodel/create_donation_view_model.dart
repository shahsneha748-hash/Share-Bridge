import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/create_donation_model.dart';
import '../repo/create_donation_repo.dart';

class CreateDonationViewModel extends ChangeNotifier {
  final DonationRepo _repo;

  CreateDonationViewModel(this._repo) {
    // FIX: controllers notify the VM internally — no onChanged needed in UI
    firstNameController.addListener(notifyListeners);
    itemNameController.addListener(notifyListeners);
    descriptionController.addListener(notifyListeners);
  }

  // ── Text Controllers ──────────────────────────────────────
  final firstNameController   = TextEditingController();
  final lastNameController    = TextEditingController();
  final locationController    = TextEditingController();
  final itemNameController    = TextEditingController();
  final descriptionController = TextEditingController();
  final expiresController     = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  String     _condition  = '';
  String     _category   = '';
  List<File> _photos     = [];
  bool       _submitted  = false;
  bool       _isDonated  = false;
  bool       _confirmDel = false;
  bool       _isLoading  = false;
  bool       _isDisposed = false;
  String?    _errorMessage;
  Timer?     _deleteTimer;

  // ── Getters ───────────────────────────────────────────────
  String     get condition          => _condition;
  String     get category           => _category;
  List<File> get photos             => List.unmodifiable(_photos);
  bool       get submitted          => _submitted;
  bool       get isDonated          => _isDonated;
  bool       get confirmDel         => _confirmDel;
  bool       get isLoading          => _isLoading;
  String?    get errorMessage       => _errorMessage;

  // FIX: expose description length as a clean getter for the counter UI
  int get descriptionLength => descriptionController.text.length;

  // FIX: canSubmit guards against double-submit while loading
  bool get canSubmit =>
      firstNameController.text.isNotEmpty &&
          itemNameController.text.isNotEmpty &&
          _category.isNotEmpty &&
          !_isLoading;

  // ── Safe notify ───────────────────────────────────────────
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────
  void setCondition(String value) {
    _condition = value;
    _notify();
  }

  void setCategory(String value) {
    _category = value;
    if (value != 'food') expiresController.clear();
    _notify();
  }

  // FIX: toggleDonated kept for the Create screen (no doc id yet).
  // Use markAsDonated(id) only after the document has been saved.
  void toggleDonated() {
    _isDonated = !_isDonated;
    _notify();
  }

  void removePhoto(int index) {
    _photos.removeAt(index);
    _notify();
  }

  // ── Load existing donation (for Edit screen) ──────────────
  // FIX: seeds _isDonated from real data, not a blind toggle
  void loadDonation(DonationModel donation) {
    firstNameController.text   = donation.firstName;
    lastNameController.text    = donation.lastName;
    locationController.text    = donation.location;
    itemNameController.text    = donation.itemName;
    descriptionController.text = donation.description;
    expiresController.text     = donation.expiresAt ?? '';
    _condition  = donation.condition;
    _category   = donation.category;
    _isDonated  = donation.isDonated;
    _photos     = [];
    _notify();
  }

  // ── Photo Picker ──────────────────────────────────────────
  // FIX: appends to existing photos instead of replacing them
  Future<void> pickPhotos() async {
    final remaining = 5 - _photos.length;
    if (remaining <= 0) return;

    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      final newFiles = picked.take(remaining).map((x) => File(x.path));
      _photos = [..._photos, ...newFiles];
      _notify();
    }
  }

  // ── Date Picker ───────────────────────────────────────────
  Future<void> pickExpiry(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3A6B1E),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      final day = picked.day.toString().padLeft(2, '0');
      expiresController.text =
      '${months[picked.month - 1]} $day, ${picked.year}';
      _notify();
    }
  }

  // ── Delete double-tap confirmation ────────────────────────
  // FIX: uses cancelable Timer to prevent post-dispose notifyListeners crash
  /// Returns true when confirmed — caller should Navigator.pop()
  bool handleDelete() {
    if (!_confirmDel) {
      _confirmDel = true;
      _notify();
      _deleteTimer?.cancel();
      _deleteTimer = Timer(const Duration(seconds: 3), () {
        _confirmDel = false;
        _notify();
      });
      return false;
    }
    _deleteTimer?.cancel();
    return true;
  }

  // ── Mark as donated (after doc exists — Edit screen) ─────
  // FIX: takes currentValue so toggle is always based on real Firestore state
  Future<void> markAsDonated(String id, {required bool currentValue}) async {
    final newValue = !currentValue;
    _isDonated = newValue;
    _notify();
    try {
      await _repo.markAsDonated(id, newValue);
    } catch (e) {
      _isDonated = currentValue;
      _errorMessage = 'Failed to update donation status.';
      _notify();
    }
  }

  // ── Submit (Create) ───────────────────────────────────────
  Future<void> submit() async {
    if (!canSubmit) return;

    _isLoading    = true;
    _errorMessage = null;
    _notify();

    try {
      final List<String> uploadedUrls = await _uploadPhotos(_photos);

      final donation = DonationModel(
        // FIX: no client-side UUID — repo.createDonation uses Firestore .add()
        id:          '',
        firstName:   firstNameController.text.trim(),
        lastName:    lastNameController.text.trim(),
        location:    locationController.text.trim(),
        itemName:    itemNameController.text.trim(),
        condition:   _condition,
        category:    _category,
        description: descriptionController.text.trim(),
        photoUrls:   uploadedUrls,
        isDonated:   _isDonated,
        createdAt:   DateTime.now(),
        expiresAt:   expiresController.text.isEmpty
            ? null
            : expiresController.text,
      );

      await _repo.createDonation(donation);
      _submitted = true;
    } catch (e) {
      _errorMessage = 'Failed to post donation. Please try again.';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // ── Photo Upload Helper ───────────────────────────────────
  Future<List<String>> _uploadPhotos(List<File> photos) async {
    if (photos.isEmpty) return [];
    try {
      // TODO: implement Firebase Storage upload, e.g.:
      // final urls = <String>[];
      // for (var i = 0; i < photos.length; i++) {
      //   final ref = FirebaseStorage.instance
      //       .ref('donations/${DateTime.now().millisecondsSinceEpoch}/$i');
      //   await ref.putFile(photos[i]);
      //   urls.add(await ref.getDownloadURL());
      // }
      // return urls;
      throw UnimplementedError('Photo upload not yet implemented.');
    } catch (e) {
      throw Exception('Photo upload failed: $e');
    }
  }

  // ── Delete existing donation ──────────────────────────────
  Future<void> deleteDonation(String id) async {
    try {
      await _repo.deleteDonation(id);
    } catch (e) {
      _errorMessage = 'Failed to delete donation.';
      _notify();
    }
  }

  // ── Reset (Create Another) ────────────────────────────────
  void reset() {
    firstNameController.clear();
    lastNameController.clear();
    locationController.clear();
    itemNameController.clear();
    descriptionController.clear();
    expiresController.clear();
    _condition    = '';
    _category     = '';
    _photos       = [];
    _submitted    = false;
    _isDonated    = false;
    _confirmDel   = false;
    _isLoading    = false;
    _errorMessage = null;
    _deleteTimer?.cancel();
    _notify();
  }

  // ── Dispose ───────────────────────────────────────────────
  @override
  void dispose() {
    _isDisposed = true;
    _deleteTimer?.cancel();
    firstNameController.removeListener(notifyListeners);
    itemNameController.removeListener(notifyListeners);
    descriptionController.removeListener(notifyListeners);
    firstNameController.dispose();
    lastNameController.dispose();
    locationController.dispose();
    itemNameController.dispose();
    descriptionController.dispose();
    expiresController.dispose();
    super.dispose();
  }
}