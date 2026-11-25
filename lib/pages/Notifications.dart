import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/notification_sound_service.dart';
import '../services/time_format.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationService.getNotifications();
      final scope = await AuthService.getNotificationAccountScope();
      if (scope != null && scope.isNotEmpty) {
        await NotificationSoundService.instance.observeNotifications(
          accountScope: scope,
          notifications: notifications,
        );
      }
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    final id = int.tryParse(notification['id'].toString());
    if (id == null) return;
    await NotificationService.markAsRead(id);
    if (mounted) {
      setState(() {
        notification['is_read'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.glassFill,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
      ),
      body: ShellAtmosphere(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: _notifications.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 220),
                          Center(child: Text('No notifications.')),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final isRead = notification['is_read'] == true;
                          final isHighPriority =
                              notification['priority']
                                  ?.toString()
                                  .toLowerCase() ==
                              'high';
                          return GlassCard(
                            padding: EdgeInsets.zero,
                            borderRadius: 14,
                            child: ListTile(
                              leading: Icon(
                                isHighPriority
                                    ? Icons.warning_amber_rounded
                                    : isRead
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: isHighPriority
                                    ? Colors.red.shade700
                                    : isRead
                                    ? AppColors.muted
                                    : AppColors.primary,
                              ),
                              title: Row(
                                children: [
                                  if (isHighPriority)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Text(
                                        'HIGH',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      (notification['message'] ??
                                              'Notification')
                                          .toString(),
                                      style: AppTypography.bodyStyle(
                                        fontWeight: isRead
                                            ? FontWeight.normal
                                            : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                PhilippineTime.format(
                                  notification['created_at']?.toString(),
                                  separator: ' • ',
                                ),
                              ),
                              onTap: isRead
                                  ? null
                                  : () => _markAsRead(notification),
                            ),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
