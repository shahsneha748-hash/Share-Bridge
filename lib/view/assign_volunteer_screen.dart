import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/request_system_model.dart';
import '../model/volunteer_request_model.dart';
import '../viewmodel/volunteer_request_viewmodel.dart';

class AssignVolunteerScreen extends StatefulWidget {
  final RequestSystemModel request;
  const AssignVolunteerScreen({
    super.key,
    required this.request,
  });
  @override
  State<AssignVolunteerScreen> createState() =>
      _AssignVolunteerScreenState();
}

class _AssignVolunteerScreenState extends State<AssignVolunteerScreen> {
  final TextEditingController vehicleController = TextEditingController();
  late final TextEditingController pickupLocationController;
  late final TextEditingController weightController;
  late final TextEditingController portionCountController;
  late final TextEditingController portionController;
  late final TextEditingController receiverPhoneController;
  late final TextEditingController deliveryLocationController;
  late final TextEditingController receiverNameController;
  late final TextEditingController donorPhoneController; // 👈 ADDED
  String? selectedTimeSlot;
  TimeOfDay? selectedClockTime;
  bool isLoadingWeight = true;
  String? weightFetchError;
  bool isLoadingDonorPhone = true; // 👈 ADDED
  String? donorPhoneFetchError; // 👈 ADDED
  static const List<String> vehicleSuggestions = [
    "Bike",
    "Car",
    "Walking",
    "Scooter",
  ];

  @override
  void initState() {
    super.initState();
    final request = widget.request;
    pickupLocationController =
        TextEditingController(text: request.location);
    deliveryLocationController =
        TextEditingController(text: request.receiverAddress);
    receiverNameController =
        TextEditingController(text: request.receiverName);
    weightController = TextEditingController();
    portionCountController =
        TextEditingController(text: request.portionCount.toString());
    portionController =
        TextEditingController(text: request.portion);
    receiverPhoneController =
        TextEditingController(text: request.receiverPhone);
    donorPhoneController = TextEditingController(); // 👈 ADDED
    _fetchWeightFromDonation();
    _fetchDonorPhone(); // 👈 ADDED
  }

  Future<void> _fetchWeightFromDonation() async {
    final donationId = widget.request.donationId;
    if (donationId.isEmpty) {
      setState(() {
        isLoadingWeight = false;
        weightFetchError = "No linked donation found";
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .get();
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data();
        weightController.text = data?['weight'] ?? '';
        setState(() {
          isLoadingWeight = false;
        });
      } else {
        setState(() {
          isLoadingWeight = false;
          weightFetchError = "Donation not found";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingWeight = false;
        weightFetchError = "Failed to load weight";
      });
    }
  }

  // 👈 ADDED — fetches donor's phone number from their user profile
  Future<void> _fetchDonorPhone() async {
    final donorId = widget.request.donorId;
    if (donorId.isEmpty) {
      setState(() {
        isLoadingDonorPhone = false;
        donorPhoneFetchError = "No donor linked";
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(donorId)
          .get();
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data();
        final phone = data?['phone'] ?? data?['phoneNumber'] ?? '';
        donorPhoneController.text = phone;
        setState(() {
          isLoadingDonorPhone = false;
          if (phone.isEmpty) donorPhoneFetchError = "No phone on donor profile";
        });
      } else {
        setState(() {
          isLoadingDonorPhone = false;
          donorPhoneFetchError = "Donor profile not found";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingDonorPhone = false;
        donorPhoneFetchError = "Failed to load donor phone";
      });
    }
  }

  @override
  void dispose() {
    vehicleController.dispose();
    pickupLocationController.dispose();
    deliveryLocationController.dispose();
    receiverNameController.dispose();
    weightController.dispose();
    portionCountController.dispose();
    portionController.dispose();
    receiverPhoneController.dispose();
    donorPhoneController.dispose(); // 👈 ADDED
    super.dispose();
  }

  Future<void> _pickClockTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedClockTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedClockTime = picked;
      });
    }
  }

  String? get combinedPreferredTime {
    if (selectedTimeSlot == null && selectedClockTime == null) return null;
    final timeText =
    selectedClockTime != null ? selectedClockTime!.format(context) : null;
    if (selectedTimeSlot != null && timeText != null) {
      return "$selectedTimeSlot • $timeText";
    }
    return selectedTimeSlot ?? timeText;
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        title: const Text(
          "Assign Volunteer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Request",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _infoCard("Donation Item", request.itemName),

            // DONOR PHONE (fetched live from users collection)
            TextField(
              controller: donorPhoneController,
              enabled: !isLoadingDonorPhone && donorPhoneFetchError != null, // 👈 CHANGED
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Donor Phone",
                hintText: isLoadingDonorPhone
                    ? "Loading..."
                    : (donorPhoneFetchError != null
                    ? "Enter donor's phone number"
                    : null),
                helperText: donorPhoneFetchError,
                helperStyle: const TextStyle(color: Colors.red),
                suffixIcon: isLoadingDonorPhone
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: receiverNameController,
              decoration: InputDecoration(
                labelText: "Receiver Name",
                hintText: "Enter receiver name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deliveryLocationController,
              decoration: InputDecoration(
                labelText: "Delivery Location",
                hintText: "Enter receiver delivery address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Item Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: weightController,
              enabled: !isLoadingWeight,
              decoration: InputDecoration(
                labelText: "Weight",
                hintText: isLoadingWeight ? "Loading..." : "e.g. 5 kg",
                helperText: weightFetchError,
                helperStyle: const TextStyle(color: Colors.red),
                suffixIcon: isLoadingWeight
                    ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: portionCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Quantity",
                      hintText: "e.g. 3",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: portionController,
                    decoration: InputDecoration(
                      labelText: "Unit",
                      hintText: "e.g. boxes, pieces",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Receiver Contact",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: receiverPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Receiver Phone Number",
                hintText: "e.g. 98XXXXXXXX",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pickup Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pickupLocationController,
              decoration: InputDecoration(
                labelText: "Pickup Location",
                hintText: "Confirm or edit pickup address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: vehicleController,
              decoration: InputDecoration(
                labelText: "Preferred Vehicle",
                hintText: "e.g. Bike, Car, or your own",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: vehicleSuggestions.map((option) {
                return ActionChip(
                  label: Text(option),
                  onPressed: () {
                    setState(() {
                      vehicleController.text = option;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedTimeSlot,
              decoration: InputDecoration(
                labelText: "Preferred Time of Day",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ["Morning", "Afternoon", "Evening"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTimeSlot = value;
                });
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickClockTime,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Exact Time (optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                child: Text(
                  selectedClockTime != null
                      ? selectedClockTime!.format(context)
                      : "Tap to pick a time",
                  style: TextStyle(
                    color: selectedClockTime != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A5C2E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (pickupLocationController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a pickup location"),
                      ),
                    );
                    return;
                  }
                  final parsedPortionCount =
                  int.tryParse(portionCountController.text.trim());
                  if (parsedPortionCount == null || parsedPortionCount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid quantity"),
                      ),
                    );
                    return;
                  }
                  if (receiverPhoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a receiver phone number"),
                      ),
                    );
                    return;
                  }
                  final vm = context.read<VolunteerRequestViewModel>();
                  final volunteerRequest = VolunteerRequestModel(
                    donationId: request.donationId,
                    donorId: request.donorId,
                    donorName: request.donorName,
                    receiverId: request.receiverId,
                    receiverName: receiverNameController.text.trim(),
                    pickupLocation: pickupLocationController.text.trim(),
                    deliveryLocation: deliveryLocationController.text.trim(),
                    itemName: request.itemName,
                    vehicle: vehicleController.text.trim().isEmpty
                        ? null
                        : vehicleController.text.trim(),
                    preferredTime: combinedPreferredTime,
                    weight: weightController.text.trim(),
                    portion: portionController.text.trim(),
                    portionCount: parsedPortionCount,
                    receiverPhone: receiverPhoneController.text.trim(),
                    donorPhone: donorPhoneController.text.trim(), // 👈 ADDED
                  );
                  try {
                    await vm.createRequest(volunteerRequest);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Volunteer request sent")),
                    );
                    Navigator.pop(context); // 👈 just close this screen, go back to donor's previous screen
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text(
                  "Find Volunteer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}