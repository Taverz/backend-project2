extension DateTimeX on DateTime {
  String toRelativeString() {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return '${diff.inSeconds}с';
    if (diff.inMinutes < 60) return '${diff.inMinutes}м';
    if (diff.inHours < 24) return '${diff.inHours}ч';
    if (diff.inDays < 7) return '${diff.inDays}д';
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.${year.toString().substring(2)}';
  }
}
