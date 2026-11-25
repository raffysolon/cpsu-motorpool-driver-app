import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/time_format.dart';

class NotificationDialog extends StatelessWidget {
  const NotificationDialog({
    super.key,
    required this.notifications,
    required this.onAcknowledge,
  });
  final List<Map<String, dynamic>> notifications;
  final Future<void> Function(int id) onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: math.min(24, size.width * .06),
        vertical: size.height * .08,
      ),
      child: SizedBox(
        width: math.min(620, size.width * .9),
        height: size.height * .78,
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text('No notifications yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (_, index) {
                        final item = notifications[index];
                        final high =
                            item['priority']?.toString().toLowerCase() ==
                            'high';
                        final id = int.tryParse('${item['id']}');
                        return ListTile(
                          isThreeLine: true,
                          leading: Icon(
                            high
                                ? Icons.warning_amber_rounded
                                : Icons.notifications_outlined,
                            color: high
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                          title: high
                              ? const Text(
                                  'HIGH PRIORITY',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          subtitle: Text(
                            '${item['message'] ?? 'Notification'}\n${PhilippineTime.format(item['created_at']?.toString(), separator: ' • ')}',
                          ),
                          onTap: id == null
                              ? null
                              : () async {
                                  await onAcknowledge(id);
                                },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
