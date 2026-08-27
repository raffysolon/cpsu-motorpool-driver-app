import 'package:flutter/material.dart';

class Trip {
  const Trip({
    required this.id,
    required this.route,
    required this.status,
    required this.vehicle,
    required this.departureTime,
    required this.expectedArrival,
  });

  final String id;
  final String route;
  final String status;
  final String vehicle;
  final DateTime departureTime;
  final DateTime expectedArrival;
}

class ScheduledTripsPage extends StatefulWidget {
  const ScheduledTripsPage({super.key});

  @override
  State<ScheduledTripsPage> createState() => _ScheduledTripsPageState();
}

class _ScheduledTripsPageState extends State<ScheduledTripsPage> {
  static const Color green = Color(0xFF0F8C59);
  static const Color softGreen = Color(0xFFBFE8D1);
  static const Color textColor = Color(0xFF1F2A2A);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightBg = Color(0xFFF5F6F5);

  static final List<Trip> _trips = [
    Trip(
      id: 'TRIP-201',
      route: 'Kabankalan to San Carlos',
      status: 'Approved',
      vehicle: '1300',
      departureTime: DateTime.now().add(const Duration(hours: 6)),
      expectedArrival: DateTime.now().add(const Duration(hours: 8, minutes: 30)),
    ),
    Trip(
      id: 'TRIP-202',
      route: 'Bacolod to San Carlos',
      status: 'Approved',
      vehicle: 'L300',
      departureTime: DateTime.now().add(const Duration(days: 4, hours: 2)),
      expectedArrival: DateTime.now().add(const Duration(days: 4, hours: 4, minutes: 15)),
    ),
  ];

  List<Trip> get _sortedTrips {
    final trips = List<Trip>.from(_trips)
      ..sort((first, second) => first.departureTime.compareTo(second.departureTime));
    return trips;
  }

  void _navigateToTripSummary(String tripId) {
    // TODO: Navigate to the trip summary page for tripId.
  }

  void _printTripTicket(String tripId) {
    // TODO: Trigger the print or download of the trip ticket PDF for tripId.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scheduled Trips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _sortedTrips.isEmpty ? _buildEmptyState() : _buildTripList(),
      ),
    );
  }

  Widget _buildTripList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: _sortedTrips.length,
      itemBuilder: (context, index) => _buildTripCard(_sortedTrips[index]),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildApprovedBadge(),
                if (_isDepartingSoon(trip)) _buildDepartingSoonLabel(),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              trip.route,
              style: const TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: borderColor),
            ),
            Row(
              children: [
                _buildTripDetail('Vehicle', trip.vehicle),
                _buildColumnDivider(),
                _buildTripDetail('Departure', _formatDateTime(trip.departureTime)),
                _buildColumnDivider(),
                _buildTripDetail('Arrival', _formatDateTime(trip.expectedArrival)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToTripSummary(trip.id),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      side: const BorderSide(color: green),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _printTripTicket(trip.id),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: green),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'APPROVED',
        style: TextStyle(
          color: green,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDepartingSoonLabel() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_outlined, color: green, size: 16),
        SizedBox(width: 4),
        Text(
          'Departing soon',
          style: TextStyle(
            color: green,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTripDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7C7C7C),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: borderColor,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: softGreen,
            ),
            child: const Icon(Icons.schedule_outlined, size: 44, color: green),
          ),
          const SizedBox(height: 16),
          const Text(
            'No upcoming trips scheduled',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isDepartingSoon(Trip trip) {
    final timeUntilDeparture = trip.departureTime.difference(DateTime.now());
    return timeUntilDeparture >= Duration.zero &&
        timeUntilDeparture <= const Duration(hours: 24);
  }

  String _formatDateTime(DateTime dateTime) {
    final month = _monthName(dateTime.month);
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month ${dateTime.day}, ${dateTime.year}\n$hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
