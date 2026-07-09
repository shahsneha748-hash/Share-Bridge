import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../components/category_chip.dart';
import '../components/custom_section.dart';
import '../components/custom_text_field.dart';
import '../components/portion_section.dart';
import '../components/radio_chip.dart';
import '../components/tag_section.dart';
import '../components/upload_photos_section.dart';
import '../constants/colors.dart';
import '../repo/create_donation_repo.dart';
import '../repo/image_repo.dart';
import '../viewmodel/create_donation_view_model.dart';
import 'navigation_screen.dart';
import 'pickup_location_field.dart';

class CreateDonationScreen extends StatelessWidget {
  const CreateDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateDonationViewModel(
        context.read<CreateDonationRepository>(),
        context.read<ImageRepo>(),
      ),
      child: const _CreateDonationView(),
    );
  }
}


class _CreateDonationView extends StatefulWidget {
  const _CreateDonationView();

  @override
  State<_CreateDonationView> createState() => _CreateDonationViewState();
}

class _CreateDonationViewState extends State<_CreateDonationView> {
  Future<void> _pickImage(CreateDonationViewModel vm, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      await vm.addImage(picked.path);
    }
  }

  Future<void> _showAddTagDialog(
      BuildContext context, CreateDonationViewModel vm) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Tag"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter tag"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              vm.addTag(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateDonationViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Donation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSection(
              title: "Item Name",
              child: CustomTextField(
                hint: "Enter item name",
                onChanged: vm.setItemName,
              ),
            ),

            const SizedBox(height: 12),

            CustomSection(
              title: "Category",
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: vm.categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: cat['label'],
                        icon: cat['icon'],
                        isSelected:
                        vm.model.category == cat['id'],
                        onTap: () =>
                            vm.setCategory(cat['id']),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (vm.isFood)
              CustomSection(
                title: "Expiry Date",
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );

                    if (date != null) {
                      vm.setExpiry(date.toIso8601String());
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vm.model.expiryDate.isEmpty
                          ? "Select expiry date"
                          : vm.model.expiryDate.split("T")[0],
                    ),
                  ),
                ),
              ),

            if (vm.isFood)
              const SizedBox(height: 12),

            CustomSection(
              title: "Sub Category",
              child: CustomTextField(
                hint: "Enter sub category",
                onChanged: vm.setSubcategory,
              ),
            ),

            const SizedBox(height: 12),

            CustomSection(
              title: "Pickup Location",
              child: PickupLocationField(
                value: vm.model.location,
                onChanged: vm.setLocation,
                onCoordinatesPicked: vm.setCoordinates, // add this line
              ),
            ),

            const SizedBox(height: 12),

            CustomSection(
              title: "Condition",
              child: Wrap(
                spacing: 8,
                children: vm.conditions.map((c) {
                  return RadioChip(
                    label: c,
                    isSelected: vm.model.condition == c,
                    onTap: () => vm.setCondition(c),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            PortionSection(
              quantity: vm.model.portionCount,
              unit: vm.model.unit,
              onIncrement: vm.incrementPortion,
              onDecrement: vm.decrementPortion,
              onUnitChanged: vm.setUnit,
            ),

            const SizedBox(height: 12),

            CustomSection(
              title: "Weight",
              child: CustomTextField(
                hint: "e.g. 2kg, 500g",
                onChanged: (v) => vm.setWeight(v),
              ),
            ),

            const SizedBox(height: 12),

            CustomSection(
              title: "Description",
              child: CustomTextField(
                hint: "Describe the item...",
                maxLines: 4,
                onChanged: vm.setDescription,
              ),
            ),

            const SizedBox(height: 12),

            CustomSection(
              title: "Note",
              child: CustomTextField(
                hint: "Any special note...",
                maxLines: 2,
                onChanged: (v) => vm.setNote(v),
              ),
            ),

            const SizedBox(height: 12),


            UploadPhotosSection(
              photoUrls: vm.images,
              uploading: vm.uploadingImage,
              onPickFromGallery: () =>
                  _pickImage(vm, ImageSource.gallery),
              onPickFromCamera: () =>
                  _pickImage(vm, ImageSource.camera),
              onRemovePhoto: vm.removeImage,
            ),

            const SizedBox(height: 12),

            TagSection(
              tags: vm.model.tags,
              onAddTag: () =>
                  _showAddTagDialog(context, vm),
              onRemoveTag: vm.removeTag,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: vm.canSubmit
                    ? () async {
                  final success = await vm.submit();
                  if (context.mounted) {
                    if (success) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NavigationScreen(),
                        ),
                            (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to post donation. Try again."),
                        ),
                      );
                    }
                  }
                }
                    : null,
                child: const Text(
                  "Post Donation",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}