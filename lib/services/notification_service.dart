import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumen/models/alarm.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static Timer? _alarmTimer;
  
  static Future<void> initialize() async {
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    
    const settings = InitializationSettings(iOS: iOSSettings);
    await _notifications.initialize(settings);
  }
  
  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isEnabled) return;
    
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year, now.month, now.day, alarm.hour, alarm.minute
    );
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    if (alarm.repeatDays.isNotEmpty && !alarm.repeatDays.contains(now.weekday - 1)) {
      while (!alarm.repeatDays.contains(scheduledTime.weekday - 1)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }
    
    final difference = scheduledTime.difference(now);
    
    if (difference.inSeconds > 0) {
      Future.delayed(difference, () async {
        await showAlarm(alarm);
      });
    }
  }
  
  static Future<void> showAlarm(Alarm alarm) async {
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      sound: 'alarm.mp3',
      interruptionLevel: InterruptionLevel.critical,
    );
    
    const details = NotificationDetails(iOS: iOSDetails);
    
    await _notifications.show(
      int.parse(alarm.id),
      '⏰ ${alarm.label}',
      'Пора просыпаться! ${alarm.timeString}',
      details,
    );
    
    await _playAlarmSound(alarm.sound);
  }
  
  static Future<void> _playAlarmSound(String sound) async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/$sound'));
    } catch (e) {
      debugPrint('Ошибка воспроизведения звука: $e');
    }
  }
  
  static Future<void> stopAlarm() async {
    await _audioPlayer.stop();
    _alarmTimer?.cancel();
  }
  
  static Future<void> cancelAlarm(String id) async {
    await _notifications.cancel(int.parse(id));
  }
}