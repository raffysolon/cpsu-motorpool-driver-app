import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../services/trip_service.dart';

class CreateTripTicket extends StatefulWidget {
  const CreateTripTicket({super.key});

  @override
  State<CreateTripTicket> createState() => _CreateTripTicketState();
}

class _CreateTripTicketState extends State<CreateTripTicket> {
  static const green = AppColors.primary;
  static const darkGreen = AppColors.primaryDark;
  static const ink = AppColors.navy;
  static const muted = AppColors.mutedDark;
  static const line = AppColors.border;
  static const background = AppColors.background;

  final formKey = GlobalKey<FormState>();
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final purposeController = TextEditingController();
  final passengers = <Map<String, String>>[];

  int step = 0;
  bool isLoadingAssignment = true;
  bool isSubmitting = false;
  int? vehicleId;
  String? vehicleDisplayName;
  DateTime departureDate = DateTime.now();
  TimeOfDay departureTime = TimeOfDay.now();
  DateTime? returnDate;
  TimeOfDay? returnTime;

  @override
  void initState() {
    super.initState();
    loadAssignment();
  }

  Future<void> loadAssignment() async {
    try {
      final assignment = await TripService.getMyAssignment();
      final vehicle = assignment?['vehicle'];
      final name = vehicle is Map ? '${vehicle['name'] ?? ''}' : '';
      final plate = vehicle is Map ? '${vehicle['plate_no'] ?? ''}' : '';
      if (!mounted) return;
      setState(() {
        final assignedVehicleId = int.tryParse(
          '${assignment?['vehicle_id'] ?? (vehicle is Map ? vehicle['id'] : '')}',
        );
        final displayName = [
          name,
          plate,
        ].where((value) => value.isNotEmpty).join(' - ');
        vehicleId = vehicle is Map && displayName.isNotEmpty
            ? assignedVehicleId
            : null;
        vehicleDisplayName = displayName;
        isLoadingAssignment = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoadingAssignment = false;
        vehicleId = null;
      });
    }
  }

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: AppColors.glassFill,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Create Trip Ticket',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ShellAtmosphere(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  buildProgress(),
                  const SizedBox(height: 22),
                  if (step == 0) buildDetails(),
                  if (step == 1) buildPassengers(),
                  if (step == 2) buildReview(),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget buildProgress() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      borderRadius: 16,
      child: Row(
        children: [
          buildStep(0, 'Trip Details', Icons.edit_note_rounded),
          buildLine(0),
          buildStep(1, 'Passengers', Icons.people_outline_rounded),
          buildLine(1),
          buildStep(2, 'Review', Icons.fact_check_outlined),
        ],
      ),
    );
  }

  Widget buildStep(int index, String label, IconData icon) {
    final active = step == index;
    final complete = step > index;
    final color = active || complete ? green : muted;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: active || complete ? green : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(
              complete ? Icons.check_rounded : icon,
              color: active || complete ? Colors.white : muted,
              size: 18,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: active || complete
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLine(int index) => Expanded(
    child: Container(
      height: 2,
      color: step > index ? green : line,
      margin: const EdgeInsets.only(bottom: 24),
    ),
  );

  Widget panel(String title, String subtitle, Widget child) {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 13)),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget field(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: green, size: 19),
          filled: true,
          fillColor: background,
          border: outline(),
          enabledBorder: outline(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: green, width: 1.5),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outline() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: const BorderSide(color: line),
  );

  Widget assignedVehicle() {
    if (isLoadingAssignment)
      return const Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: LinearProgressIndicator(color: green),
      );
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Vehicle',
          prefixIcon: const Icon(
            Icons.directions_car_outlined,
            color: muted,
            size: 19,
          ),
          filled: true,
          fillColor: const Color(0xFFEFF2F0),
          border: outline(),
          enabledBorder: outline(),
        ),
        child: Text(
          vehicleDisplayName?.isNotEmpty == true
              ? vehicleDisplayName!
              : 'No vehicle assigned',
          style: const TextStyle(color: muted, fontSize: 13),
        ),
      ),
    );
  }

  Widget dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: pickDateAndTime,
        borderRadius: BorderRadius.circular(9),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Scheduled Departure',
            prefixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: green,
              size: 19,
            ),
            suffixIcon: const Icon(
              Icons.access_time_rounded,
              color: green,
              size: 19,
            ),
            filled: true,
            fillColor: background,
            border: outline(),
            enabledBorder: outline(),
          ),
          child: Text(
            '${formatDate(departureDate)}   ${formatTime(departureTime)}',
            style: const TextStyle(color: ink, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget returnDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: pickReturnDateAndTime,
        borderRadius: BorderRadius.circular(9),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Return Departure (Optional)',
            prefixIcon: const Icon(
              Icons.keyboard_return_rounded,
              color: green,
              size: 19,
            ),
            suffixIcon: returnDate == null
                ? const Icon(Icons.add_circle_outline, color: green, size: 19)
                : IconButton(
                    tooltip: 'Clear return schedule',
                    icon: const Icon(Icons.clear, color: green, size: 19),
                    onPressed: () => setState(() {
                      returnDate = null;
                      returnTime = null;
                    }),
                  ),
            filled: true,
            fillColor: background,
            border: outline(),
            enabledBorder: outline(),
          ),
          child: Text(
            returnDate == null || returnTime == null
                ? 'To be confirmed'
                : '${formatDate(returnDate!)}   ${formatTime(returnTime!)}',
            style: const TextStyle(color: ink, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget buildDetails() {
    return panel(
      'Trip Details',
      'Enter the information for this trip request.',
      Form(
        key: formKey,
        child: Column(
          children: [
            assignedVehicle(),
            field('Origin', originController, Icons.trip_origin),
            field(
              'Destination',
              destinationController,
              Icons.location_on_outlined,
            ),
            field(
              'Purpose of Trip',
              purposeController,
              Icons.description_outlined,
            ),
            dateField(),
            returnDateField(),
            primaryButton(
              'Continue to Passengers',
              nextStep,
              labelColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPassengers() {
    return panel(
      'Passengers',
      'Add everyone who will travel on this trip.',
      Column(
        children: [
          if (passengers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: line),
              ),
              child: const Column(
                children: [
                  Icon(Icons.people_outline, color: muted, size: 34),
                  SizedBox(height: 8),
                  Text(
                    'No passengers added yet.',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ...passengers.asMap().entries.map(
              (entry) => passengerTile(entry.key, entry.value),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: showAddPassenger,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD PASSENGER'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: secondaryButton('Back', () => setState(() => step = 0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: primaryButton(
                  'Review Ticket',
                  nextStep,
                  labelColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget passengerTile(int index, Map<String, String> passenger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE8F7F0),
            child: Icon(Icons.person, color: green, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger['name'] ?? '',
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((passenger['designation'] ?? '').isNotEmpty)
                  Text(
                    passenger['designation']!,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => passengers.removeAt(index)),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReview() {
    final passengerRows = passengers.isEmpty
        ? <Widget>[
            const Text(
              'No passengers added.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ]
        : passengers.map((passenger) {
            final name = passenger['name'] ?? '';
            final designation = passenger['designation'] ?? '';
            return row(
              'Passenger',
              designation.isEmpty ? name : '$name - $designation',
            );
          }).toList();

    return panel(
      'Review Trip Ticket',
      'Please confirm that the information below is correct.',
      Column(
        children: [
          reviewSection('Trip Information', [
            row('Vehicle', vehicleDisplayName ?? 'No vehicle assigned'),
            row(
              'Route',
              '${originController.text} to ${destinationController.text}',
            ),
            row('Purpose', purposeController.text),
            row(
              'Departure',
              '${formatDate(departureDate)} at ${formatTime(departureTime)}',
            ),
            row(
              'Return',
              returnDate == null || returnTime == null
                  ? 'To be confirmed'
                  : '${formatDate(returnDate!)} at ${formatTime(returnTime!)}',
            ),
          ]),
          const SizedBox(height: 15),
          reviewSection('Passengers (${passengers.length})', passengerRows),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: secondaryButton('Back', () => setState(() => step = 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: primaryButton(
                  isSubmitting ? 'Submitting...' : 'Submit Trip Ticket',
                  isSubmitting ? null : submitTicket,
                  labelColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget reviewSection(String title, List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        ...children,
      ],
    ),
  );
  Widget row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  Widget primaryButton(
    String label,
    VoidCallback? onPressed, {
    Color labelColor = Colors.black,
  }) => SizedBox(
    height: 48,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: labelColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
  Widget secondaryButton(String label, VoidCallback onPressed) => SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );

  void nextStep() {
    if (step == 0 &&
        (!(formKey.currentState?.validate() ?? false) ||
            vehicleId == null ||
            vehicleDisplayName?.isEmpty != false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete the trip details and vehicle assignment first.',
          ),
        ),
      );
      return;
    }
    setState(() => step = (step + 1).clamp(0, 2));
  }

  Future<void> pickDateAndTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: departureDate.isBefore(now) ? now : departureDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: departureTime,
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      departureDate = pickedDate;
      departureTime = pickedTime;
    });
  }

  Future<void> pickReturnDateAndTime() async {
    final now = DateTime.now();
    final initialDate = returnDate ?? departureDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(DateTime(now.year, now.month, now.day))
          ? now
          : initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: returnTime ?? departureTime,
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      returnDate = pickedDate;
      returnTime = pickedTime;
    });
  }

  Future<void> showAddPassenger() async {
    final passenger = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddPassengerDialog(),
    );
    if (passenger != null && mounted) setState(() => passengers.add(passenger));
  }

  Future<void> submitTicket() async {
    if (vehicleId == null || isSubmitting) return;
    setState(() => isSubmitting = true);
    final scheduled = DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
      departureTime.hour,
      departureTime.minute,
    ).toIso8601String();
    final returnScheduled = returnDate == null || returnTime == null
        ? null
        : DateTime(
            returnDate!.year,
            returnDate!.month,
            returnDate!.day,
            returnTime!.hour,
            returnTime!.minute,
          );
    try {
      await TripService.createTrip(
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        purpose: purposeController.text.trim(),
        scheduledDeparture: DateTime.parse(scheduled),
        returnScheduledDeparture: returnScheduled,
        passengers: passengers,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Trip Ticket Submitted'),
          content: const Text('Your trip ticket has been sent for review.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to submit trip ticket: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  String formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}

class _AddPassengerDialog extends StatefulWidget {
  const _AddPassengerDialog();

  @override
  State<_AddPassengerDialog> createState() => _AddPassengerDialogState();
}

class _AddPassengerDialogState extends State<_AddPassengerDialog> {
  final nameController = TextEditingController();
  final designationController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    designationController.dispose();
    super.dispose();
  }

  void addPassenger() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(context, {
      'name': name,
      'designation': designationController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Passenger'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Passenger name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: designationController,
            decoration: const InputDecoration(
              labelText: 'Designation / Position',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: addPassenger,
          style: ElevatedButton.styleFrom(
            backgroundColor: _CreateTripTicketState.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
