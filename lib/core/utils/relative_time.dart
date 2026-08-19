abstract final class RelativeTime {
  static String format(DateTime value, {DateTime? now}) {
    final current = (now ?? DateTime.now()).toUtc();
    final target = value.toUtc();
    final delta = current.difference(target);
    if (delta.isNegative) return '刚刚';
    if (delta.inSeconds < 60) return '${delta.inSeconds} 秒前';
    if (delta.inMinutes < 60) return '${delta.inMinutes} 分钟前';
    if (delta.inHours < 24) return '${delta.inHours} 小时 ${delta.inMinutes % 60} 分钟前';
    if (delta.inDays < 30) return '${delta.inDays} 天 ${delta.inHours % 24} 小时前';
    if (delta.inDays < 365) return '${delta.inDays ~/ 30} 个月前';
    return '${delta.inDays ~/ 365} 年前';
  }
}
