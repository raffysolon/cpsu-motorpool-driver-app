import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// LOGIN PAGE (Web)
// Route: /login
// ═══════════════════════════════════════════════════════════════

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  static const _brandGreen = Color(0xFF1F8A3D);
  static const _brandGreenDark = Color(0xFF176E30);
  static const _textDark = Color(0xFF1F2933);
  static const _textMuted = Color(0xFF6B7280);
  static const _fieldBorder = Color(0xFFE2E8F0);
  static const _fieldFill = Color(0xFFFAFBFC);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wideLayout = constraints.maxWidth >= 800;

          if (wideLayout) {
            return Row(
              children: [
                Expanded(child: _buildBrandPanel()),
                Expanded(child: _buildFormSection()),
              ],
            );
          }

          return Column(
            children: [
              _buildMobileBrandHeader(),
              Expanded(child: _buildFormSection()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      color: _brandGreen,
      padding: const EdgeInsets.all(48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(showWhiteBorder: true),
              const SizedBox(height: 28),
              const Text(
                'CPSU MOTORPOOL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Reliable fleet management for every journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFDDF5E4),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBrandHeader() {
    return Container(
      width: double.infinity,
      color: _brandGreen,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Row(
        children: [
          _buildLogo(size: 72, showWhiteBorder: true),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'CPSU\nMOTORPOOL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 8),
              const Text(
                'Sign in to manage your fleet.',
                style: TextStyle(color: _textMuted, fontSize: 14),
              ),
              const SizedBox(height: 28),
              _buildLoginCard(),
              const SizedBox(height: 24),
              _buildQuickAccessButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({double size = 150, bool showWhiteBorder = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showWhiteBorder
            ? Border.all(color: Colors.white, width: size > 100 ? 4 : 2)
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/cpsu logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.account_balance,
            size: 56,
            color: _brandGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'CPSU MOTORPOOL',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: _textDark,
        height: 1.2,
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Email:'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailCtrl,
            focused: _emailFocused,
            onFocusChange: (v) => setState(() => _emailFocused = v),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Password:'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordCtrl,
            focused: _passwordFocused,
            onFocusChange: (v) => setState(() => _passwordFocused = v),
            obscure: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _passwordFocused ? _brandGreen : _textMuted,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildRememberAndForgot(),
          const SizedBox(height: 24),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: _textDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool focused,
    required ValueChanged<bool> onFocusChange,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: focused
            ? const [
                BoxShadow(
                  color: Color(0x261F8A3D),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          cursorColor: _brandGreen,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _textDark,
            height: 1.3,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: focused ? Colors.white : _fieldFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _fieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brandGreen, width: 1.6),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    final rememberMe = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _rememberMe,
            activeColor: _brandGreen,
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(color: Color(0xFFC5CDD6), width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Remember me',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: _textDark,
          ),
        ),
      ],
    );
    final forgotPassword = TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: _brandGreen,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Forgot password?',
        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              rememberMe,
              Align(alignment: Alignment.centerRight, child: forgotPassword),
            ],
          );
        }

        return Row(
          children: [
            rememberMe,
            const Spacer(),
            forgotPassword,
          ],
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.pressed)) {
              return _brandGreenDark;
            }
            return _brandGreen;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.hovered) ? 4 : 0;
          }),
          shadowColor: const WidgetStatePropertyAll(Color(0x331F8A3D)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        child: const Text(
          'LOG IN',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // TEMPORARY QUICK ACCESS BUTTONS
  Widget _buildQuickAccessButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FCF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5EBDD)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'QUICK ACCESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _brandGreenDark,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  label: 'Admin',
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  color: _brandGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessButton(
                  label: 'Driver',
                  onPressed: () => Navigator.pushReplacementNamed(context, '/driver-dashboard'),
                  color: _brandGreenDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(color),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
