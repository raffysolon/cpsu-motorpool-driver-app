import 'package:flutter/material.dart';

class Trip {
  const Trip({
    required this.id,
    required this.route,
    required this.status,
    required this.vehicle,
    required this.departureOrDate,
  });

  final String id;
  final String route;
  final String status;
  final String vehicle;
  final String departureOrDate;
}

class MyTrip extends StatefulWidget {
  const MyTrip({super.key});

  @override
  State<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends State<MyTrip> {
  static const Color green = Color(0xFF0F8C59);
  static const Color darkGreen = Color(0xFF0A6E45);
  static const Color textColor = Color(0xFF1F2A2A);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightBg = Color(0xFFF5F6F5);

  static const List<String> _filters = [
    'All',
    'Pending',
    'Approved',
    'Active',
    'Completed',
  ];

  static const List<Trip> _trips = [
    Trip(
      id: 'TRIP-001',
      route: 'San Carlos to Kabangkalan',
      status: 'Active',
      vehicle: '1300',
      departureOrDate: 'Today, 8:00 AM',
    ),
    Trip(
      id: 'TRIP-002',
      route: 'Bacolod to San Carlos',
      status: 'Approved',
      vehicle: 'L300',
      departureOrDate: 'Aug 24, 2026',
    ),
    Trip(
      id: 'TRIP-003',
      route: 'San Carlos to Himamaylan',
      status: 'Completed',
      vehicle: 'L200',
      departureOrDate: 'Aug 18, 2026',
    ),
  ];

  String _selectedFilter = 'All';

  List<Trip> get _filteredTrips {
    if (_selectedFilter == 'All') {
      return _trips;
    }
    return _trips
        .where((trip) => trip.status == _selectedFilter)
        .toList();
  }

  void _navigateToTripSummary(String tripId) {
    // TODO: Navigate to the trip summary page for tripId.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text(
          'My Trips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterRow(),
            Expanded(
              child: _filteredTrips.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: _filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = _filteredTrips[index];
                        return _buildTripCard(trip);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;
          return FilterChip(
            label: Text(filter),
            selected: selected,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF707070),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            selectedColor: green,
            side: BorderSide(color: selected ? green : borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (value) {
              setState(() => _selectedFilter = filter);
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToTripSummary(trip.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(trip.status),
                  Icon(_statusIcon(trip.status), color: _statusColor(trip.status)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                trip.route,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
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
                  _buildTripDetail('Departure/Date', trip.departureOrDate),
                  _buildColumnDivider(),
                  _buildTripDetail('Status', trip.status),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _navigateToTripSummary(trip.id),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('View details'),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    foregroundColor: green,
                    padding: const EdgeInsets.only(left: 8),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final active = status == 'Active';
    final completed = status == 'Completed';
    final color = completed ? const Color(0xFF777777) : green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? green : Colors.transparent,
        border: active ? null : Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: active ? Colors.white : color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
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
          Icon(Icons.receipt_long_outlined, size: 52, color: green),
          const SizedBox(height: 12),
          const Text(
            'No trips found',
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Active':
        return Icons.directions_car_outlined;
      case 'Approved':
        return Icons.description_outlined;
      case 'Completed':
        return Icons.check_circle_outline;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return darkGreen;
      case 'Approved':
        return green;
      case 'Completed':
        return const Color(0xFF777777);
      default:
        return green;
    }
  }
}
