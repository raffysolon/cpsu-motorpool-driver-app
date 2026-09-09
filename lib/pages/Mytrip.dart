import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../services/notification_service.dart';
import '../services/trip_service.dart';

class Trip {
  const Trip({
    required this.id,
    required this.route,
    required this.status,
    required this.secondaryStatus,
    required this.vehicle,
    required this.departureOrDate,
  });

  final String id;
  final String route;
  final String status;
  final String? secondaryStatus;
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
  static const Color textColor = Color(0xFF1F2A2A);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightBg = Color(0xFFF5F6F5);

  static const List<String> _filters = [
    'All',
    'Pending',
    'Approved',
    'Denied',
  ];

  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isOpeningTicket = false;
  List<Trip> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final rawTrips = await TripService.getMyTrips();
      if (!mounted) return;
      setState(() {
        _trips = rawTrips
            .where((trip) {
              final status = (trip['effective_status'] ?? trip['status'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase();
              return status != 'completed';
            })
            .map(_tripFromApi)
            .toList();
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
    final vehicleName = vehicle['name'] ?? vehicle['plate_no'] ?? '—';
    final scheduled = data['scheduled_departure']?.toString() ?? '';
    final rawStatus = (data['status'] ?? 'pending').toString();
    final effectiveStatus = (data['effective_status'] ?? rawStatus).toString();
    final isApprovedScheduled =
        rawStatus.trim().toLowerCase() == 'approved' &&
        effectiveStatus.trim().toLowerCase() == 'scheduled';
    return Trip(
      id: (data['id'] ?? '').toString(),
      route: '$origin to $destination',
      status: _displayStatus(rawStatus),
      secondaryStatus: isApprovedScheduled ? 'Scheduled' : null,
      vehicle: vehicleName.toString(),
      departureOrDate: _formatDateTime(scheduled),
    );
  }

  String _displayStatus(String value) {
    final status = value.trim().toLowerCase();
    if (status == 'approved') return 'Approved';
    if (status == 'scheduled') return 'Scheduled';
    if (status == 'active') return 'Active';
    if (status == 'completed') return 'Completed';
    if (status == 'denied') return 'Denied';
    return status.isEmpty
        ? 'Pending'
        : '${status[0].toUpperCase()}${status.substring(1)}';
  }

  String _formatDateTime(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return '—';
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_month(date.month)} ${date.day}, ${date.year}\n$hour:$minute $period';
  }

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

  List<Trip> get _filteredTrips {
    if (_selectedFilter == 'All') return _trips;
    return _trips.where((trip) => trip.status == _selectedFilter).toList();
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

  bool _canViewTicket(Trip trip) {
    final status = trip.status.trim().toLowerCase();
    return status == 'approved' ||
        status == 'scheduled' ||
        status == 'active' ||
        status == 'completed';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showTripDetails(Trip trip) async {
    await NotificationService.markTripNotificationsAsRead(trip.id);
    if (!mounted) return;

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
            _detailRow('Departure / Date', trip.departureOrDate),
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildFilterRow(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredTrips.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                          itemCount: _filteredTrips.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _filteredTrips.length) {
                              return _buildPrintReminder();
                            }
                            final trip = _filteredTrips[index];
                            return _buildTripCard(trip);
                          },
                        ),
                ),
              ],
            ),
          ),
          if (_isOpeningTicket) _buildTicketLoadingOverlay(),
        ],
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
        onTap: _canViewTicket(trip) ? () => _openTripTicket(trip.id) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusStack(trip),
                  Icon(
                    _statusIcon(trip.status),
                    color: _statusColor(trip.status),
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showTripDetails(trip),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: green),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_canViewTicket(trip))
                    ElevatedButton.icon(
                      onPressed: () => _openTripTicket(trip.id),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('View trip ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final denied = status == 'Denied';
    final completed = status == 'Completed';
    final color = denied
        ? Colors.red.shade700
        : completed
        ? const Color(0xFF777777)
        : green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: denied ? Colors.red.shade50 : Colors.transparent,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatusStack(Trip trip) {
    return _buildStatusBadge(trip.status);
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

  IconData _statusIcon(String status) {
    switch (status) {
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
      case 'Approved':
        return green;
      case 'Denied':
        return Colors.red.shade700;
      case 'Completed':
        return const Color(0xFF777777);
      default:
        return green;
    }
  }
}
