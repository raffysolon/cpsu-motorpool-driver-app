import 'package:flutter/material.dart';

// DRIVER DASHBOARD
// Route: /driver-dashboard

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  static const _green = Color(0xFF0B8F5A);
  static const _greenDark = Color(0xFF087448);
  static const _greenSoft = Color(0xFFE8F7F0);
  static const _ink = Color(0xFF19332A);
  static const _muted = Color(0xFF71827B);
  static const _line = Color(0xFFDCE9E2);
  static const _background = Color(0xFFF7FAF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 720;
        final padding = narrow ? 20.0 : 42.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 24, padding, 42),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(narrow: narrow),
                  SizedBox(height: narrow ? 28 : 36),
                  _buildWelcome(),
                  const SizedBox(height: 28),
                  _buildMainGrid(narrow: narrow),
                  const SizedBox(height: 24),
                  _buildQuickActions(narrow: narrow),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar({required bool narrow}) {
    return Row(
      children: [
        Container(
          width: narrow ? 34 : 42,
          height: narrow ? 34 : 42,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: narrow ? 19 : 23,
          ),
        ),
        const SizedBox(width: 11),
        const Text(
          'CPSU MOTORPOOL',
          style: TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _showUnavailableMessage('Notifications'),
          icon: const Badge(
            label: Text('3'),
            backgroundColor: _green,
            child: Icon(Icons.notifications_none_rounded, color: _ink),
          ),
        ),
        const SizedBox(width: 10),
        _buildAccountBox(narrow: narrow),
      ],
    );
  }

  Widget _buildAccountBox({required bool narrow}) {
    return Container(
      padding: EdgeInsets.fromLTRB(narrow ? 6 : 10, 6, 4, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D19332A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundColor: _greenSoft,
            child: Icon(Icons.person, color: _green, size: 19),
          ),
          if (!narrow) ...[
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver Account',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'CPSU Driver',
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ],
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => _showUnavailableMessage('Settings'),
            icon: const Icon(Icons.settings_outlined, color: _muted, size: 19),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: _greenDark, size: 19),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome, Driver!',
          style: TextStyle(
            color: _ink,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'What would you like to do today?',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMainGrid({required bool narrow}) {
    if (narrow) {
      return Column(
        children: [
          _buildCreateTripCard(),
          const SizedBox(height: 18),
          _buildActiveTripCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildCreateTripCard()),
        const SizedBox(width: 22),
        Expanded(flex: 7, child: _buildActiveTripCard()),
      ],
    );
  }

  Widget _buildCreateTripCard() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/driver-create-trip'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 248,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220B8F5A),
              blurRadius: 15,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: _green, size: 43),
            ),
            const SizedBox(height: 18),
            const Text(
              'Create Trip Ticket',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Start a new trip request',
              style: TextStyle(color: Color(0xFFD7F4E5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripCard() {
    return Container(
      height: 248,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Active Trip',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _greenSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: _greenDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'San Carlos to Kabankalan',
            style: TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 19),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTripDetail('VEHICLE', '1300'),
              _buildTripDetail('DEPARTURE', '08:30 AM'),
              _buildTripDetail('STATUS', 'In Progress'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _greenDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({required bool narrow}) {
    final cards = [
      _buildActionCard(
        Icons.receipt_long_outlined,
        'My Trips',
        'Pending & completed',
      ),
      _buildActionCard(
        Icons.history_rounded,
        'History',
        'Past trips',
      ),
      _buildActionCard(
        Icons.schedule_outlined,
        'Scheduled Trips',
        'Upcoming trips',
      ),
    ];

    if (narrow) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 12),
          cards[1],
          const SizedBox(height: 12),
          cards[2],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle) {
    return InkWell(
      onTap: () => _showUnavailableMessage(title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _greenSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _green, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnavailableMessage(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$section is ready for the next feature update.')),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your driver account?',
            style: TextStyle(color: _muted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: _muted),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
