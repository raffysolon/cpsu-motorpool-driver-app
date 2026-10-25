import '../widgets/app_notification.dart';
import '../widgets/skeleton_widgets.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:open_filex/open_filex.dart';

import '../services/notification_service.dart';
import '../services/trip_service.dart';
import '../widgets/interaction_loading_overlay.dart';

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

class _MyTripState extends State<MyTrip> with WidgetsBindingObserver {
  static const Color green = AppColors.primary;
  static const Color textColor = AppColors.navy;
  static const Color borderColor = AppColors.border;
  static const Color lightBg = AppColors.background;

  static const List<String> _filters = [
    'All',
    'Pending',
    'Approved',
    'Active',
    'Denied',
  ];

  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isOpeningTicket = false;
  bool _isDialogOpen = false;
  bool _isPageVisible = true;
  bool _isRefreshRunning = false;
  Timer? _refreshTimer;
  String? _loadError;
  List<Trip> _trips = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTrips();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted ||
          !_isPageVisible ||
          _isDialogOpen ||
          _isOpeningTicket ||
          _isRefreshRunning) {
        return;
      }
      _loadTrips(background: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isPageVisible = true;
      if (!_isRefreshRunning) {
        _loadTrips(background: true);
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _isPageVisible = false;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadTrips({bool background = false}) async {
    if (background) {
      if (_isRefreshRunning ||
          !mounted ||
          !_isPageVisible ||
          _isDialogOpen ||
          _isOpeningTicket) {
        return;
      }
      _isRefreshRunning = true;
    } else if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final rawTrips = await TripService.getMyTrips();
      final nextTrips = rawTrips
          .where((trip) {
            final status = (trip['effective_status'] ?? trip['status'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            return status != 'completed';
          })
          .map(_tripFromApi)
          .toList();
      if (!mounted) return;
      if (!background || _hasTripsChanged(nextTrips)) {
        setState(() {
          _trips = nextTrips;
          _isLoading = false;
          _loadError = null;
        });
      }
    } catch (_) {
      if (background) return;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load trips. Check your connection and try again.';
      });
    } finally {
      if (background) {
        _isRefreshRunning = false;
      }
    }
  }

  bool _hasTripsChanged(List<Trip> nextTrips) {
    if (_trips.length != nextTrips.length) return true;
    for (var i = 0; i < nextTrips.length; i++) {
      final current = _trips[i];
      final next = nextTrips[i];
      if (current.id != next.id ||
          current.route != next.route ||
          current.status != next.status ||
          current.secondaryStatus != next.secondaryStatus ||
          current.vehicle != next.vehicle ||
          current.departureOrDate != next.departureOrDate) {
        return true;
      }
    }
    return false;
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
    final displayStatus = effectiveStatus.trim().toLowerCase() == 'active'
        ? effectiveStatus
        : rawStatus;
    final isApprovedScheduled =
        rawStatus.trim().toLowerCase() == 'approved' &&
        effectiveStatus.trim().toLowerCase() == 'scheduled';
    return Trip(
      id: (data['id'] ?? '').toString(),
      route: '$origin to $destination',
      status: _displayStatus(displayStatus),
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
    return _trips.where((trip) {
      return _selectedFilter == 'All' || trip.status == _selectedFilter;
    }).toList();
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
    AppNotification.show(context, SnackBar(content: Text(message)));
  }

  Future<void> _showTripDetails(Trip trip) async {
    await NotificationService.markTripNotificationsAsRead(trip.id);
    if (!mounted) return;

    _isDialogOpen = true;
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
    ).then((_) {
      if (mounted) {
        setState(() => _isDialogOpen = false);
      }
    });
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          backgroundColor: lightBg,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.glassFill,
            foregroundColor: AppColors.navy,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'My Trips',
              style: AppTypography.displayTitle(
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
                  child: Column(
                    children: [
                      _buildFilterRow(),
                      Expanded(
                        child: _isLoading
                            ? ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                                itemCount: 3,
                                itemBuilder: (context, index) => SkeletonWidgets.tripCard(),
                              )
                            : _filteredTrips.isEmpty
                            ? _loadError == null
                                  ? _buildEmptyState()
                                  : _buildLoadError()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  4,
                                  20,
                                  20,
                                ),
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
              ],
            ),
          ),
        ),
        if (_isOpeningTicket) _buildTicketLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: AppColors.mutedDark,
            ),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedDark),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _loadTrips(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: SizedBox(
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
              labelStyle: AppTypography.bodyStyle(
                color: selected ? Colors.white : AppColors.mutedDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.glassFill,
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
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      borderRadius: 12,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showTripDetails(trip),
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
                  if (_canViewTicket(trip))
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openTripTicket(trip.id),
                        icon: const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 18,
                        ),
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
        style: AppTypography.labelCaps(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
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
          Text(
            'No trips found',
            style: AppTypography.bodyStyle(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.print_outlined, color: green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You must log in to desktop to print the trip ticket.',
              style: AppTypography.bodyStyle(
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
    return const InteractionLoadingOverlay(message: 'Opening trip ticket...');
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
