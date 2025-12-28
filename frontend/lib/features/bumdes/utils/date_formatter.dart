/// Indonesian date formatting utilities
/// Used across bumdes screens for consistent date display
class BumdesDateFormatter {
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
  /// Returns '-' if parsing fails
  static String formatDateFromIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      return formatDateShort(date);
    } catch (e) {
      return '-';
    }
  }

  /// Format date to full Indonesian format: "DD MonthName YYYY"
  /// Example: "25 Desember 2024"
  static String formatDateFull(DateTime date) {
    return "${date.day} ${getMonthFullName(date.month)} ${date.year}";
  }

  /// Format date/time to Indonesian format
  static String formatDateTime(DateTime dateTime) {
    return "${formatDateShort(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
