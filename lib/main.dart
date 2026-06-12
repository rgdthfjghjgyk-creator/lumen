import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lumen/screens/home_screen.dart';
import 'package:lumen/services/notification_service.dart';
import 'package:lumen/services/alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Запрос разрешений
  await _requestPermissions();
  
  // Инициализация сервисов
  await NotificationService.initialize();
  await AlarmService().initialize();
  
  runApp(const LumenApp());
}

Future<void> _requestPermissions() async {
  await Permission.notification.request();
  await Permission.storage.request();
  await Permission.ignoreBatteryOptimizations.request();
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orange,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}