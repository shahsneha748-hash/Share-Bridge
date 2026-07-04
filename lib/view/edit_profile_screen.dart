import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  // ── Theme Colors ─────────────────────────────────────────────
  static const Color kPrimary  = Color(0xFF2D5A27);
  static const Color kDark     = Color(0xFF1A3A15);
  static const Color kLight    = Color(0xFFF5F7F4);
  static const Color kCard     = Color(0xFFFFFFFF);
  static const Color kAccent   = Color(0xFF4CAF50);
  static const Color kTextDark = Color(0xFF1C2B1A);
  static const Color kTextGrey = Color(0xFF7A8A78);

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
  String? _uid;
  String? _initial; // avatar letter

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kLight,
        appBar: AppBar(
          backgroundColor: kPrimary,
          elevation: 0,
          title: const Text("Edit Profile",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: const Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: kLight,
      resizeToAvoidBottomInset: true,

      // ── App Bar ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),

        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
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
                  color: kCard,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                            color: kPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _initial ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: kAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Change Profile Photo",
                        style: TextStyle(
                          color: kPrimary,
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
                  color: kCard,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                    backgroundColor: kPrimary,
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
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
            color: kTextDark,
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
            color: enabled ? kTextDark : kTextGrey,
            fontSize: 14,
          ),

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: kPrimary,
              size: 20,
            ),

            filled: true,
            fillColor: kLight,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            hintStyle: const TextStyle(
              color: kTextGrey,
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
                color: kPrimary,
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