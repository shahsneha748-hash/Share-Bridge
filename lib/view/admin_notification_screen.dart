import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_notification_viewmodel.dart';
import 'admin_dashboard_view.dart';
import '../constants/colors.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminNotificationViewModel()..fetchNotifications(),
      child: const _NotificationBody(),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminNotificationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context, vm),
          Expanded(
            child: vm.isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
                : vm.notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: vm.notifications.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 8),
              itemBuilder: (_, i) => _NotificationCard(
                notification: vm.notifications[i],
                onTap: () =>
                    vm.markAsRead(vm.notifications[i].id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, AdminNotificationViewModel vm) {
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
            child: Text('Notifications',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
          if (vm.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllAsRead,
              child: const Text('Mark all read',
                  style: TextStyle(
                      color: Colors.white, fontSize: 12)),
            ),
        ],
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
            child: const Icon(Icons.notifications_none,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('You\'ll be notified when something happens',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'new_report': return Icons.flag_outlined;
      case 'new_user':   return Icons.person_add_outlined;
      default:           return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.successBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? AppColors.light2
                : AppColors.primary,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? AppColors.light2
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon,
                  size: 20,
                  color: notification.isRead
                      ? AppColors.primary
                      : Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textDark,
                            )),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.body,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(notification.timeAgo,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}