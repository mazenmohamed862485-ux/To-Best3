// lib/core/utils/date_helper.dart
class DateHelper {
  DateHelper._();

  static String toDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  static String toMonthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}';

  static DateTime fromDateKey(String key) {
    final p = key.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  static String today()     => toDateKey(DateTime.now());
  static String thisMonth() => toMonthKey(DateTime.now());

  static String formatAr(DateTime d) {
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];
    return '${d.day} ${months[d.month-1]} ${d.year}';
  }

  static String formatEn(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month-1]} ${d.day}, ${d.year}';
  }

  static String format(DateTime d, {bool arabic = true}) =>
      arabic ? formatAr(d) : formatEn(d);

  static String timeAgo(DateTime past, {bool arabic = true}) {
    final diff = DateTime.now().difference(past);
    if (diff.inDays > 0) {
      return arabic ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return arabic ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return arabic ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
    } else {
      return arabic ? 'الآن' : 'just now';
    }
  }

  static List<DateTime> daysInMonth(int year, int month) {
    final last = DateTime(year, month + 1, 0);
    return List.generate(last.day, (i) => DateTime(year, month, i + 1));
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
