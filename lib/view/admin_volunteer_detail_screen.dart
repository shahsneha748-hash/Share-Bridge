import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/admin_volunteer_model.dart';
import '../viewmodel/admin_volunteer_viewmodel.dart';

class AdminVolunteerDetailScreen extends StatelessWidget {
  final AdminVolunteerModel volunteer;

  const AdminVolunteerDetailScreen({super.key, required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Volunteer Details',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar & name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      volunteer.name.isNotEmpty
                          ? volunteer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 32,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(volunteer.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _statusBadge(volunteer.status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Personal Info
            _sectionCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _detailRow(Icons.email, 'Email', volunteer.email),
                _detailRow(Icons.phone, 'Phone', volunteer.phone),
                _detailRow(Icons.location_on, 'Address', volunteer.address),
              ],
            ),

            const SizedBox(height: 14),

            // Volunteer Info
            _sectionCard(
              title: 'Volunteer Application',
              icon: Icons.volunteer_activism,
              children: [
                _detailRow(Icons.badge, 'Citizenship No.',
                    volunteer.citizenshipNumber),
                _detailRow(Icons.directions_bike, 'Vehicle',
                    volunteer.vehicle),
                _detailRow(Icons.access_time, 'Availability',
                    volunteer.availability),
                _detailRow(Icons.calendar_today, 'Submitted',
                    _formatDate(volunteer.submittedAt)),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = AppColors.primary;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      case 'Suspended':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(iso);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return iso;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final viewModel = context.read<AdminVolunteerViewModel>();

    if (volunteer.status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Approve',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _confirmAction(context, viewModel, 'Approved'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Reject',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _confirmAction(context, viewModel, 'Rejected'),
            ),
          ),
        ],
      );
    } else if (volunteer.status == 'Approved') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.pause_circle, color: Colors.grey),
          label: const Text('Suspend',
              style: TextStyle(color: Colors.grey)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => _confirmAction(context, viewModel, 'Suspended'),
        ),
      );
    } else if (volunteer.status == 'Suspended') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Reactivate',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => _confirmAction(context, viewModel, 'Approved'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _confirmAction(BuildContext context,
      AdminVolunteerViewModel viewModel, String newStatus) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$newStatus Volunteer?'),
        content: Text(
            'Are you sure you want to mark ${volunteer.name} as $newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                newStatus == 'Rejected' ? Colors.red : AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await viewModel.updateStatus(volunteer.id, newStatus);
              if (!context.mounted) return;
              Navigator.pop(context); // go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${volunteer.name} $newStatus')),
              );
            },
            child: Text(newStatus),
          ),
        ],
      ),
    );
  }
}