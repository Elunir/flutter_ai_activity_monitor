import 'package:activity_monitoring/activity_monitoring/view/activity_monitoring.dart';
import 'package:flutter/material.dart';
import 'package:activity_monitoring/activity_monitoring/service/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.initializeService();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QueryScreen(),
    );
  }
}
