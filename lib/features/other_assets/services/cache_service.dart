import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _lastFetchPrefix = 'last_fetch_';

  static Future<bool> shouldFetchData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getInt('$_lastFetchPrefix$key');

    if (lastFetchTimestamp == null) return true;

    final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(
      lastFetchTimestamp,
    );
    final today = DateTime.now();

    // Check if last fetch was today
    return !(today.year == lastFetchDate.year &&
        today.month == lastFetchDate.month &&
        today.day == lastFetchDate.day);
  }

  static Future<void> markDataFetched(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_lastFetchPrefix$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
