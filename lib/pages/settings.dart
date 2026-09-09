import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../services/auth_service.dart';

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
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  Map<String, dynamic> profile = const {};
  bool isLoading = true;
  bool isSaving = false;
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
    final next = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      showMessage('Complete all password fields.');
      return;
    }
    if (next.length < 8) {
      showMessage('New password must be at least 8 characters.');
      return;
    }
    if (next != confirm) {
      showMessage('New passwords do not match.');
      return;
    }

    setState(() => isSaving = true);
    try {
      await AuthService.changePassword(current, next);
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      showMessage('Password changed successfully.');
    } catch (_) {
      showMessage('Unable to change password. Check your current password.');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
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
            section('Change Password', [
              passwordField(
                'Current password',
                currentPasswordController,
                obscureCurrent,
                () => setState(() => obscureCurrent = !obscureCurrent),
              ),
              passwordField(
                'New password',
                newPasswordController,
                obscureNew,
                () => setState(() => obscureNew = !obscureNew),
              ),
              passwordField(
                'Confirm new password',
                confirmPasswordController,
                obscureConfirm,
                () => setState(() => obscureConfirm = !obscureConfirm),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : changePassword,
                  child: Text(isSaving ? 'Saving...' : 'Change Password'),
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
