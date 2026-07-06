import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sharebridge/constants/colors.dart';
import 'package:sharebridge/repo/image_repo_impl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  // ── Form Key ─────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers (start empty, filled once real data loads) ───
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  bool _uploadingPhoto = false;
  String? _uid;
  String? _initial; // avatar letter
  String? _profilePicture; // current profile picture URL, if any

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Load real data from Firestore, same doc profile screen uses ──
  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    _uid = uid;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      final data = doc.data();

      if (data != null) {
        _nameController.text = data['fullName'] as String? ?? '';
        _emailController.text = data['email'] as String? ??
            FirebaseAuth.instance.currentUser?.email ?? '';
        _phoneController.text = data['phone'] as String? ?? '';
        _locationController.text = data['address'] as String? ?? '';
        _bioController.text = data['bio'] as String? ?? '';
        _profilePicture = data['profilePicture'] as String?;
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          _initial = _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()[0].toUpperCase()
              : 'U';
          _isLoading = false;
        });
      }
    }
  }

  // ── Dispose Controllers ──────────────────────────────────────
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ── Save Profile (writes straight to Firestore) ───────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uid == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection("users").doc(_uid).update({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );
      // Tell the profile screen a save happened so it can refetch.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ── Image picker: camera/gallery bottom sheet ─────────────────
  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.darkGreen),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.darkGreen),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;
    if (_uid == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final imageRepo = ImageRepoImpl();
      final url = await imageRepo.uploadImage(pickedFile.path);

      await FirebaseFirestore.instance.collection("users").doc(_uid).update({
        'profilePicture': url,
      });

      if (!mounted) return;
      setState(() => _profilePicture = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo upload failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundGreen,
        appBar: AppBar(
          backgroundColor: AppColors.darkGreen,
          elevation: 0,
          title: const Text("Edit Profile",
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      resizeToAvoidBottomInset: true,

      // ── App Bar ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),

        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // ── Profile Card ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // ── Avatar ───────────────────────────────
                    Stack(
                      children: [

                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 4,
                            ),
                            image: (_profilePicture != null && _profilePicture!.isNotEmpty)
                                ? DecorationImage(
                              image: NetworkImage(_profilePicture!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: (_profilePicture == null || _profilePicture!.isEmpty)
                              ? Center(
                            child: Text(
                              _initial ?? 'U',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              : null,
                        ),

                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _showImageSourceSheet,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppColors.onlineDot,
                                shape: BoxShape.circle,
                              ),
                              child: _uploadingPhoto
                                  ? const Padding(
                                padding: EdgeInsets.all(7),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                                  : const Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: _showImageSourceSheet,
                      child: const Text(
                        "Change Profile Photo",
                        style: TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Form Section ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // Name
                    _buildTextField(
                      label: "Full Name",
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email (read-only — changing email requires re-auth,
                    // so it's shown but disabled here)
                    _buildTextField(
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter phone number";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location
                    _buildTextField(
                      label: "Location",
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                    ),

                    const SizedBox(height: 16),

                    // Bio
                    _buildTextField(
                      label: "Bio",
                      icon: Icons.edit_note_outlined,
                      controller: _bioController,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Save Button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Custom TextField ─────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),

        const SizedBox(height: 8),

        // Field
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          style: TextStyle(
            color: enabled ? AppColors.darkText : AppColors.textMuted,
            fontSize: 14,
          ),

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.darkGreen,
              size: 20,
            ),

            filled: true,
            fillColor: AppColors.inputBg,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            hintStyle: const TextStyle(
              color: AppColors.textMuted,
            ),

            errorStyle: const TextStyle(
              fontSize: 12,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.darkGreen,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.2,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}