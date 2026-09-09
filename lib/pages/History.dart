import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../services/trip_service.dart';

class Trip {
  const Trip({
    required this.id,
    required this.route,
    required this.date,
    required this.distance,
    required this.duration,
    required this.status,
    required this.movements,
  });

  final String id;
  final String route;
  final String date;
  final String distance;
  final String duration;
  final String status;
  final List<Map<String, dynamic>> movements;
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

  String _selectedFilter = 'All time';
  bool _isLoading = true;
  final Set<String> _downloadingTripIds = {};
  List<Trip> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final rawTrips = await TripService.getMyTrips(status: 'completed');
      if (!mounted) return;
      setState(() {
        _trips = rawTrips.map(_tripFromApi).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _trips = [];
        _isLoading = false;
      });
    }
  }

  Trip _tripFromApi(Map<String, dynamic> data) {
    final origin = (data['origin'] ?? '').toString();
    final destination = (data['destination'] ?? '').toString();
    final departure = DateTime.tryParse(
      data['scheduled_departure']?.toString() ?? '',
    );
    final distance = data['total_distance']?.toString() ?? '0';
    return Trip(
      id: (data['id'] ?? '').toString(),
      route: '$origin to $destination',
      date: departure == null ? '—' : _formatDate(departure.toLocal()),
      distance: '$distance km',
      duration: '—',
      status: 'Completed',
      movements:
          (data['movements'] is List ? data['movements'] as List : const [])
              .whereType<Map>()
              .map((movement) => Map<String, dynamic>.from(movement))
              .toList(),
    );
  }

  String _formatDate(DateTime date) =>
      '${_month(date.month)} ${date.day}, ${date.year}';

  String _month(int month) {
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
        title: Text(
          'Trip History (${_trips.length})',
          style: const TextStyle(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _trips.isEmpty
                  ? _buildEmptyState()
                  : _buildTripList(),
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
                    onPressed: () => _showTripDetails(trip),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: green),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _downloadingTripIds.contains(trip.id)
                    ? null
                    : () => _downloadPdf(trip.id),
                icon: _downloadingTripIds.contains(trip.id)
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined, size: 18),
                label: Text(
                  _downloadingTripIds.contains(trip.id)
                      ? 'Downloading...'
                      : 'Download as PDF',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTripDetails(Trip trip) async {
    String time(Map<String, dynamic> movement, String key) {
      final value = DateTime.tryParse('${movement[key] ?? ''}')?.toLocal();
      return value == null ? 'Not recorded' : _formatDateTime(value);
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(trip.route),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${trip.status}'),
              for (final movement in trip.movements) ...[
                const SizedBox(height: 10),
                Text(
                  'Movement ${movement['movement_no']}: ${movement['origin']} to ${movement['destination']}',
                ),
                Text('Departure: ${time(movement, 'actual_departure_at')}'),
                Text('Arrival: ${time(movement, 'actual_arrival_at')}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) =>
      '${_month(value.month)} ${value.day}, ${value.year} ${value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour)}:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';

  Future<void> _downloadPdf(String tripId) async {
    if (_downloadingTripIds.contains(tripId)) return;

    setState(() => _downloadingTripIds.add(tripId));
    try {
      final response = await TripService.getTripTicket(int.parse(tripId));
      final file = File('${Directory.systemTemp.path}/trip_ticket_$tripId.pdf');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No PDF viewer is available on this phone.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to download PDF: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingTripIds.remove(tripId));
      }
    }
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
