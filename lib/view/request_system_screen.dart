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
            child: Consumer<DonationRequestViewModel>(
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
        left: 20,
        right: 12,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.white, size: 24),
            onPressed: () {},
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
    final vm = context.read<DonationRequestViewModel>();
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
  final DonationRequestViewModel vm;
  const _StatsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(count: vm.pendingCount,  label: 'Pending',  color: AppColors.pendingText),
        const SizedBox(width: 8),
        _StatCard(count: vm.acceptedCount, label: 'Accepted', color: AppColors.accepted),
        const SizedBox(width: 8),
        _StatCard(count: vm.rejectedCount, label: 'Rejected', color: AppColors.rejectedText),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Row ────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final DonationRequestViewModel vm;
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
  final DonationRequestModel request;
  const _RequestCard({required this.request});

  static const _itemIcons = {
    'food':       Icons.restaurant,
    'stationery': Icons.edit,
    'clothes':    Icons.checkroom,
    'other':      Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DonationRequestViewModel>();
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
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: request.itemName),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.itemName.isEmpty ? 'Unnamed Item' : request.itemName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.id.substring(0, 8).toUpperCase()} · ${_formatDate(request.createdAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    if (request.location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.pendingText),
                          const SizedBox(width: 2),
                          Text(request.location, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _StatusPill(status: request.status),
            ],
          ),
          const SizedBox(height: 10),

          // Category chip
          if (request.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_itemIcons[request.category] ?? Icons.category, size: 13, color: AppColors.darkGreen),
                  const SizedBox(width: 4),
                  Text(
                    request.category[0].toUpperCase() + request.category.substring(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkGreen),
                  ),
                ],
              ),
            ),

          if (request.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(request.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],

          if (request.condition.isNotEmpty || request.weight.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (request.condition.isNotEmpty)
                  Text('Condition: ${request.condition}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                if (request.condition.isNotEmpty && request.weight.isNotEmpty)
                  const Text('  ·  ', style: TextStyle(color: AppColors.textMuted)),
                if (request.weight.isNotEmpty)
                  Text('Weight: ${request.weight}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              _ActionButton(label: 'Accept', icon: Icons.check,       onTap: () => vm.updateStatus(request.id, 'accepted')),
              const SizedBox(width: 8),
              _ActionButton(label: 'Pending', icon: Icons.access_time, onTap: () => vm.updateStatus(request.id, 'pending')),
              const SizedBox(width: 8),
              _ActionButton(label: 'Reject', icon: Icons.close,        onTap: () => vm.updateStatus(request.id, 'rejected')),
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
      'pending':  (bg: AppColors.pendingBg,  text: AppColors.pendingText,  border: AppColors.pendingBorder),
      'accepted': (bg: AppColors.acceptedBg, text: AppColors.accepted,     border: AppColors.acceptedBorder),
      'rejected': (bg: AppColors.rejectedBg, text: AppColors.rejectedText, border: AppColors.rejectedBorder),
    };
    final c = configs[status] ?? configs['pending']!;
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
  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: AppColors.darkGreen),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkText)),
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