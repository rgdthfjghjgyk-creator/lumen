import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:lumen/models/alarm.dart';
import 'package:lumen/screens/alarm_ring_screen.dart';
import 'package:flutter/material.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _fadeTimer;
  Timer? _alarmCheckTimer;
  Alarm? _currentAlarm;
  bool _isRinging = false;
  
  Future<void> initialize() async {
    // iOS настройки
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
      interruptionLevel: InterruptionLevel.critical,
    );
    
    const settings = InitializationSettings(iOS: iOSSettings);
    await _notifications.initialize(settings);
    
    // Запускаем проверку будильников каждую минуту
    _alarmCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAlarms();
    });
  }
  
  Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isEnabled) return;
    
    final now = DateTime.now();
    final scheduledTime = alarm.nextAlarmTime;
    
    if (scheduledTime.isAfter(now)) {
      final delay = scheduledTime.difference(now);
      
      Timer(delay, () async {
        await _triggerAlarm(alarm);
      });
      
      // Сохраняем scheduled alarm
      await _saveScheduledAlarm(alarm, scheduledTime);
    }
  }
  
  Future<void> _triggerAlarm(Alarm alarm) async {
    if (_isRinging) return;
    
    _currentAlarm = alarm;
    _isRinging = true;
    
    // Показываем экран будильника
    await _showAlarmScreen(alarm);
    
    // Воспроизводим звук
    await _playSound(alarm);
    
    // Вибрация
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [1000, 1000, 1000], repeat: 2);
    }
    
    // Отправляем уведомление
    await _sendNotification(alarm);
  }
  
  Future<void> _playSound(Alarm alarm) async {
    try {
      if (alarm.fadeInSound) {
        // Плавное увеличение громкости
        await _audioPlayer.setVolume(0.0);
        await _audioPlayer.play(AssetSource('sounds/${alarm.sound}'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        
        final stepDuration = Duration(seconds: alarm.fadeInDuration ~/ 10);
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(stepDuration);
          await _audioPlayer.setVolume(i / 10 * alarm.volume);
        }
      } else {
        await _audioPlayer.setVolume(alarm.volume);
        await _audioPlayer.play(AssetSource('sounds/${alarm.sound}'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }
  
  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
    await Vibration.cancel();
    _isRinging = false;
    _currentAlarm = null;
    _fadeTimer?.cancel();
  }
  
  Future<void> snoozeAlarm(Alarm alarm) async {
    await stopAlarm();
    
    final snoozeTime = DateTime.now().add(Duration(minutes: alarm.snoozeMinutes));
    
    Timer(snoozeTime.difference(DateTime.now()), () async {
      await _triggerAlarm(alarm);
    });
    
    await _sendSnoozeNotification(alarm);
  }
  
  Future<void> _showAlarmScreen(Alarm alarm) async {
    // TODO: Показать экран с возможностью выключения
    // Используйте navigator key для показа поверх всего
  }
  
  Future<void> _sendNotification(Alarm alarm) async {
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.critical,
    );
    
    const details = NotificationDetails(iOS: iOSDetails);
    
    await _notifications.show(
      int.parse(alarm.id),
      '⏰ ${alarm.label}',
      'Пора просыпаться! ${alarm.timeString}',
      details,
    );
  }
  
  Future<void> _sendSnoozeNotification(Alarm alarm) async {
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false,
      presentBadge: true,
    );
    
    const details = NotificationDetails(iOS: iOSDetails);
    
    await _notifications.show(
      int.parse(alarm.id) + 1000,
      '😴 Отложено',
      'Будильник сработает через ${alarm.snoozeMinutes} минут',
      details,
    );
  }
  
  void _checkAlarms() {
    // TODO: Проверить все активные будильники
  }
  
  Future<void> _saveScheduledAlarm(Alarm alarm, DateTime time) async {
    // TODO: Сохранять запланированные будильники в БД
  }
  
  void dispose() {
    _alarmCheckTimer?.cancel();
    _fadeTimer?.cancel();
    _audioPlayer.dispose();
  }
}