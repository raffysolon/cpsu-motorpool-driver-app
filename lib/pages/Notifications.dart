import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../services/notification_service.dart';

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
                        return GlassCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 14,
                          child: ListTile(
                            leading: Icon(
                              isRead
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: isRead ? AppColors.muted : AppColors.primary,
                            ),
                            title: Text(
                              (notification['message'] ?? 'Notification').toString(),
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              (notification['created_at'] ?? '').toString(),
                            ),
                            onTap: isRead ? null : () => _markAsRead(notification),
                          ),
                        );
                      },
                    ),
            ),
          ),
    );
  }
}
