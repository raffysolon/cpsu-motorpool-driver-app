class PhilippineTime {
  static const _months = [
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

  static DateTime parse(String? value) {
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) return DateTime.now();
    return parsed.toUtc().add(const Duration(hours: 8));
  }

  static DateTime now() => parse(DateTime.now().toUtc().toIso8601String());

  static String format(String? value, {String separator = '\n'}) {
    final date = parse(value);
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${_months[date.month - 1]} ${date.day}, ${date.year}'
        '$separator$hour:$minute $period PHT';
  }
}
