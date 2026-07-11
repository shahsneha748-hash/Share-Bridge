import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodel/volunteer_view_model.dart';
import 'volunteer_pending screen.dart';

class VolunteerVerificationScreen extends StatefulWidget {
  const VolunteerVerificationScreen({super.key});
  @override
  State<VolunteerVerificationScreen> createState() =>
      _VolunteerVerificationScreenState();
}

class _VolunteerVerificationScreenState
    extends State<VolunteerVerificationScreen> {
  final TextEditingController citizenshipController =
  TextEditingController();
  bool agreed = false;

  @override
  void dispose() {
    citizenshipController.dispose();
    super.dispose();
  }

  Widget buildCard(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4E8C2)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text("Please log in to continue."),
        ),
      );
    }

    final uid = user.uid;
    final vm = context.watch<VolunteerViewModel>();
    final error = vm.getMissingFieldMessage(
      citizenshipController.text,
      agreed,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
            color: const Color(0xFF3A5C2E),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF3A5C2E),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Volunteer Verification",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SCREEN CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Complete your verification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "We verify volunteers to ensure safe deliveries.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // IDENTITY CARD
                  buildCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Identity Verification",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: citizenshipController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: "Citizenship Number",
                            border: const OutlineInputBorder(),
                            suffixIcon: citizenshipController.text.isNotEmpty
                                ? const Icon(Icons.check_circle,
                                color: Colors.green)
                                : const Icon(Icons.info_outline,
                                color: Colors.grey),
                          ),
                        ),

                        const SizedBox(height: 12),

                        ListTile(
                          leading: Icon(
                            vm.citizenshipImage == null
                                ? Icons.badge
                                : Icons.check_circle,
                            color: vm.citizenshipImage == null
                                ? Colors.grey
                                : Colors.green,
                          ),
                          title: const Text("Upload Citizenship Document"),
                          onTap: () async {
                            final source =
                            await showModalBottomSheet<ImageSource>(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text("Take Photo"),
                                    onTap: () => Navigator.pop(
                                        context, ImageSource.camera),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text("Choose from Gallery"),
                                    onTap: () => Navigator.pop(
                                        context, ImageSource.gallery),
                                  ),
                                ],
                              ),
                            );

                            if (source == null) return;

                            vm.pickCitizenship(source);
                          },
                        ),

                        ListTile(
                          leading: Icon(
                            vm.selfieImage == null
                                ? Icons.camera_alt
                                : Icons.check_circle,
                            color: vm.selfieImage == null
                                ? Colors.grey
                                : Colors.green,
                          ),
                          title: const Text("Take Selfie (Front Camera Only)"),
                          onTap: vm.takeSelfie,
                        ),
                      ],
                    ),
                  ),

                  //  DELIVERY CARD
                  buildCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Delivery Preferences",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text("Vehicle Type"),

                        Wrap(
                          spacing: 10,
                          children: ["Bike", "Car", "Walking", "Scooter"]
                              .map((e) => ChoiceChip(
                            label: Text(e),
                            selected:
                            vm.vehicle != null && vm.vehicle == e,
                            onSelected: (_) => vm.setVehicle(e),
                            selectedColor: const Color(0xFF3A5C2E),
                            labelStyle: TextStyle(
                              color: vm.vehicle == e
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ))
                              .toList(),
                        ),

                        const SizedBox(height: 12),

                        const Text("Availability"),

                        Wrap(
                          spacing: 10,
                          children: ["Morning", "Afternoon", "Evening"]
                              .map((e) => ChoiceChip(
                            label: Text(e),
                            selected: vm.availability != null &&
                                vm.availability == e,
                            onSelected: (_) => vm.setAvailability(e),
                            selectedColor: const Color(0xFF3A5C2E),
                            labelStyle: TextStyle(
                              color: vm.availability == e
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  //  ADMIN NOTE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF3A5C2E)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Admin will verify your documents before approval.",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  //  CHECKBOX
                  Row(
                    children: [
                      Checkbox(
                        value: agreed,
                        onChanged: (v) {
                          setState(() {
                            agreed = v ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I certify that the information and documents provided are true and belong to me",
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  //  SUBMIT

                  if (error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A5C2E),
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (!vm.isFullyValid || vm.loading)
                          ? null
                          : () async {
                        try {
                          await vm.submit(
                            userId: uid,
                            citizenshipNumber:
                            citizenshipController.text,
                          );

                          if (!context.mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const VolunteerPendingScreen(),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(vm.errorMessage ??
                                  "Upload failed. Please try again."),
                            ),
                          );
                        }
                      },
                      child: vm.loading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        "Submit Application",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}