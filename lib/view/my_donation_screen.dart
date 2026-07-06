import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sharebridge/constants/colors.dart';
import 'package:sharebridge/components/app_header.dart';
import 'package:sharebridge/model/donation_record.dart';
import 'package:sharebridge/viewmodel/my_donation_view_model.dart';

class MyDonationsScreen extends StatefulWidget {
  final String uid;
  const MyDonationsScreen({super.key, required this.uid});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyDonationsViewModel>().getDonationsForUser(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyDonationsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'My Donations'),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
                  : vm.donations.isEmpty
                  ? const Center(
                child: Text(
                  "You haven't shared any items yet.",
                  style: TextStyle(color: AppColors.textMuted),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vm.donations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _buildDonationCard(vm.donations[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(DonationRecord record) {
    final donation = record.model;
    final dateLabel = record.createdAt != null
        ? '${record.createdAt!.day}/${record.createdAt!.month}/${record.createdAt!.year}'
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          if (donation.images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                donation.images.first,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              ),
            )
          else
            _fallbackIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.itemName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkText),
                ),
                const SizedBox(height: 3),
                Text(
                  '${donation.category}${dateLabel.isNotEmpty ? ' · $dateLabel' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          _buildStatusChip(record.status),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.volunteer_activism, color: AppColors.darkGreen),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    Color border;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'donated':
        bg = AppColors.acceptedBg;
        text = AppColors.accepted;
        border = AppColors.acceptedBorder;
        break;
      case 'rejected':
        bg = AppColors.rejectedBg;
        text = AppColors.rejectedText;
        border = AppColors.rejectedBorder;
        break;
      default: // pending
        bg = AppColors.pendingBg;
        text = AppColors.pendingText;
        border = AppColors.pendingBorder;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, color: text, fontWeight: FontWeight.w600),
      ),
    );
  }
}