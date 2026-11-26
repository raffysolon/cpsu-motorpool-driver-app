import '../widgets/app_notification.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../services/auth_service.dart';
import '../widgets/notification_sound_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const green = AppColors.primary;
  static const ink = AppColors.navy;
  static const muted = AppColors.mutedDark;
  static const line = AppColors.border;
  static const background = AppColors.background;

  final currentPasswordController = TextEditingController();
  Map<String, dynamic> profile = const {};
  bool isLoading = true;
  bool isSaving = false;
  bool obscureCurrent = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      final result = await AuthService.getProfile();
      if (!mounted) return;
      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> changePassword() async {
    final current = currentPasswordController.text;
    if (isSaving) return;
    if (current.isEmpty) {
      showMessage('Enter your current password.');
      return;
    }

    setState(() => isSaving = true);
    try {
      await AuthService.changePassword(current);
      if (!mounted) return;
      currentPasswordController.clear();
      AppNotification.showMessage(
        'Password reset email sent. Check your inbox or spam folder to continue.',
        isSuccess: true,
      );
    } on AuthException catch (error) {
      if (mounted) AppNotification.showMessage(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        AppNotification.showMessage(
          'Unable to send the password reset email. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void showMessage(String message) {
    AppNotification.show(context, SnackBar(content: Text(message)));
  }

  String value(String key, String fallback) {
    final result = profile[key]?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: AppColors.glassFill,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.displayTitle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ShellAtmosphere(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              section('Driver Profile', [
                readOnlyField(
                  'Name',
                  value('name', isLoading ? 'Loading...' : 'Unavailable'),
                  Icons.person_outline,
                ),
                readOnlyField(
                  'Email',
                  value('email', isLoading ? 'Loading...' : 'Unavailable'),
                  Icons.email_outlined,
                ),
                readOnlyField(
                  'Contact Number',
                  value('contact_number', 'Unavailable'),
                  Icons.phone_outlined,
                ),
                readOnlyField(
                  'License Number',
                  value('license_number', 'Unavailable'),
                  Icons.badge_outlined,
                ),
              ]),
              const SizedBox(height: 18),
              section('Notification Sounds', const [
                NotificationSoundSettings(),
              ]),
              const SizedBox(height: 18),
              section('Change Password', [
                const Text(
                  'Confirm your current password to receive a link at your registered email. Choose your new password using that link.',
                ),
                passwordField(
                  'Current password',
                  currentPasswordController,
                  obscureCurrent,
                  () => setState(() => obscureCurrent = !obscureCurrent),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : changePassword,
                    child: Text(
                      isSaving ? 'Sending...' : 'Send password reset email',
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget section(String title, List<Widget> children) {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget readOnlyField(String label, String text, IconData icon) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: muted),
        filled: true,
        fillColor: const Color(0xFFEFF2F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: line),
        ),
      ),
      child: Text(text, style: const TextStyle(color: ink)),
    );
  }

  Widget passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: green),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: muted,
          ),
        ),
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: line),
        ),
      ),
    );
  }
}
