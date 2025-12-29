/// Indonesian date formatting utilities
/// Centralized date formatting for the entire application
class DateFormatter {
  /// Get short month name in Indonesian (Jan, Feb, Mar, etc.)
  static String getMonthShortName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    if (month < 1 || month > 12) return "";
    return months[month];
  }

  /// Get full month name in Indonesian (Januari, Februari, etc.)
  static String getMonthFullName(int month) {
    const months = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    if (month < 1 || month > 12) return "";
    return months[month];
  }

  /// Format date to Indonesian format: "DD MMM YYYY"
  /// Example: "25 Des 2024"
  static String formatDateShort(DateTime date) {
    return "${date.day} ${getMonthShortName(date.month)} ${date.year}";
  }

  /// Format date from ISO string to Indonesian format
  /// Returns original string if parsing fails
  static String formatDateFromIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      return formatDateShort(date);
    } catch (e) {
      return isoString;
    }
  }

  /// Format date/time to Indonesian format: "DD MMM, HH:MM"
  /// Example: "27 Nov, 14:30"
  static String formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day} ${getMonthShortName(dateTime.month)}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// Format date to full Indonesian format: "DD MonthName YYYY"
  /// Example: "25 Desember 2024"
  static String formatDateFull(DateTime date) {
    return "${date.day} ${getMonthFullName(date.month)} ${date.year}";
  }

  /// Calculate time remaining from deadline string
  /// Returns formatted string like "23j 45m 30d" or "Kedaluwarsa"
  static String calculateTimeLeft(String deadlineStr) {
    try {
      final deadline = DateTime.parse(deadlineStr);
      final now = DateTime.now();
      final difference = deadline.difference(now);

      if (difference.isNegative) {
        return 'Kedaluwarsa';
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      if (hours > 0) {
        return '${hours}j ${minutes}m ${seconds}d';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds}d';
      } else {
        return '${seconds}d';
      }
    } catch (e) {
      return '-';
    }
  }

  /// Format date only (no time) from ISO string
  /// Example: "30 Nov 2025"
  static String formatDateOnly(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${getMonthShortName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
