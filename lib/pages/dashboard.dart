import 'package:flutter/material.dart';

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
  /// Number of unread notifications
  /// TODO: Connect to real notification system
  int unreadNotifications = 3;
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
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                onPressed: _goToNotifications,
              ),
              // Unread badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // ===== NOTIFICATION ICON - END =====
        ],
      ),
      // ===== APPBAR - END =====

      // ===== DRAWER MENU - START =====
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: darkGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.person, color: green, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Driver Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'driver@cpsu.edu.ph',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: green),
              title: const Text('My Profile'),
              onTap: _goToProfile,
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: green),
              title: const Text('Settings'),
              onTap: _goToSettings,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
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
              const Text(
                'Welcome, Driver!',
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
                height: 240,
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
                            child: const Text(
                              'ACTIVE',
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

                      // Trip Details
                      const Text(
                        'San Carlos to Kabangkalan',
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
                              children: const [
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
                                  '1300',
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
                              children: const [
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
                                  '08:30 AM',
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
                              children: const [
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
                                  'In Progress',
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
                          child: const Text('End Trip'),
                        ),
                      ),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: softGreen,
                ),
                child: Icon(icon, size: 24, color: green),
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
    Navigator.pushNamed(context, '/my-trips');
  }

  /// Navigate to Trip History page
  void _goToHistory() {
    Navigator.pushNamed(context, '/history');
  }

  /// Navigate to Scheduled Trips page
  void _goToScheduledTrips() {
    Navigator.pushNamed(context, '/scheduled-trips');
  }

  Future<void> _showEndTripSheet() async {
    final arrivalTimeController = TextEditingController(
      text: _formatTimeOfDay(TimeOfDay.now()),
    );

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasArrivalTime =
                arrivalTimeController.text.trim().isNotEmpty;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm Trip Arrival',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: arrivalTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Arrival Time',
                      prefixIcon: Icon(Icons.access_time, color: green),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        arrivalTimeController.text =
                            _formatTimeOfDay(selectedTime);
                        setSheetState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: green,
                            side: const BorderSide(color: green),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: hasArrivalTime
                              ? () => Navigator.pop(
                                  sheetContext,
                                  arrivalTimeController.text,
                                )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Confirm End Trip'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    arrivalTimeController.dispose();

    if (result != null && mounted) {
      _endTrip('trip-001', result);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _endTrip(String tripId, String arrivalTime) {
    // TODO: POST to the backend, mark the trip COMPLETED, and save arrivalTime.
  }

  /// Navigate to Notifications page
  void _goToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  /// Navigate to User Profile page (TODO: Create page)
  void _goToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  /// Navigate to App Settings page (TODO: Create page)
  void _goToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  /// Handle logout with confirmation dialog
  /// Returns user to login page
  void _logout() {
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
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
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
