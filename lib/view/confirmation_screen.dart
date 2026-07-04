import 'package:flutter/material.dart';
import '../components/success_screen.dart';
import '../model/create_donation_model.dart';
import '../viewmodel/create_donation_view_model.dart';

class ConfirmationScreen extends StatelessWidget {
  final CreateDonationModel donation;
  final CreateDonationViewModel vm;

  const ConfirmationScreen({
    super.key,
    required this.donation,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ── APP BAR ──
      appBar: AppBar(
        title: const Text(
          "Confirm Donation",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3D5A3E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── BODY ──
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ── TITLE ──
            const Text(
              "Please review your donation details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // ── DETAILS CARD ──
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _buildRow("Item Name", donation.itemName),
                      _buildRow("Category", donation.category),
                      _buildRow("Sub Category", donation.subcategory),
                      _buildRow("Location", donation.location),
                      _buildRow("Condition", donation.condition),
                      _buildRow(
                        "Quantity",
                        "${donation.portionCount} ${donation.unit}",
                      ),

                      if (donation.expiryDate.isNotEmpty)
                        _buildRow(
                          "Expiry Date",
                          donation.expiryDate.split("T")[0],
                        ),

                      const SizedBox(height: 10),

                      const Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(donation.description),

                      const SizedBox(height: 10),

                      const Text(
                        "Note",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(donation.note),

                      const SizedBox(height: 20),

                      // ── IMAGES ──
                      if (donation.images.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Images",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),

                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: donation.images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Image.network(
                                      donation.images[index],
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── BUTTONS ──
            Row(
              children: [

                // EDIT BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Edit"),
                  ),
                ),

                const SizedBox(width: 10),

                // CONFIRM BUTTON
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5A3E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final success = await vm.submit();

                      if (success && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SuccessScreen(
                              donation: donation,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── REUSABLE ROW UI ──
  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}