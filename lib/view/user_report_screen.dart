import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_report_viewmodel.dart';
import '../model/user_report_model.dart';

class UserReportScreen extends StatelessWidget {
  const UserReportScreen({super.key});

  static const Color _topBarColor = Color(0xFF2D5A14);
  static const Color _greenMedium = Color(0xFF4A7C26);
  static const Color _greenLight  = Color(0xFFEAF3DE);
  static const Color _bgColor     = Color(0xFFF9F9F9);
  static const Color _darkButton  = Color(0xFF2D3A28);
  static const Color _creamCard   = Color(0xFFF5F0E8);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserReportViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _bgColor,
        body: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Consumer<UserReportViewModel>(
                builder: (context, vm, _) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWarningBanner(),
                      const SizedBox(height: 20),
                      _buildReportTypeSection(vm),
                      const SizedBox(height: 20),
                      if (vm.selectedType.isNotEmpty) ...[
                        _buildReportingCard(vm),
                        const SizedBox(height: 20),
                      ],
                      _buildReasonSection(vm),
                      const SizedBox(height: 20),
                      _buildDetailsSection(vm),
                      const SizedBox(height: 20),
                      _buildAttachEvidence(context, vm),
                      const SizedBox(height: 20),
                      _buildAnonymousToggle(vm),
                      const SizedBox(height: 24),
                      _buildSubmitButton(context, vm),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Color(0xFFE53935), size: 20),
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
                  style: TextStyle(color: Color(0xFFE53935), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSection(UserReportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("What are you reporting?",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(UserReportModel.reportTypes.length, (index) {
            final type = UserReportModel.reportTypes[index];
            final bool isSelected = vm.selectedType == type.label;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: index < UserReportModel.reportTypes.length - 1
                        ? 10
                        : 0),
                child: GestureDetector(
                  onTap: () => vm.selectType(type.label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? _greenMedium : _greenLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(type.icon,
                            color: isSelected ? Colors.white : _greenMedium,
                            size: 26),
                        const SizedBox(height: 8),
                        Text(
                          type.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
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
      ],
    );
  }

  Widget _buildReportingCard(UserReportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reporting",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        if (vm.isLoadingItems)
          const Center(child: CircularProgressIndicator())
        else if (vm.selectedType == 'A User' && vm.selectedUser == null)
          _buildUserPickerList(vm)
        else
          GestureDetector(
            onTap: () => vm.selectType(vm.selectedType),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(vm.selectedType + vm.reportingName),
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
                        vm.reportingInitial,
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
                            vm.reportingName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (vm.reportingStars > 0)
                                ...List.generate(
                                  5,
                                      (i) => Icon(Icons.star,
                                      size: 13,
                                      color: i < vm.reportingStars
                                          ? const Color(0xFFFFC107)
                                          : Colors.grey.shade300),
                                ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vm.reportingSubtitle,
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
          ),
      ],
    );
  }

  Widget _buildUserPickerList(UserReportViewModel vm) {
    if (vm.usersList.isEmpty) {
      return const Center(
        child: Text('No users found',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      children: vm.usersList.map((user) {
        return GestureDetector(
          onTap: () => vm.selectUser(user),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _creamCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _greenMedium,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(user.email,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ...List.generate(
                  5,
                      (i) => Icon(Icons.star,
                      size: 12,
                      color: i < user.rating.round()
                          ? const Color(0xFFFFC107)
                          : Colors.grey.shade300),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonSection(UserReportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Reason for report",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        for (int i = 0; i < UserReportModel.reasons.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: _reasonChip(vm, UserReportModel.reasons[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < UserReportModel.reasons.length
                    ? _reasonChip(vm, UserReportModel.reasons[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
          if (i + 2 < UserReportModel.reasons.length)
            const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _reasonChip(UserReportViewModel vm, String reason) {
    final bool isSelected = vm.selectedReason == reason;
    return GestureDetector(
      onTap: () => vm.selectReason(reason),
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

  Widget _buildDetailsSection(UserReportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              color: vm.charCount >= 15
                  ? _greenMedium
                  : const Color(0xFFC8E6C9),
            ),
          ),
          child: TextField(
            controller: vm.detailsController,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText:
              "Describe what happened in detail. The more context you "
                  "provide, the faster our team can review this report ..",
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
                vm.charCount >= 15 ? "✓ Good to go!" : "Min. 15 characters",
                style: TextStyle(
                  fontSize: 12,
                  color: vm.charCount >= 15 ? _greenMedium : Colors.red,
                  fontWeight: vm.charCount >= 15
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              Text("${vm.charCount}/500",
                  style: TextStyle(
                      fontSize: 12,
                      color: vm.charCount >= 15 ? _greenMedium : Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachEvidence(BuildContext context, UserReportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Attach evidence (optional)",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 12),
        vm.attachedImage != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                vm.attachedImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: vm.removeImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        )
            : GestureDetector(
          onTap: () => vm.pickImage(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC8E6C9)),
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
      ],
    );
  }

  Widget _buildAnonymousToggle(UserReportViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                Text("Your name won't be shown to the reported user",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: vm.isAnonymous,
            onChanged: vm.toggleAnonymous,
            activeColor: _greenMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, UserReportViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: vm.canSubmit ? _darkButton : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: vm.canSubmit ? 2 : 0,
        ),
        onPressed: vm.canSubmit ? () => vm.submitReport(context) : null,
        child: vm.isSubmitting
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
    );
  }
}