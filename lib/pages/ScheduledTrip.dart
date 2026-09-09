import 'dart:io';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:open_filex/open_filex.dart';

import '../services/notification_service.dart';
import '../services/trip_service.dart';

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
  static const Color green = AppColors.primary;
  static const Color softGreen = AppColors.mint;
  static const Color textColor = AppColors.navy;
  static const Color borderColor = AppColors.border;
  static const Color lightBg = AppColors.background;

  List<Trip> _trips = [];
  bool _isLoading = true;
  bool _isOpeningTicket = false;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final rawTrips = await TripService.getMyTrips(status: 'scheduled');
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
    final vehicle = data['vehicle'] is Map
        ? Map<String, dynamic>.from(data['vehicle'] as Map)
        : const <String, dynamic>{};
    final vehicleLabel = vehicle['name'] ?? vehicle['plate_no'] ?? '—';
    final departure =
        DateTime.tryParse(
          data['scheduled_departure']?.toString() ?? '',
        )?.toLocal() ??
        DateTime.now();
    return Trip(
      id: (data['id'] ?? '').toString(),
      route: '$origin to $destination',
      status: 'Approved',
      vehicle: vehicleLabel.toString(),
      departureTime: departure,
      expectedArrival: departure,
    );
  }

  List<Trip> get _sortedTrips {
    final trips = List<Trip>.from(_trips)
      ..sort(
        (first, second) => first.departureTime.compareTo(second.departureTime),
      );
    return trips;
  }

  Future<void> _openTripTicket(String tripId) async {
    if (_isOpeningTicket) return;

    setState(() => _isOpeningTicket = true);
    try {
      await NotificationService.markTripNotificationsAsRead(tripId);
      final response = await TripService.getTripTicket(int.parse(tripId));
      final file = File('${Directory.systemTemp.path}/trip_ticket_$tripId.pdf');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        _showMessage('No PDF viewer is available on this phone.');
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to open trip ticket: $error');
    } finally {
      if (mounted) setState(() => _isOpeningTicket = false);
    }
  }

  void _showDetailsDialog(Trip trip) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Route', trip.route),
            _detailRow('Vehicle', trip.vehicle),
            _detailRow('Departure', _formatDateTime(trip.departureTime)),
            _detailRow('Arrival', _formatDateTime(trip.expectedArrival)),
            _detailRow('Status', trip.status),
          ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: textColor, fontSize: 14),
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.glassFill,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
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
      body: ShellAtmosphere(
        child: Stack(
          children: [
            SafeArea(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sortedTrips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    itemCount: _sortedTrips.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _sortedTrips.length) {
                        return _buildPrintReminder();
                      }
                      return _buildTripCard(_sortedTrips[index]);
                    },
                  ),
            ),
            if (_isOpeningTicket) _buildTicketLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final now = DateTime.now();
    final scheduledDate = trip.departureTime;
    final sameDay =
        now.year == scheduledDate.year &&
        now.month == scheduledDate.month &&
        now.day == scheduledDate.day;
    final canStart =
        sameDay &&
        !now.isBefore(scheduledDate.subtract(const Duration(minutes: 10)));
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildScheduledBadge(), _buildTimingLabel(trip)],
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
                _buildTripDetail(
                  'Departure',
                  _formatDateTime(trip.departureTime),
                ),
                _buildColumnDivider(),
                _buildTripDetail(
                  'Arrival',
                  _formatDateTime(trip.expectedArrival),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canStart ? () => _startTrip(trip.id) : null,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Start Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canStart ? green : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await NotificationService.markTripNotificationsAsRead(
                        trip.id,
                      );
                      if (mounted) _showDetailsDialog(trip);
                    },
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
                    onPressed: () => _openTripTicket(trip.id),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('View trip ticket'),
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

  Future<void> _startTrip(String tripId) async {
    try {
      await TripService.startTrip(int.tryParse(tripId) ?? 0);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to start trip: $error')));
    }
  }

  Widget _buildScheduledBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: green),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'SCHEDULED',
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

  Widget _buildPrintReminder() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB9DEC9)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.print_outlined, color: green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You must log in to desktop to print the trip ticket.',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketLoadingOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x66000000),
        child: Center(
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(strokeWidth: 4),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Opening trip ticket...',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text('Please wait', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isDepartingSoon(Trip trip) {
    final timeUntilDeparture = trip.departureTime.difference(DateTime.now());
    return timeUntilDeparture >= Duration.zero &&
        timeUntilDeparture <= const Duration(hours: 24);
  }

  Widget _buildTimingLabel(Trip trip) {
    final now = DateTime.now();
    final scheduled = trip.departureTime;
    final sameDay =
        now.year == scheduled.year &&
        now.month == scheduled.month &&
        now.day == scheduled.day;
    final earlyWindow = scheduled.subtract(const Duration(minutes: 10));

    if (sameDay && now.isBefore(scheduled) && !now.isBefore(earlyWindow)) {
      return _timingBadge('Early start window', Colors.orange.shade700);
    }
    if (sameDay && now.isAfter(scheduled)) {
      return _timingBadge('Late start', Colors.red.shade700);
    }
    if (_isDepartingSoon(trip)) {
      return _buildDepartingSoonLabel();
    }
    return const SizedBox.shrink();
  }

  Widget _timingBadge(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
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
