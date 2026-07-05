import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/admin_volunteer_model.dart';
import '../viewmodel/admin_volunteer_viewmodel.dart';
import 'admin_volunteer_detail_screen.dart';

class AdminVolunteerScreen extends StatelessWidget {
  const AdminVolunteerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminVolunteerViewModel()..loadVolunteers(),
      child: const _AdminVolunteerBody(),
    );
  }
}

class _AdminVolunteerBody extends StatelessWidget {
  const _AdminVolunteerBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminVolunteerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Volunteers',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => viewModel.loadVolunteers(),
        child: Column(
          children: [
            _buildStatsRow(viewModel),
            _buildFilterChips(context, viewModel),
            Expanded(
              child: viewModel.volunteers.isEmpty
                  ? const Center(
                  child: Text('No volunteers found',
                      style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: viewModel.volunteers.length,
                itemBuilder: (context, index) {
                  return _buildVolunteerCard(
                      context,
                      viewModel,
                      viewModel.volunteers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AdminVolunteerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _statCard('Pending', viewModel.pendingCount, Colors.orange),
          const SizedBox(width: 10),
          _statCard('Approved', viewModel.approvedCount, AppColors.primary),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, AdminVolunteerViewModel viewModel) {
    final filters = ['All', 'Pending', 'Approved', 'Rejected', 'Suspended'];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: filters.map((filter) {
          final isSelected = viewModel.selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12),
              onSelected: (_) => viewModel.setFilter(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVolunteerCard(BuildContext context,
      AdminVolunteerViewModel viewModel, AdminVolunteerModel volunteer) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: viewModel,
                child: AdminVolunteerDetailScreen(volunteer: volunteer),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      volunteer.name.isNotEmpty
                          ? volunteer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(volunteer.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  _statusBadge(volunteer.status),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              _infoRow(Icons.access_time, 'Availability',
                  volunteer.availability),
              _infoRow(Icons.directions_bike, 'Vehicle', volunteer.vehicle),
              _infoRow(Icons.badge, 'Citizenship No.',
                  volunteer.citizenshipNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButtons(BuildContext context,
      AdminVolunteerViewModel viewModel, AdminVolunteerModel volunteer) {
    if (volunteer.status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              onPressed: () =>
                  _confirmAction(context, viewModel, volunteer, 'Approved'),
              child: const Text('Approve'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () =>
                  _confirmAction(context, viewModel, volunteer, 'Rejected'),
              child: const Text('Reject'),
            ),
          ),
        ],
      );
    } else if (volunteer.status == 'Approved') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: () =>
              _confirmAction(context, viewModel, volunteer, 'Suspended'),
          child: const Text('Suspend'),
        ),
      );
    } else if (volunteer.status == 'Suspended') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style:
          OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
          onPressed: () =>
              _confirmAction(context, viewModel, volunteer, 'Approved'),
          child: const Text('Reactivate'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _confirmAction(BuildContext context, AdminVolunteerViewModel viewModel,
      AdminVolunteerModel volunteer, String newStatus) {
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
            onPressed: () {
              Navigator.pop(dialogContext);
              viewModel.updateStatus(volunteer.id, newStatus);
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