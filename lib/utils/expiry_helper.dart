
bool isItemExpired(Map<String, dynamic> item) {
  final category = item['category']?.toString().toLowerCase();
  if (category != 'food') return false;

  final raw = item['expiryDate'];
  if (raw == null || raw.toString().isEmpty) return false;

  try {
    final expiry = DateTime.parse(raw.toString());
    final now = DateTime.now();

    final expiryDateOnly = DateTime(expiry.year, expiry.month, expiry.day);
    final todayOnly = DateTime(now.year, now.month, now.day);

    return expiryDateOnly.isBefore(todayOnly);
  } catch (_) {
    return false;
  }
}