// ===== IMPORTS - START =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../services/trip_service.dart';

// ===== IMPORTS - END =====

// ===== ADD TRIP PAGE - START =====
/// Add Trip page for creating new trip tickets
/// Multi-step form with 3 steps: Trip Details, Passengers, Review
class AddTrip extends StatefulWidget {
  const AddTrip({super.key});

  @override
  State<AddTrip> createState() => _AddTripState();
}

// ===== ADD TRIP STATE - START =====
/// State class for AddTrip
/// Manages multi-step form state and trip creation process
class _AddTripState extends State<AddTrip> {
  // ===== COLOR THEME - START =====
  static const Color green = AppColors.primary;
  static const Color textColor = AppColors.navy;
  static const Color borderColor = AppColors.border;
  static const Color lightBg = AppColors.background;
  // ===== COLOR THEME - END =====

  // ===== FORM STEP TRACKING - START =====
  /// Current form step (0: Trip Details, 1: Passengers, 2: Review)
  int _currentStep = 0;
  // ===== FORM STEP TRACKING - END =====

  // ===== FORM OPTIONS - START =====

  final List<String> _vehicles = [
    'CPSU SAN CARLOS - L300',
    'CPSU SAN CARLOS - L200',
    'CPSU SAN CARLOS - L500',
  ];

  final List<String> _startPlaces = [
    '',
    'CPSU SAN CARLOS',
    'Bacolod',
    'Himamaylan',
    'Kabankalan',
  ];

  final List<String> _destinations = [
    'Bacolod',
    'CPSU SAN CARLOS',
    'Himamaylan',
    'Kabankalan',
  ];

  final List<String> _purposes = [
    'Paper Works',
    'Official Business',
    'Field Visit',
    'School Activity',
  ];

  final List<String> _passengers = [];

  /// Controller for passenger name input field
  final TextEditingController _passengerNameController =
      TextEditingController();

  @override
  void dispose() {
    _passengerNameController.dispose();
    super.dispose();
  }

  /// Currently selected vehicle
  String _selectedVehicle = 'CPSU SAN CARLOS - L300';

  /// Currently selected starting location
  String _selectedStart = '';

  /// Currently selected destination location
  String _selectedDestination = 'Bacolod';

  /// Currently selected trip purpose
  String _selectedPurpose = 'Paper Works';

  /// Scheduled departure date and time
  DateTime _scheduledDeparture = DateTime(2027, 8, 25, 8, 24);

  /// Expected arrival date and time
  DateTime _expectedArrival = DateTime(2027, 8, 25, 18, 0);
  bool _isSaving = false;
  // ===== FORM OPTIONS - END =====

  // ===== STEP INDICATOR WIDGET - START =====
  /// Builds a step indicator circle showing current progress
  /// Used in multi-step form to show which step user is on
  Widget _stepIndicator(int index, String label) {
    final isActive = index == _currentStep;
    final isDone = index < _currentStep;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive || isDone ? green : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive || isDone ? green : const Color(0xFFB3C0BA),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive || isDone
                      ? Colors.white
                      : const Color(0xFF6A6A6A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isActive || isDone ? green : const Color(0xFF6A6A6A),
                fontWeight: isActive || isDone
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== STEP INDICATOR WIDGET - END =====

  // ===== FORM FIELD BUILDERS - START =====
  /// Builds a consistent field label for form inputs
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  /// Builds a dropdown field for selecting from predefined options
  /// Used for Vehicle, Start Location, Destination, Purpose selection
  Widget _buildTextDropDown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down, color: green),
              style: const TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a date/time field with date and time pickers
  /// Used for Scheduled Departure and Expected Arrival
  Widget _buildDateTimeField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    final dateText = _formattedDate(value);
    final timeText = _formattedTime(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A6A6A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.access_time, size: 18, color: green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== FIELD BUILDERS - END =====

  // ===== DATE/TIME HELPERS - START =====
  String _formattedDate(DateTime date) {
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

  String _formattedTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $suffix';
  }

  Future<void> _pickDateTime({
    required DateTime initialDate,
    required Function(DateTime) onPicked,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    final newDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    onPicked(newDate);
  }

  // ===== DATE/TIME HELPERS - END =====

  // ===== NAVIGATION - START =====
  void _goToNextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      _saveTrip();
    }
  }

  Future<void> _saveTrip() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      await TripService.createTrip(
        origin: _selectedStart,
        destination: _selectedDestination,
        purpose: _selectedPurpose,
        scheduledDeparture: _scheduledDeparture,
        passengers: _passengers,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Trip Ticket Ready'),
          content: const Text(
            'Your trip ticket has been reviewed successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save trip ticket.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.pop(context);
    }
  }

  // ===== NAVIGATION - END =====

  // ===== PASSENGERS SCREEN - START =====
  void _addPassengerFromInput() {
    final name = _passengerNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _passengers.add(name);
      _passengerNameController.clear();
    });

    Navigator.of(context).pop();
  }

  void _showAddPassengerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Passenger'),
          content: TextField(
            controller: _passengerNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter passenger name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _passengerNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addPassengerFromInput,
              style: ElevatedButton.styleFrom(backgroundColor: green),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPassengerCard(String passenger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              passenger,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _passengers.remove(passenger);
              });
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Remove passenger',
          ),
        ],
      ),
    );
  }
  // ===== PASSENGERS SCREEN - END =====

  // ===== REVIEW SCREEN - START =====
  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C5C5C),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== REVIEW SCREEN - END =====

  // ===== PAGE CONTENT - START =====
  Widget _buildPage() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            const SizedBox(height: 18),
            _buildTextDropDown(
              label: 'Vehicle',
              value: _selectedVehicle,
              items: _vehicles,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedVehicle = value);
                }
              },
            ),
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Destination'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedStart,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: green,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _startPlaces
                                .map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedStart = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, color: green),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedDestination,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: green,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _destinations
                                .map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedDestination = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildTextDropDown(
              label: 'Purpose',
              value: _selectedPurpose,
              items: _purposes,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPurpose = value);
                }
              },
            ),
            const SizedBox(height: 18),
            _buildDateTimeField(
              label: 'Scheduled Departure',
              value: _scheduledDeparture,
              onTap: () => _pickDateTime(
                initialDate: _scheduledDeparture,
                onPicked: (date) => setState(() => _scheduledDeparture = date),
              ),
            ),
            const SizedBox(height: 18),
            _buildDateTimeField(
              label: 'Expected Arrival',
              value: _expectedArrival,
              onTap: () => _pickDateTime(
                initialDate: _expectedArrival,
                onPicked: (date) => setState(() => _expectedArrival = date),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'List of Passengers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_passengers.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: const Text(
                  'No passengers added yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6A6A6A)),
                ),
              )
            else
              ..._passengers.map(_buildPassengerCard).toList(),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _showAddPassengerDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'ADD PASSENGER',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Please review your trip details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.2),
              ),
              child: Column(
                children: [
                  _buildReviewRow('Vehicle', _selectedVehicle),
                  Divider(color: borderColor, thickness: 1),
                  _buildReviewRow(
                    'Destination',
                    '$_selectedStart to $_selectedDestination',
                  ),
                  Divider(color: borderColor, thickness: 1),
                  _buildReviewRow('Purpose', _selectedPurpose),
                  Divider(color: borderColor, thickness: 1),
                  _buildReviewRow(
                    'Scheduled Departure',
                    '${_formattedDate(_scheduledDeparture)} ${_formattedTime(_scheduledDeparture)}',
                  ),
                  Divider(color: borderColor, thickness: 1),
                  _buildReviewRow(
                    'Expected Arrival',
                    '${_formattedDate(_expectedArrival)} ${_formattedTime(_expectedArrival)}',
                  ),
                  Divider(color: borderColor, thickness: 1),
                  _buildReviewRow('Passengers', '${_passengers.length}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  // ===== PAGE CONTENT - END =====

  // ===== MAIN BUILD - START =====
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _goToPreviousStep,
        ),
        title: const Text(
          'Create Trip Ticket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ShellAtmosphere(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            children: [
              // ===== STEP INDICATOR - START =====
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 12,
                ),
                borderRadius: 16,
                child: Row(
                  children: [
                    Expanded(child: _stepIndicator(0, 'Trip Details')),
                    Container(
                      width: 28,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentStep > 0
                            ? green
                            : const Color(0xFFDBE1DE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(child: _stepIndicator(1, 'Passengers')),
                    Container(
                      width: 28,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentStep > 1
                            ? green
                            : const Color(0xFFDBE1DE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(child: _stepIndicator(2, 'Review')),
                  ],
                ),
              ),

              // ===== STEP INDICATOR - END =====
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPage(),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ===== MAIN BUILD - END =====
}
