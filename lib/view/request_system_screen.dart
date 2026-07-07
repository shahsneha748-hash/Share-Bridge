import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/request_system_model.dart';
import '../viewmodel/request_system_view_model.dart';

class RequestSystemScreen extends StatelessWidget {
  const RequestSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Column(
        children: [
          _TopBar(),
          Expanded(
            child: Consumer<RequestSystemViewModel>(
              builder: (context, vm, _) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    _SearchBar(),
                    const SizedBox(height: 14),
                    _StatsRow(vm: vm),
                    const SizedBox(height: 12),
                    _FilterRow(vm: vm),
                    const SizedBox(height: 12),
                    if (vm.isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
                    else if (vm.errorMessage != null)
                      Center(child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.rejectedText)))
                    else if (vm.filteredRequests.isEmpty)
                        const _EmptyState()
                      else
                        ...vm.filteredRequests.map((r) => _RequestCard(request: r)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkGreen,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        left: 12,
        right: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.darkGreen, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Request',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<RequestSystemViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        onChanged: vm.setSearchQuery,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search requests...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ─── Stats Row ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final RequestSystemViewModel vm;
  const _StatsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          count: vm.acceptedCount,
          label: 'Accepted',
          color: AppColors.darkGreen,
          bgColor: AppColors.paleGreen,
        ),
        const SizedBox(width: 8),
        _StatCard(
          count: vm.rejectedCount,
          label: 'Rejected',
          color: AppColors.rejectedText,
          bgColor: AppColors.rejectedBg,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  const _StatCard({required this.count, required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Row ────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final RequestSystemViewModel vm;
  const _FilterRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RequestFilter.values.map((f) {
        final isActive = vm.filter == f;
        final label = f.name[0].toUpperCase() + f.name.substring(1);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => vm.setFilter(f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.darkGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppColors.darkGreen : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.white : AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Request Card ──────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final RequestSystemModel request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RequestSystemViewModel>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: request.donorName),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.donorName.isEmpty ? 'Unknown User' : request.donorName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.id.substring(0, request.id.length >= 8 ? 8 : request.id.length).toUpperCase()} · ${_formatDate(request.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    if (request.itemName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        request.itemName,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                    if (request.location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.darkGreen),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              request.location,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Status pill hidden for pending requests, shown for accepted/rejected.
              // If you want it gone completely, just delete this line.
              if (request.status != 'pending') _StatusPill(status: request.status),
            ],
          ),
          const SizedBox(height: 10),

          const SizedBox(height: 12),

          Row(
            children: [
              _ActionButton(
                label: 'Accept',
                icon: Icons.check,
                onTap: () => vm.updateStatus(request.id, 'accepted'),
                color: AppColors.darkGreen,
                bgColor: AppColors.paleGreen,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Reject',
                icon: Icons.close,
                onTap: () => vm.updateStatus(request.id, 'rejected'),
                color: AppColors.rejectedText,
                bgColor: AppColors.rejectedBg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─── Avatar ────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get initials {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.darkGreen,
      child: Text(initials,
          style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Status Pill ───────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final configs = {
      'accepted': (bg: AppColors.paleGreen, text: AppColors.darkGreen, border: AppColors.paleGreen),
      'rejected': (bg: AppColors.rejectedBg, text: AppColors.rejectedText, border: AppColors.rejectedBg),
    };
    final c = configs[status] ?? configs['accepted']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.border),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.text),
      ),
    );
  }
}

// ─── Action Button ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color; // text + icon color
  final Color? bgColor; // optional background color (pill style)
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('No requests found.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}