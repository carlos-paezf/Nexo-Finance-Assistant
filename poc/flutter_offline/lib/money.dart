String? parseCopCents(String input, {bool allowZero = false}) {
  final match = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$').firstMatch(input.trim());
  if (match == null) return null;
  final decimals = (match.group(2) ?? '').padRight(2, '0');
  final cents = BigInt.parse(match.group(1)!) * BigInt.from(100) +
      BigInt.parse(decimals.isEmpty ? '0' : decimals);
  if (cents > BigInt.parse('9223372036854775807')) return null;
  return cents == 0 && !allowZero ? null : '$cents';
}

String formatCop(int cents) {
  final negative = cents < 0;
  final absolute = cents.abs();
  final digits = (absolute ~/ 100).toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${negative ? '-' : ''}\$$grouped,${(absolute % 100).toString().padLeft(2, '0')}';
}
