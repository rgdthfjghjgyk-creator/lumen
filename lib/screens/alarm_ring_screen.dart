import 'package:flutter/material.dart';
import 'package:lumen/models/alarm.dart';
import 'package:lumen/services/alarm_service.dart';
import 'package:lumen/widgets/math_challenge.dart';
import 'package:lumen/widgets/typing_challenge.dart';
import 'package:lumen/widgets/shake_challenge.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmRingScreen extends StatefulWidget {
  final Alarm alarm;
  const AlarmRingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  final AlarmService _alarmService = AlarmService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isStopping = false;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideController.forward();
    
    // Воспроизводим мелодию
    _playRingtone();
  }
  
  Future<void> _playRingtone() async {
    if (widget.alarm.ringtone.isLocal && widget.alarm.ringtone.localPath != null) {
      await _audioPlayer.play(DeviceFileSource(widget.alarm.ringtone.localPath!));
    } else {
      await _audioPlayer.play(UrlSource(widget.alarm.ringtone.url));
    }
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Плавное увеличение громкости
    if (widget.alarm.gradualVolume) {
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(Duration(seconds: widget.alarm.gradualDuration ~/ 10));
        await _audioPlayer.setVolume(i / 10);
      }
    }
  }
  
  void _stopAlarm() async {
    if (_isStopping) return;
    _isStopping = true;
    
    await _audioPlayer.stop();
    await _alarmService.stopAlarm();
    
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
  
  void _snooze() async {
    await _audioPlayer.stop();
    await _alarmService.snoozeAlarm(widget.alarm);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Фон с анимацией
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withOpacity(0.3 * _pulseController.value),
                        Colors.black,
                      ],
                      radius: 1.5,
                    ),
                  ),
                );
              },
            ),
            
            // Основной контент
            Column(
              children: [
                const Spacer(),
                
                // Иконка будильника
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  )),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + _pulseController.value * 0.1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.5),
                                blurRadius: 30 * _pulseController.value,
                                spreadRadius: 10 * _pulseController.value,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.alarm,
                            size: 100,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Время
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  )),
                  child: Column(
                    children: [
                      Text(
                        widget.alarm.timeString,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.alarm.label,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Вызов миссии
                if (!_isStopping)
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOut,
                    )),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildChallenge(),
                    ),
                  ),
                
                // Кнопки управления
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (widget.alarm.isSnoozeEnabled)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ElevatedButton(
                              onPressed: _snooze,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade800,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.snooze, color: Colors.white),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Отложить (${widget.alarm.snoozeMinutes} мин)',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _stopAlarm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.close, color: Colors.white),
                              SizedBox(height: 5),
                              Text('Выключить', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChallenge() {
    switch (widget.alarm.mission) {
      case AlarmMission.math:
        return MathChallengeWidget(
          level: widget.alarm.mathLevel,
          onSuccess: _stopAlarm,
        );
      case AlarmMission.typing:
        return TypingChallengeWidget(onSuccess: _stopAlarm);
      case AlarmMission.shake:
        return ShakeChallengeWidget(
          requiredShakes: widget.alarm.shakeCount,
          onSuccess: _stopAlarm,
        );
      default:
        return Container();
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}