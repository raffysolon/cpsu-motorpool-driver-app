import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notification_sound_service.dart';

class NotificationSoundSettings extends StatefulWidget {
  const NotificationSoundSettings({super.key});

  @override
  State<NotificationSoundSettings> createState() =>
      _NotificationSoundSettingsState();
}

class _NotificationSoundSettingsState extends State<NotificationSoundSettings> {
  final _service = NotificationSoundService.instance;
  NotificationSoundPreferences _preferences =
      const NotificationSoundPreferences();
  String? _scope;
  bool _loading = true;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final scope = await AuthService.getNotificationAccountScope();
      if (scope == null || scope.isEmpty) throw StateError('Sign in first.');
      final value = await _service.initializeAccount(scope);
      if (mounted)
        setState(() {
          _scope = scope;
          _preferences = value;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(NotificationSoundPreferences value) async {
    final scope = _scope;
    if (scope == null) return;
    setState(() => _preferences = value);
    await _service.savePreferences(scope, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable notification sounds'),
          subtitle: const Text(
            'Play tones for new movement and departure alerts.',
          ),
          value: _preferences.enabled,
          onChanged: (value) => _save(_preferences.copyWith(enabled: value)),
        ),
        Text('Volume: ${(_preferences.volume * 100).round()}%'),
        Slider(
          value: _preferences.volume,
          divisions: 10,
          label: '${(_preferences.volume * 100).round()}%',
          onChanged: (value) => setState(
            () => _preferences = _preferences.copyWith(volume: value),
          ),
          onChangeEnd: (value) => _save(_preferences.copyWith(volume: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('High-priority alerts only'),
          subtitle: const Text(
            'Ignore ordinary scheduled and pre-departure alerts.',
          ),
          value: _preferences.highPriorityOnly,
          onChanged: (value) =>
              _save(_preferences.copyWith(highPriorityOnly: value)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _testing
                ? null
                : () async {
                    setState(() => _testing = true);
                    await _service.playTestSound(_preferences.volume);
                    if (mounted) setState(() => _testing = false);
                  },
            icon: const Icon(Icons.volume_up_outlined),
            label: Text(_testing ? 'Testing...' : 'Test sound'),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Sounds play only while the app is open and active.'),
      ],
    );
  }
}
