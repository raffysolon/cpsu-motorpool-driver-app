import 'package:flutter/material.dart';
import 'package:cpsumotorpooladmin/widgets/app_shell.dart';

// ═══════════════════════════════════════════════════════════════
// VEHICLE & DRIVERS PAGE
// Admin can add/edit/delete vehicles and assign drivers
// Route: /vehicles
// ═══════════════════════════════════════════════════════════════

// ─── Page Wrapper ───
class Vehicles extends StatelessWidget {
  const Vehicles({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/vehicles',
      child: const _VehiclesContent(),
    );
  }
}

// ─── Data Model ───
class _VehicleData {
  String name;
  String plate;
  String status; // 'Available', 'In-Use', 'Maintenance' (auto-determined)
  String assignedDriver;

  _VehicleData({
    required this.name,
    required this.plate,
    required this.status,
    this.assignedDriver = '',
  });
}

// ─── Stateful Content ───
class _VehiclesContent extends StatefulWidget {
  const _VehiclesContent();

  @override
  State<_VehiclesContent> createState() => _VehiclesContentState();
}

class _VehiclesContentState extends State<_VehiclesContent> {
  // ─── Mock Vehicle List (replace with API/database later) ───
  final List<_VehicleData> _vehicles = [
    _VehicleData(
      name: 'Toyota Innova (2022)',
      plate: 'SJA 4421',
      status: 'Available',
    ),
    _VehicleData(
      name: 'Mitsubishi L300 (2021)',
      plate: 'SJB 8832',
      status: 'In-Use',
      assignedDriver: 'Maria Santos',
    ),
    _VehicleData(
      name: 'Toyota Hi-Ace (2023)',
      plate: 'SJC 1194',
      status: 'Available',
    ),
    _VehicleData(
      name: 'Ford Ranger (2020)',
      plate: 'SJD 5567',
      status: 'Maintenance',
    ),
    _VehicleData(
      name: 'Toyota Fortuner (2022)',
      plate: 'SJE 2289',
      status: 'In-Use',
      assignedDriver: 'Eduardo Flores',
    ),
  ];

  // ─── Add Vehicle Dialog ───
  void _showAddVehicleDialog() {
    final nameCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final driverCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Add Vehicle',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl, 'Vehicle Name / Model'),
                  const SizedBox(height: 12),
                  _dialogField(plateCtrl, 'Plate Number'),
                  const SizedBox(height: 12),
                  _dialogField(driverCtrl, 'Assigned Driver (optional)'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty ||
                      plateCtrl.text.trim().isEmpty) {
                    return;
                  }
                  setState(() {
                    _vehicles.add(_VehicleData(
                      name: nameCtrl.text.trim(),
                      plate: plateCtrl.text.trim(),
                      status: 'Available',
                      assignedDriver: driverCtrl.text.trim(),
                    ));
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  // ─── Edit Vehicle Dialog ───
  void _showEditDialog(int index) {
    final v = _vehicles[index];
    final nameCtrl = TextEditingController(text: v.name);
    final plateCtrl = TextEditingController(text: v.plate);
    final driverCtrl = TextEditingController(text: v.assignedDriver);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('Edit Vehicle',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(nameCtrl, 'Vehicle Name / Model'),
                  const SizedBox(height: 12),
                  _dialogField(plateCtrl, 'Plate Number'),
                  const SizedBox(height: 12),
                  _dialogField(driverCtrl, 'Assigned Driver (optional)'),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty ||
                      plateCtrl.text.trim().isEmpty) {
                    return;
                  }
                  setState(() {
                    v.name = nameCtrl.text.trim();
                    v.plate = plateCtrl.text.trim();
                    v.assignedDriver = driverCtrl.text.trim();
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  // ─── Delete Confirmation Dialog ───
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Vehicle',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
            'Are you sure you want to delete "${_vehicles[index].name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _vehicles.removeAt(index));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Text Field for Dialogs ───
  Widget _dialogField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ─── Build Method ───
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(),
                const SizedBox(height: 16),
                _buildTable(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Top Bar (Title + Notification + Profile) ───
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Vehicle & Drivers',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy)),
              SizedBox(height: 2),
              Text('Province of Negros Occidental — Motorpool Division',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.mutedDark)),
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
                      color: Colors.amber, shape: BoxShape.circle),
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

  // ─── Section Header ("Fleet Vehicles & Drivers" + Add button) ───
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Fleet Vehicles & Drivers',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.navy)),
        ElevatedButton.icon(
          onPressed: _showAddVehicleDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Vehicle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ─── Table Container ───
  Widget _buildTable() {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.mutedDark,
      letterSpacing: 0.8,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // ─── Table Header Row ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: const [
                Expanded(flex: 6, child: Text('VEHICLE NAME / MODEL', style: headerStyle)),
                Expanded(flex: 4, child: Text('PLATE NUMBER', style: headerStyle)),
                Expanded(flex: 4, child: Text('ASSIGNED DRIVER', style: headerStyle)),
                Expanded(flex: 3, child: Text('STATUS', style: headerStyle)),
                SizedBox(width: 80, child: Text('ACTIONS', style: headerStyle)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // ─── Table Data Rows ───
          ..._vehicles.asMap().entries.map((entry) {
            final i = entry.key;
            final v = entry.value;
            return Column(
              children: [
                _buildRow(i, v),
                if (i < _vehicles.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Table Data Row ───
  Widget _buildRow(int index, _VehicleData v) {
    // Status color mapping
    Color statusColor;
    Color statusBg;
    switch (v.status) {
      case 'Available':
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        break;
      case 'In-Use':
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        break;
      case 'Maintenance':
        statusColor = const Color(0xFF6B7280);
        statusBg = const Color(0xFFF3F4F6);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBg = const Color(0xFFF3F4F6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Vehicle name
          Expanded(
            flex: 6,
            child: Text(v.name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy)),
          ),
          // Plate number
          Expanded(
            flex: 4,
            child: Text(v.plate,
                style: const TextStyle(fontSize: 13, color: AppColors.navy)),
          ),
          // Assigned driver
          Expanded(
            flex: 4,
            child: Text(
              v.assignedDriver.isEmpty ? '—' : v.assignedDriver,
              style: TextStyle(
                fontSize: 13,
                color: v.assignedDriver.isEmpty
                    ? AppColors.muted
                    : AppColors.navy,
              ),
            ),
          ),
          // Status badge
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(v.status,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ),
          ),
          // Action buttons (edit + delete)
          SizedBox(
            width: 80,
            child: Row(
              children: [
                InkWell(
                  onTap: () => _showEditDialog(index),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.mutedDark),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _confirmDelete(index),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.mutedDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
