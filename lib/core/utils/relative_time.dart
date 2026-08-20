abstract final class RelativeTime {
  static const chinaOffset = Duration(hours: 8);

  static String format(DateTime value, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toUtc();
    final target = value.toUtc();
    final delta = current.difference(target);
    if (delta.isNegative) return '刚刚';
    if (delta.inSeconds < 60) return '${delta.inSeconds} 秒前';
    if (delta.inMinutes < 60) return '${delta.inMinutes} 分钟前';
    if (delta.inHours < 24)
      return '${delta.inHours} 小时 ${delta.inMinutes % 60} 分钟前';
    if (delta.inDays < 30) return '${delta.inDays} 天 ${delta.inHours % 24} 小时前';
    if (delta.inDays < 365) return '${delta.inDays ~/ 30} 个月前';
    return '${delta.inDays ~/ 365} 年前';
  }

  static String chinaDateTime(DateTime value) {
    final china = value.toUtc().add(chinaOffset);
    return '${china.year.toString().padLeft(4, '0')}-${china.month.toString().padLeft(2, '0')}-${china.day.toString().padLeft(2, '0')} ${china.hour.toString().padLeft(2, '0')}:${china.minute.toString().padLeft(2, '0')}:${china.second.toString().padLeft(2, '0')}';
  }

  static String chinaCardDate(DateTime value, {DateTime? now}) {
    final delta = (now ?? DateTime.now()).toUtc().difference(value.toUtc());
    if (!delta.isNegative && delta.inDays < 2) return format(value, now: now);
    return chinaDateTime(value);
  }
}
