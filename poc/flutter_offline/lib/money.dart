String? parseCopCents(String input, {bool allowZero = false}) {
  final match = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$').firstMatch(input.trim());
  if (match == null) return null;
  final whole = int.tryParse(match.group(1)!);
  if (whole == null || whole > 90000000000000) return null;
  final decimals = (match.group(2) ?? '').padRight(2, '0');
  final cents = whole * 100 + (decimals.isEmpty ? 0 : int.parse(decimals));
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
