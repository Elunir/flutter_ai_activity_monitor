import 'package:flutter/services.dart';
import 'database_service.dart';

class UsageStatsService {
  static const MethodChannel _channel = MethodChannel('app_usage_channel');

  /// Tracks and stores app usage stats periodically
  static Future<void> trackAppUsage() async {
    try {
      final List<dynamic> usageStats =
          await _channel.invokeMethod<List<dynamic>>('getUsageStats') ?? [];

      for (var stat in usageStats) {
        final packageName = stat['packageName'];
        final duration = stat['totalTimeInForeground'];

        if (packageName != null && duration != null) {
          await DatabaseService.instance.insertUsageData(
              packageName.toString(), int.parse(duration.toString()));
        }
      }
    } on PlatformException catch (e) {
      print('⚠️ Failed to get usage stats: ${e.message}');
    }
  }

  /// Retrieves app usage stats from SQLite, filterable by day, month, or year.
  static Future<List<Map<String, dynamic>>> getUsageData(
      {String filterType = "day"}) async {
    return await DatabaseService.instance.fetchUsageData(filterType);
  }
}
