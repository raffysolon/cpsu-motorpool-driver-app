import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class NotificationSoundPreferences {
  const NotificationSoundPreferences({
    this.enabled = true,
    this.volume = 0.6,
    this.highPriorityOnly = false,
  });

  final bool enabled;
  final double volume;
  final bool highPriorityOnly;

  NotificationSoundPreferences copyWith({
    bool? enabled,
    double? volume,
    bool? highPriorityOnly,
  }) => NotificationSoundPreferences(
    enabled: enabled ?? this.enabled,
    volume: (volume ?? this.volume).clamp(0, 1).toDouble(),
    highPriorityOnly: highPriorityOnly ?? this.highPriorityOnly,
  );
}

class NotificationSoundService {
  static const _androidSounds = MethodChannel(
    'cpsumotorpooldriverapp/notification_sounds',
  );
  static final instance = NotificationSoundService();
  static const _prefix = 'notification_sounds_v1';
  static const _minimumAlertInterval = Duration(seconds: 3);

  final Set<String> _seen = {};
  DateTime? _lastPlaybackAt;
  String? _account;
  bool _hasInitialSnapshot = false;
  bool _playing = false;
  NotificationSoundPreferences _preferences =
      const NotificationSoundPreferences();

  NotificationSoundPreferences get preferences => _preferences;

  Future<NotificationSoundPreferences> initializeAccount(String account) async {
    final normalized = account.trim().toLowerCase();
    if (_account == normalized) return _preferences;
    _account = normalized;
    _seen.clear();
    _hasInitialSnapshot = false;
    final prefs = await SharedPreferences.getInstance();
    final key = _key(normalized);
    _preferences = NotificationSoundPreferences(
      enabled: prefs.getBool('$key.enabled') ?? true,
      volume: (prefs.getDouble('$key.volume') ?? 0.6).clamp(0, 1).toDouble(),
      highPriorityOnly: prefs.getBool('$key.high_priority_only') ?? false,
    );
    return _preferences;
  }

  Future<void> savePreferences(
    String account,
    NotificationSoundPreferences value,
  ) async {
    await initializeAccount(account);
    _preferences = value;
    final prefs = await SharedPreferences.getInstance();
    final key = _key(account.trim().toLowerCase());
    await prefs.setBool('$key.enabled', value.enabled);
    await prefs.setDouble('$key.volume', value.volume);
    await prefs.setBool('$key.high_priority_only', value.highPriorityOnly);
  }

  Future<void> observeNotifications({
    required String accountScope,
    required List<Map<String, dynamic>> notifications,
  }) async {
    await initializeAccount(accountScope);
    final fresh = notifications.where((item) {
      final key = item['event_key']?.toString().trim().isNotEmpty == true
          ? 'event:${item['event_key']}'
          : 'id:${item['id']}';
      final isNew = _seen.add(key);
      return isNew && _hasInitialSnapshot && _isRecent(item);
    }).toList();
    _hasInitialSnapshot = true;
    if (!_preferences.enabled ||
        _playing ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final candidates = fresh
        .where(
          (item) =>
              soundForNotification(item) != null &&
              (!_preferences.highPriorityOnly ||
                  notificationIsHighPriority(item)),
        )
        .toList();
    if (candidates.isEmpty) return;
    candidates.sort((a, b) => _priority(b).compareTo(_priority(a)));
    final last = _lastPlaybackAt;
    if (last != null && DateTime.now().difference(last) < _minimumAlertInterval)
      return;
    await _play(soundForNotification(candidates.first)!, _preferences.volume);
  }

  Future<bool> playTestSound(double volume) async {
    try {
      await _play(NotificationSound.scheduledDepartureReminder, volume);
      return true;
    } catch (error) {
      debugPrint('Notification sound playback failed: $error');
      return false;
    }
  }

  Future<void> _play(NotificationSound sound, double volume) async {
    if (_playing) return;
    _playing = true;
    _lastPlaybackAt = DateTime.now();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _androidSounds.invokeMethod<void>('play', {
          'volume': volume.clamp(0, 1).toDouble(),
          'sound': sound.name,
        });
      } else {
        await SystemSound.play(SystemSoundType.alert);
      }
    } finally {
      _playing = false;
    }
  }

  bool _isRecent(Map<String, dynamic> item) {
    final created = DateTime.tryParse(item['created_at']?.toString() ?? '');
    return created == null ||
        DateTime.now().difference(created.toLocal()) <=
            const Duration(minutes: 2);
  }

  int _priority(Map<String, dynamic> item) =>
      item['priority']?.toString().toLowerCase() == 'high' ? 2 : 1;

  String _key(String account) =>
      '$_prefix.${base64Url.encode(utf8.encode(account)).replaceAll('=', '')}';

  static bool notificationIsHighPriority(Map<String, dynamic> item) =>
      item['priority']?.toString().toLowerCase() == 'high';

  static NotificationSound? soundForNotification(Map<String, dynamic> item) {
    final key = item['event_key']?.toString() ?? '';
    if (key.startsWith('movement:unauthorized:'))
      return NotificationSound.unauthorizedMovement;
    if (key.startsWith('movement:pretrip:'))
      return NotificationSound.approvedMovementBeforeStart;
    if (key.startsWith('tracker-departure-unreachable:'))
      return NotificationSound.scheduledDepartureReminder;
    if (key.startsWith('departure-overdue:'))
      return NotificationSound.overdueDepartureWarning;
    return NotificationSound.scheduledDepartureReminder;
  }
}

enum NotificationSound {
  unauthorizedMovement,
  approvedMovementBeforeStart,
  scheduledDepartureReminder,
  overdueDepartureWarning,
}
