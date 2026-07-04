import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/donation_admin_viewmodel.dart';
import '../model/donation_admin_model.dart';
import 'admin_dashboard_view.dart';

class DonationAdminScreen extends StatelessWidget {
  const DonationAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DonationAdminViewModel()..loadDonations(),
      child: const _DonationBody(),
    );
  }
}

class _DonationBody extends StatelessWidget {
  const _DonationBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DonationAdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context, vm),
          _buildSummaryRow(vm),
          _buildSearchBar(context, vm),
          _buildFilterRow(vm),
          Expanded(
            child: vm.isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
                : vm.filteredDonations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: vm.filteredDonations.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) => _DonationCard(
                donation: vm.filteredDonations[i],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, DonationAdminViewModel vm) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4, right: 16, bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Donations',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${vm.totalDonations} total',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(DonationAdminViewModel vm) {
    final stats = {
      'Total':     vm.totalDonations,
      'Available': vm.availableCount,
      'Taken':     vm.takenCount,
      'Food':      vm.foodCount,
    };
    final colors = {
      'Total':     AppColors.primary,
      'Available': AppColors.successText,
      'Taken':     AppColors.primary,
      'Food':      AppColors.successText,
    };

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        children: stats.entries.map((e) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(e.value.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors[e.key],
                      )),
                  const SizedBox(height: 2),
                  Text(e.key,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, DonationAdminViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: TextField(
        onChanged: vm.search,
        decoration: InputDecoration(
          hintText: 'Search donations...',
          hintStyle: const TextStyle(
              fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search,
              color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(DonationAdminViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            _ActiveChip(
              label: 'Available',
              isActive: vm.filterStatus == DonationStatus.available,
              onTap: () => vm.setStatusFilter(
                vm.filterStatus == DonationStatus.available
                    ? null : DonationStatus.available,
              ),
            ),
            const SizedBox(width: 8),
            _ActiveChip(
              label: 'Taken',
              isActive: vm.filterStatus == DonationStatus.taken,
              onTap: () => vm.setStatusFilter(
                vm.filterStatus == DonationStatus.taken
                    ? null : DonationStatus.taken,
              ),
            ),
            const SizedBox(width: 8),
            _ActiveChip(
              label: 'Food',
              isActive: vm.filterCategory == DonationCategory.food,
              onTap: () => vm.setCategoryFilter(
                vm.filterCategory == DonationCategory.food
                    ? null : DonationCategory.food,
              ),
            ),
            const SizedBox(width: 8),
            _ActiveChip(
              label: 'Clothes',
              isActive: vm.filterCategory == DonationCategory.clothes,
              onTap: () => vm.setCategoryFilter(
                vm.filterCategory == DonationCategory.clothes
                    ? null : DonationCategory.clothes,
              ),
            ),
            const SizedBox(width: 8),
            _ActiveChip(
              label: 'Stationery',
              isActive: vm.filterCategory == DonationCategory.stationery,
              onTap: () => vm.setCategoryFilter(
                vm.filterCategory == DonationCategory.stationery
                    ? null : DonationCategory.stationery,
              ),
            ),
            const SizedBox(width: 8),
            _ActiveChip(
              label: 'Others',
              isActive: vm.filterCategory == DonationCategory.others,
              onTap: () => vm.setCategoryFilter(
                vm.filterCategory == DonationCategory.others
                    ? null : DonationCategory.others,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.light2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.card_giftcard_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('No donations found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('Try a different search or filter',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final AdminDonation donation;
  const _DonationCard({required this.donation});

  Color get _statusColor {
    switch (donation.status) {
      case DonationStatus.available: return AppColors.successText;
      case DonationStatus.taken:     return AppColors.primary;
    }
  }

  Color get _statusBg {
    switch (donation.status) {
      case DonationStatus.available: return AppColors.successBg;
      case DonationStatus.taken:     return AppColors.light2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DonationAdminViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.light1,
                child: Text(donation.donorInitials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successText,
                    )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donation.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        )),
                    Text('by ${donation.donorName}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(donation.statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDF2E7)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(donation.categoryLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successText,
                    )),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.location_on_outlined,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text(donation.location,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              const Icon(Icons.access_time_outlined,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text(donation.postedTime,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _confirmRemove(context, vm),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline,
                          size: 16, color: AppColors.dangerText),
                      SizedBox(width: 6),
                      Text('Remove post',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dangerText,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, DonationAdminViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Post?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(
          '"${donation.title}" will be permanently removed.',
          style: const TextStyle(
              fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              vm.removePost(donation.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '"${donation.title}" removed successfully',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActiveChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : const Color(0xFFB8C8B0),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textDark,
            )),
      ),
    );
  }
}