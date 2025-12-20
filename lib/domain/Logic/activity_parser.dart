class ActivityParser {
  static double parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static double parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 0;

    try {
      final parts = timeStr.split(':');

      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return minutes + (seconds / 60);
      } else if (parts.length == 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = int.tryParse(parts[2]) ?? 0;
        return (hours * 60) + minutes + (seconds / 60);
      } else {
        return double.tryParse(timeStr) ?? 0;
      }
    } catch (e) {
      print('Error parsing time: $e');
      return 0;
    }
  }
}