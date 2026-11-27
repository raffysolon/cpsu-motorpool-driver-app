import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/notification_sound_service.dart';
import '../widgets/notification_item.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});
  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _isLoading = true;
  bool _fetching = false;
  Timer? _timer;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed)
        _loadNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final notifications = await NotificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
        _error = null;
      });
      try {
        final scope = await AuthService.getNotificationAccountScope();
        if (scope != null && scope.isNotEmpty) {
          await NotificationSoundService.instance.observeNotifications(
            accountScope: scope,
            notifications: notifications,
          );
        }
      } catch (_) {
        /* Sound preferences must not hide a loaded inbox. */
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Unable to load notifications. Pull down to retry.';
        });
      }
    } finally {
      _fetching = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: [
                  Text(
                    '${_notifications.where((n) => n['is_read'] != true).length} unread',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  if (_notifications.isEmpty && _error == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 180),
                      child: Center(child: Text('No notifications.')),
                    ),
                  for (final item in _notifications)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 14,
                        child: NotificationItem(
                          key: ValueKey(item['id']),
                          notification: item,
                          onAcknowledge: (id) async {
                            await NotificationService.markAsRead(id);
                            if (mounted) setState(() => item['is_read'] = true);
                          },
                          onDelete: (id) async {
                            await NotificationService.deleteNotification(id);
                            if (mounted) {
                              setState(
                                () => _notifications.removeWhere(
                                  (n) => '${n['id']}' == '$id',
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    ),
  );
}
