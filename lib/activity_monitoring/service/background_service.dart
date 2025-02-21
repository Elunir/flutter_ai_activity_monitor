import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'usage_service.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'AI Assistant Running',
        initialNotificationContent: 'Tracking app usage...',
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        autoStart: true,
      ),
    );

    await service.startService();
  }

  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      await service.setAsForegroundService();
    }
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      await UsageStatsService.trackAppUsage();
    });
  }
}
