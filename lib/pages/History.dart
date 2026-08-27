import 'package:flutter/material.dart';

class Trip {
  const Trip({
    required this.id,
    required this.route,
    required this.date,
    required this.distance,
    required this.duration,
    required this.status,
  });

  final String id;
  final String route;
  final String date;
  final String distance;
  final String duration;
  final String status;
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color green = Color(0xFF0F8C59);
  static const Color softGreen = Color(0xFFBFE8D1);
  static const Color textColor = Color(0xFF1F2A2A);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightBg = Color(0xFFF5F6F5);

  static const List<String> _filters = [
    'All time',
    'This month',
    'Last 3 months',
  ];

  static const List<Trip> _trips = [
    Trip(
      id: 'TRIP-101',
      route: 'San Carlos to Bacolod',
      date: 'Aug 20, 2026',
      distance: '84 km',
      duration: '2h 15m',
      status: 'Completed',
    ),
    Trip(
      id: 'TRIP-102',
      route: 'Bacolod to Kabankalan',
      date: 'Aug 12, 2026',
      distance: '96 km',
      duration: '2h 40m',
      status: 'Completed',
    ),
    Trip(
      id: 'TRIP-103',
      route: 'San Carlos to Himamaylan',
      date: 'Jul 28, 2026',
      distance: '112 km',
      duration: '3h 05m',
      status: 'Completed',
    ),
  ];

  String _selectedFilter = 'All time';

  void _viewTripTicket(String tripId) {
    // TODO: Open a PDF preview for tripId.
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
          'Trip History',
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
              child: _trips.isEmpty ? _buildEmptyState() : _buildTripList(),
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
              // TODO: Apply the selected date range when history filtering is connected.
            },
          );
        },
      ),
    );
  }

  Widget _buildTripList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: _trips.length,
      itemBuilder: (context, index) => _buildTripCard(_trips[index]),
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
                _buildCompletedBadge(),
                const Icon(Icons.check_circle_outline, color: green),
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
                _buildTripDetail('Date', trip.date),
                _buildColumnDivider(),
                _buildTripDetail('Distance (km)', trip.distance),
                _buildColumnDivider(),
                _buildTripDetail('Duration', trip.duration),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewTripTicket(trip.id),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View'),
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

  Widget _buildCompletedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'COMPLETED',
        style: TextStyle(
          color: Color(0xFF777777),
          fontSize: 10,
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
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: softGreen,
            ),
            child: const Icon(Icons.history_outlined, size: 44, color: green),
          ),
          const SizedBox(height: 16),
          const Text(
            'No completed trips yet',
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
}
