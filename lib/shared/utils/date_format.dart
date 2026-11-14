const _months = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

/// İlan detayındaki tam tarih: "30 Eki 2026, 14:05" (yerel saat).
String formatDateTime(DateTime date) {
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day} ${_months[d.month - 1]} ${d.year}, '
      '${two(d.hour)}:${two(d.minute)}';
}

/// İlan kartlarındaki göreli tarih: "Az önce", "5 dk önce", "3 saat önce",
/// "Dün", "4 gün önce"; bir haftadan eskiyse "12 Eki" (başka yılsa "12 Eki 2025").
/// [now] testler için verilebilir.
String formatRelative(DateTime date, {DateTime? now}) {
  final local = date.toLocal();
  final current = (now ?? DateTime.now()).toLocal();
  final diff = current.difference(local);

  if (diff.inMinutes < 1) return 'Az önce';
  if (diff.inHours < 1) return '${diff.inMinutes} dk önce';

  final days = DateTime(
    current.year,
    current.month,
    current.day,
  ).difference(DateTime(local.year, local.month, local.day)).inDays;
  if (days == 0) return '${diff.inHours} saat önce';
  if (days == 1) return 'Dün';
  if (days < 7) return '$days gün önce';

  final dayMonth = '${local.day} ${_months[local.month - 1]}';
  return local.year == current.year ? dayMonth : '$dayMonth ${local.year}';
}
