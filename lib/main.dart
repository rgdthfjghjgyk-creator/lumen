import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lumen/screens/home_screen.dart';
import 'package:lumen/services/notification_service.dart';
import 'package:lumen/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Запрашиваем все необходимые разрешения для iOS
  await _requestPermissions();
  
  // Инициализируем сервис уведомлений
  await NotificationService.initialize();
  
  runApp(const LumenApp());
}

Future<void> _requestPermissions() async {
  // Запрашиваем разрешение на уведомления
  await Permission.notification.request();
  
  // Для критических уведомлений (важно для будильника на iOS)
  if (await Permission.notification.isGranted) {
    // Разрешение получено
    debugPrint('✅ Уведомления разрешены');
  } else {
    debugPrint('⚠️ Уведомления запрещены');
  }
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumen - Будильник',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}