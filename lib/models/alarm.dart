enum AlarmDifficulty {
  easy('Легко', 1),
  medium('Средне', 2),
  hard('Сложно', 3);
  
  final String label;
  final int value;
  const AlarmDifficulty(this.label, this.value);
}

enum AlarmMathOperation {
  addition('+', (a, b) => a + b),
  subtraction('-', (a, b) => a - b),
  multiplication('×', (a, b) => a * b);
  
  final String symbol;
  final int Function(int a, int b) calculate;
  const AlarmMathOperation(this.symbol, this.calculate);
}

class Alarm {
  final String id;
  final int hour;
  final int minute;
  bool isEnabled;
  String label;
  String sound;
  List<int> repeatDays;
  bool isSnoozeEnabled;
  int snoozeMinutes;
  bool requiresMath;
  AlarmDifficulty mathDifficulty;
  bool requiresShake;
  int shakeCount;
  bool fadeInSound;
  int fadeInDuration; // seconds
  double volume;
  String? weatherCity;
  bool showWeather;
  
  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.label = 'Будильник',
    this.sound = 'alarm_default.mp3',
    this.repeatDays = const [],
    this.isSnoozeEnabled = true,
    this.snoozeMinutes = 5,
    this.requiresMath = false,
    this.mathDifficulty = AlarmDifficulty.medium,
    this.requiresShake = false,
    this.shakeCount = 10,
    this.fadeInSound = true,
    this.fadeInDuration = 10,
    this.volume = 1.0,
    this.weatherCity,
    this.showWeather = false,
  });
  
  String get timeString => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  
  String get repeatText {
    if (repeatDays.isEmpty) return 'Однократный';
    if (repeatDays.length == 7) return 'Каждый день';
    
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return repeatDays.map((i) => days[i]).join(', ');
  }
  
  DateTime get nextAlarmTime {
    final now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    
    if (repeatDays.isNotEmpty) {
      while (!repeatDays.contains(next.weekday - 1)) {
        next = next.add(const Duration(days: 1));
      }
    }
    
    return next;
  }
  
  Duration get timeUntilAlarm => nextAlarmTime.difference(DateTime.now());
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'isEnabled': isEnabled,
    'label': label,
    'sound': sound,
    'repeatDays': repeatDays,
    'isSnoozeEnabled': isSnoozeEnabled,
    'snoozeMinutes': snoozeMinutes,
    'requiresMath': requiresMath,
    'mathDifficulty': mathDifficulty.value,
    'requiresShake': requiresShake,
    'shakeCount': shakeCount,
    'fadeInSound': fadeInSound,
    'fadeInDuration': fadeInDuration,
    'volume': volume,
    'weatherCity': weatherCity,
    'showWeather': showWeather,
  };
  
  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'],
    hour: json['hour'],
    minute: json['minute'],
    isEnabled: json['isEnabled'],
    label: json['label'],
    sound: json['sound'],
    repeatDays: List<int>.from(json['repeatDays']),
    isSnoozeEnabled: json['isSnoozeEnabled'],
    snoozeMinutes: json['snoozeMinutes'],
    requiresMath: json['requiresMath'] ?? false,
    mathDifficulty: AlarmDifficulty.values.firstWhere(
      (d) => d.value == json['mathDifficulty'],
      orElse: () => AlarmDifficulty.medium,
    ),
    requiresShake: json['requiresShake'] ?? false,
    shakeCount: json['shakeCount'] ?? 10,
    fadeInSound: json['fadeInSound'] ?? true,
    fadeInDuration: json['fadeInDuration'] ?? 10,
    volume: json['volume']?.toDouble() ?? 1.0,
    weatherCity: json['weatherCity'],
    showWeather: json['showWeather'] ?? false,
  );
}