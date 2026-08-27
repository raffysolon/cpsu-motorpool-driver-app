import 'package:flutter/material.dart';
import 'package:cpsumotorpooladmin/widgets/app_shell.dart';

// ═══════════════════════════════════════════════════════════════
// TRIP REQUEST PAGE
// Shows pending trip requests with approve/deny status
// Route: /trip-request
// ═══════════════════════════════════════════════════════════════

// ─── Page Wrapper ───
class TripRequest extends StatelessWidget {
  const TripRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/trip-request',
      child: const _TripRequestContent(),
    );
  }
}

// ─── Data Model ───
class _TripRequestData {
  final String driverName;
  final String vehicle;
  final String destination;
  final String departure;
  final String status; // 'Pending', 'Approved', 'Denied'

  const _TripRequestData({
    required this.driverName,
    required this.vehicle,
    required this.destination,
    required this.departure,
    required this.status,
  });
}

// ─── Mock Data (replace with API/database later) ───
const _mockRequests = [
  _TripRequestData(
    driverName: 'Ramon Dela Cruz',
    vehicle: 'Toyota Innova — SJA 4421',
    destination: 'Bacolod to San Carlos',
    departure: '2026-08-20\n07:00',
    status: 'Denied',
  ),
  _TripRequestData(
    driverName: 'Maria Santos',
    vehicle: 'Mitsubishi L300 — SJB 8832',
    destination: 'Bacolod to Kabankalan',
    departure: '2026-08-20\n08:30',
    status: 'Approved',
  ),
  _TripRequestData(
    driverName: 'Jose Reyes',
    vehicle: 'Toyota Hi-Ace — SJC 1194',
    destination: 'Bacolod to Himamaylan',
    departure: '2026-08-21\n06:00',
    status: 'Pending',
  ),
  _TripRequestData(
    driverName: 'Lourdes Manalo',
    vehicle: 'Ford Ranger — SJD 5567',
    destination: 'Bacolod to Silay City',
    departure: '2026-08-21\n09:00',
    status: 'Pending',
  ),
  _TripRequestData(
    driverName: 'Eduardo Flores',
    vehicle: 'Toyota Fortuner — SJE 2289',
    destination: 'Bacolod to La Carlota',
    departure: '2026-08-22\n07:30',
    status: 'Pending',
  ),
];

// ─── Main Content Layout ───
class _TripRequestContent extends StatelessWidget {
  const _TripRequestContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(),
                const SizedBox(height: 16),
                _buildTable(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Top Bar (Title + Notification + Profile) ───
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Trip Requests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Province of Negros Occidental — Motorpool Division',
                style: TextStyle(fontSize: 13, color: AppColors.mutedDark),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    size: 24, color: AppColors.navy),
                onPressed: () {},
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          // Profile avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ("Pending Trip Requests" + count) ───
  Widget _buildSectionHeader() {
    final pendingCount =
        _mockRequests.where((r) => r.status == 'Pending').length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pending Trip Requests',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        Text(
          '$pendingCount pending',
          style: const TextStyle(fontSize: 13, color: AppColors.mutedDark),
        ),
      ],
    );
  }

  // ─── Table Container ───
  Widget _buildTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: AppColors.border),
          ..._mockRequests.asMap().entries.map((entry) {
            final i = entry.key;
            final req = entry.value;
            return Column(
              children: [
                _buildTableRow(context, req),
                if (i < _mockRequests.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Table Header Row ───
  Widget _buildTableHeader() {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.mutedDark,
      letterSpacing: 0.8,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: const [
          SizedBox(width: 36),
          SizedBox(width: 12),
          Expanded(flex: 5, child: Text('DRIVER NAME', style: style)),
          Expanded(flex: 6, child: Text('VEHICLE', style: style)),
          Expanded(flex: 6, child: Text('DESTINATION', style: style)),
          Expanded(flex: 5, child: Text('DEPARTURE', style: style)),
          Expanded(flex: 4, child: Text('STATUS', style: style)),
          SizedBox(width: 110),
        ],
      ),
    );
  }

  // ─── Table Data Row ───
  Widget _buildTableRow(BuildContext context, _TripRequestData req) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Driver avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.person_outline,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          // Driver name
          Expanded(
            flex: 5,
            child: Text(
              req.driverName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          // Vehicle
          Expanded(
            flex: 6,
            child: Text(
              req.vehicle,
              style: const TextStyle(fontSize: 13, color: AppColors.navy),
            ),
          ),
          // Destination
          Expanded(
            flex: 6,
            child: Text(
              req.destination,
              style: const TextStyle(fontSize: 13, color: AppColors.navy),
            ),
          ),
          // Departure date/time
          Expanded(
            flex: 5,
            child: Text(
              req.departure,
              style: const TextStyle(fontSize: 13, color: AppColors.navy),
            ),
          ),
          // Status badge
          Expanded(
            flex: 4,
            child: _StatusBadge(status: req.status),
          ),
          // View Details button
          SizedBox(
            width: 110,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge Widget (Approved / Denied / Pending) ───
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;

    switch (status) {
      case 'Approved':
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFDCFCE7);
        break;
      case 'Denied':
        textColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEE2E2);
        break;
      case 'Pending':
      default:
        textColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFEF3C7);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
