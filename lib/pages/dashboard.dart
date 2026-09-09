import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/trip_service.dart';

// ===== DRIVER DASHBOARD PAGE - START =====
/// Main dashboard page shown after login
/// Displays trip options, active trips, and quick action buttons
class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

// ===== DRIVER DASHBOARD STATE - START =====
/// State class for DriverDashboard
/// Manages dashboard UI and navigation
class _DriverDashboardState extends State<DriverDashboard> {
  // ===== COLOR THEME - START =====
  /// Main green color for app branding
  static const Color green = Color(0xFF0F8C59);

  /// Dark green color for emphasis and buttons
  static const Color darkGreen = Color(0xFF0A6E45);

  /// Soft green for backgrounds and accents
  static const Color softGreen = Color(0xFFBFE8D1);

  /// Main text color
  static const Color textColor = Color(0xFF1F2A2A);

  /// Border color for elements
  static const Color borderColor = Color(0xFFE0E0E0);

  /// Light background color
  static const Color lightBg = Color(0xFFF5F6F5);
  // ===== COLOR THEME - END =====

  // ===== DASHBOARD STATE - START =====
  int unreadNotifications = 0;
  int _myTripsCount = 0;
  int _scheduledTripsCount = 0;
  int _historyCount = 0;
  String _driverName = 'Driver';
  String _driverEmail = '';
  String _activeAction = 'Start Trip';
  Map<String, dynamic>? _activeTrip;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
    _loadTripCounts();
    _loadDriverAccount();
    _loadActiveAction();
  }

  Future<void> _loadActiveAction() async {
    try {
      final trips = await TripService.getMyTrips();
      Map<String, dynamic>? selectedTrip;
      String selectedStatus = 'none';

      for (final trip in trips) {
        final status = (trip['effective_status'] ?? trip['status'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        if (status == 'active') {
          selectedTrip = Map<String, dynamic>.from(trip);
          selectedStatus = 'active';
          break;
        }

        if (status == 'scheduled' && selectedStatus == 'none') {
          selectedTrip = Map<String, dynamic>.from(trip);
          selectedStatus = 'scheduled';
        }
      }

      if (selectedTrip == null) {
        if (mounted) {
          setState(() {
            _activeTrip = null;
            _activeAction = 'Start Trip';
          });
        }
        return;
      }

      final movements =
          (selectedTrip['movements'] is List
                  ? selectedTrip['movements'] as List
                  : const [])
              .whereType<Map>()
              .toList();
      final outboundMatches = movements
          .where((item) => '${item['movement_no']}' == '1')
          .toList();
      final returnMatches = movements
          .where((item) => '${item['movement_no']}' == '2')
          .toList();
      final outbound = outboundMatches.isEmpty ? null : outboundMatches.first;
      final returnMovement = returnMatches.isEmpty ? null : returnMatches.first;
      final action = selectedStatus == 'active'
          ? ('${returnMovement?['status'] ?? ''}' == 'active'
                ? 'End Return Trip'
                : '${outbound?['status'] ?? ''}' == 'active'
                ? 'End Trip'
                : '${outbound?['status'] ?? ''}' == 'completed'
                ? 'Start Return Trip'
                : 'Start Trip')
          : '${returnMovement?['status'] ?? ''}' == 'active'
          ? 'End Return Trip'
          : '${outbound?['status'] ?? ''}' == 'scheduled'
          ? 'Start Trip'
          : '${outbound?['status'] ?? ''}' == 'active'
          ? 'End Trip'
          : '${outbound?['status'] ?? ''}' == 'completed'
          ? 'Start Return Trip'
          : 'Start Trip';

      if (!mounted) return;
      setState(() {
        _activeTrip = selectedTrip;
        _activeAction = action;
      });
    } catch (_) {}
  }

  Future<void> _loadDriverAccount() async {
    var name = await AuthService.getName();
    var email = await AuthService.getEmail();

    if (email == null || email.trim().isEmpty) {
      try {
        final profile = await AuthService.getProfile();
        name = name ?? profile['name']?.toString();
        email = profile['email']?.toString();
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _driverName = name?.trim().isNotEmpty == true ? name!.trim() : 'Driver';
      _driverEmail = email?.trim() ?? '';
    });
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) setState(() => unreadNotifications = count);
    } catch (_) {
      if (mounted) setState(() => unreadNotifications = 0);
    }
  }

  Future<void> _loadTripCounts() async {
    try {
      final trips = await TripService.getMyTrips();
      var myTripsCount = 0;
      var scheduledTripsCount = 0;
      var historyCount = 0;

      for (final trip in trips) {
        final status = (trip['effective_status'] ?? trip['status'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        if (status != 'completed') {
          myTripsCount++;
        }
        if (status == 'scheduled') {
          scheduledTripsCount++;
        }
        if (status == 'completed') {
          historyCount++;
        }
      }

      if (!mounted) return;
      setState(() {
        _myTripsCount = myTripsCount;
        _scheduledTripsCount = scheduledTripsCount;
        _historyCount = historyCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _myTripsCount = 0;
        _scheduledTripsCount = 0;
        _historyCount = 0;
      });
    }
  }
  // ===== DASHBOARD STATE - END ====="

  // ===== BUILD METHOD - START =====
  /// Builds the main dashboard UI with AppBar, drawer, and body
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      // ===== APPBAR - START =====
      appBar: AppBar(
        elevation: 0,
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text(
          'CPSU MOTORPOOL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          // ===== NOTIFICATION ICON - START =====
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                onPressed: _goToNotifications,
              ),
              if (unreadNotifications > 0)
                _buildUnreadBadge(unreadNotifications, right: 3),
            ],
          ),
          // ===== NOTIFICATION ICON - END =====
        ],
      ),
      // ===== APPBAR - END =====

      // ===== DRAWER MENU - START =====
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.white,
                elevation: 18,
                shadowColor: Colors.black.withValues(alpha: 0.22),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  side: BorderSide(color: Color(0xFFE0E8E3)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 248,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
                        decoration: const BoxDecoration(color: darkGreen),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: green,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _driverName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                _driverEmail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _goToSettings,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: softGreen,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.settings_outlined,
                                      color: green,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Text(
                                      'Settings',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF9AA8A1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Divider(height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        child: Material(
                          color: const Color(0xFFFFF3F2),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _logout,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFDAD6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      color: Color(0xFFC62828),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Color(0xFFC62828),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFE57373),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ===== DRAWER MENU - END =====

      // ===== MAIN BODY - START =====
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome Section
              const SizedBox(height: 20),
              // ===== WELCOME MESSAGE SECTION - START =====
              /// Welcome greeting for the driver
              Text(
                'Welcome, $_driverFirstName!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What would you like to do today?',
                style: TextStyle(fontSize: 16, color: Color(0xFF7C7C7C)),
              ),
              const SizedBox(height: 40),
              // ===== WELCOME MESSAGE SECTION - END =====

              // ===== CREATE TRIP TICKET BUTTON - START =====
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [green, darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: green.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _goToAddTrip,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.add, size: 48, color: green),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Trip Ticket',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Start a new trip request',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== CREATE TRIP TICKET BUTTON - END =====
              const SizedBox(height: 30),

              // ===== ACTIVE TRIPS SECTION - START =====
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 240),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: softGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Active Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _activeTrip != null ? 'IN PROGRESS' : 'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: softGreen,
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              color: green,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_activeTrip == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 24, bottom: 24),
                          child: Center(
                            child: Text(
                              'No active trips right now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7C7C7C),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        // Trip Details
                        Text(
                          _activeRoute(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Vehicle and Time Info
                        Row(
                          children: [
                          // Vehicle Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vehicle',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7C7C7C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _activeVehicle(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Container(width: 1, height: 30, color: borderColor),
                          // Time Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Departure',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7C7C7C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _activeDeparture(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7C7C7C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _displayTripStatus(
                                    _activeTrip?['status'] ??
                                        _activeTrip?['effective_status'],
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: green,
                                  ),
                                ),

                              ],
                            ),
                          ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _showEndTripSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(_activeAction),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // ===== ACTIVE TRIPS SECTION - END =====
              const SizedBox(height: 30),

              // ===== QUICK ACTION BUTTONS ROW - START =====
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 112,
                      child: _tripActionButton(
                        icon: Icons.assignment_outlined,
                        title: 'My Trips',
                        subtitle: 'Pending & Completed',
                        onPressed: _goToMyTrips,
                        badgeCount: _myTripsCount,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 112,
                      child: _tripActionButton(
                        icon: Icons.history_outlined,
                        title: 'History',
                        subtitle: 'Past Trips',
                        onPressed: _goToHistory,
                        badgeCount: _historyCount,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 112,
                      child: _tripActionButton(
                        icon: Icons.schedule_outlined,
                        title: 'Scheduled Trips',
                        subtitle: 'Upcoming Trips',
                        onPressed: _goToScheduledTrips,
                        badgeCount: _scheduledTripsCount,
                      ),
                    ),
                  ),
                ],
              ),

              // ===== QUICK ACTION BUTTONS ROW - END =====
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // ===== MAIN BODY - END =====
    );
  }

  // ===== TRIP ACTION BUTTON WIDGET - START =====
  /// Builds a reusable action button for trip-related features
  /// Used for My Trips, History, and Scheduled Trips buttons
  Widget _tripActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: softGreen, width: 2),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: softGreen,
                    ),
                    child: Icon(icon, size: 24, color: green),
                  ),
                  if (badgeCount > 0) _buildUnreadBadge(badgeCount),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF7C7C7C),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ===== TRIP ACTION BUTTON WIDGET - END =====

  // ===== NAVIGATION FUNCTIONS - START =====
  /// Navigate to Create Trip page
  void _goToAddTrip() {
    Navigator.pushNamed(context, '/create-trip');
  }

  /// Navigate to My Trips page
  void _goToMyTrips() {
    Navigator.pushNamed(context, '/my-trips').then((_) {
      _loadNotificationCount();
      _loadTripCounts();
    });
  }

  /// Navigate to Trip History page
  void _goToHistory() {
    Navigator.pushNamed(context, '/history');
  }

  /// Navigate to Scheduled Trips page
  void _goToScheduledTrips() {
    Navigator.pushNamed(context, '/scheduled-trips').then((_) {
      _loadNotificationCount();
      _loadTripCounts();
      _loadActiveAction();
    });
  }

  Widget _buildUnreadBadge(int count, {double right = -9}) {
    return Positioned(
      top: -7,
      right: right,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          count > 9 ? '9+' : '$count',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _activeRoute() {
    final trip = _activeTrip;
    if (trip == null) return 'No active trip';
    return '${trip['origin'] ?? ''} to ${trip['destination'] ?? ''}';
  }

  String _activeVehicle() {
    final vehicle = _activeTrip?['vehicle'];
    if (vehicle is Map) {
      return '${vehicle['name'] ?? vehicle['plate_no'] ?? '—'}';
    }
    return '—';
  }

  String _activeDeparture() {
    final value = DateTime.tryParse(
      '${_activeTrip?['scheduled_departure'] ?? ''}',
    )?.toLocal();
    if (value == null) return '—';
    final hour = value.hour == 0
        ? 12
        : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _displayTripStatus(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'approved':
        return 'PENDING';
      case 'scheduled':
        return 'PENDING';
      case 'active':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'denied':
        return 'DENIED';
      default:
        return 'PENDING';
    }
  }

  String get _driverFirstName {
    final name = _driverName.trim();
    if (name.isEmpty) return 'Driver';
    return name.split(RegExp(r'\s+')).first;
  }

  Future<void> _showEndTripSheet() async {
    await _loadActiveAction();
    if (!mounted) return;
    final action = _activeAction;
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action == 'Start Trip'
                    ? 'The system will record the departure time automatically.'
                    : action == 'Start Return Trip'
                    ? 'The system will record the return departure time automatically.'
                    : 'The system will record the current arrival time automatically.',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(action),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == true && mounted) {
      try {
        final tripId = int.tryParse('${_activeTrip?['id']}');
        if (tripId == null) throw Exception('No active trip found');
        if (action == 'Start Trip') {
          await TripService.startTrip(tripId);
        } else if (action == 'Start Return Trip') {
          await TripService.startReturnTrip(tripId);
        } else if (action == 'End Return Trip') {
          await TripService.endReturnTrip(tripId);
        } else {
          await TripService.endTrip(tripId);
        }
        await _loadActiveAction();
        if (!mounted) return;
        final message = action == 'Start Trip' || action == 'Start Return Trip'
            ? 'Trip started successfully.'
            : 'Trip ended. Arrival time was recorded automatically.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to process trip: $error')));
      }
    }
  }

  /// Navigate to Notifications page
  void _goToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  /// Navigate to App Settings page (TODO: Create page)
  void _goToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  /// Handle logout with confirmation dialog
  /// Returns user to login page
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ===== NAVIGATION FUNCTIONS - END =====
}

// ===== DRIVER DASHBOARD STATE - END =====
