import 'dart:convert';

enum AlarmMission {
  math('Математика'),
  typing('Набор текста'),
  shake('Встряхивание'),
  memory('Память'),
  puzzle('Головоломка');
  
  final String label;
  const AlarmMission(this.label);
}

enum MathLevel {
  easy('Легкий', 10, 0),
  medium('Средний', 50, 1),
  hard('Сложный', 100, 2);
  
  final String label;
  final int maxValue;
  final int complexity;
  const MathLevel(this.label, this.maxValue, this.complexity);
}

class Ringtone {
  final String id;
  final String name;
  final String url;
  final bool isLocal;
  final String? localPath;
  final int duration;
  
  Ringtone({
    required this.id,
    required this.name,
    required this.url,
    this.isLocal = false,
    this.localPath,
    this.duration = 30,
  });
  
  factory Ringtone.local(String path, String name) {
    return Ringtone(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: path,
      isLocal: true,
      localPath: path,
    );
  }
  
  factory Ringtone.fromJson(Map<String, dynamic> json) => Ringtone(
    id: json['id'],
    name: json['name'],
    url: json['url'],
    isLocal: json['isLocal'] ?? false,
    localPath: json['localPath'],
    duration: json['duration'] ?? 30,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'isLocal': isLocal,
    'localPath': localPath,
    'duration': duration,
  };
}

class Alarm {
  final String id;
  final int hour;
  final int minute;
  bool isEnabled;
  String label;
  Ringtone ringtone;
  List<int> repeatDays;
  bool isSnoozeEnabled;
  int snoozeMinutes;
  
  // Новые функции
  AlarmMission mission;
  MathLevel mathLevel;
  bool requiresTyping;
  String? typingText;
  bool requiresShake;
  int shakeCount;
  
  // Умные функции
  bool gradualVolume;
  int gradualDuration;
  bool wakeUpLight;
  bool weatherReport;
  String? weatherCity;
  bool smartWake;
  int smartWakeMinutes;
  
  // Статистика
  int timesSnoozed;
  int timesCompleted;
  DateTime? lastTriggered;
  
  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.label = 'Будильник',
    required this.ringtone,
    this.repeatDays = const [],
    this.isSnoozeEnabled = true,
    this.snoozeMinutes = 5,
    this.mission = AlarmMission.math,
    this.mathLevel = MathLevel.easy,
    this.requiresTyping = false,
    this.typingText,
    this.requiresShake = false,
    this.shakeCount = 10,
    this.gradualVolume = true,
    this.gradualDuration = 10,
    this.wakeUpLight = false,
    this.weatherReport = false,
    this.weatherCity,
    this.smartWake = false,
    this.smartWakeMinutes = 30,
    this.timesSnoozed = 0,
    this.timesCompleted = 0,
    this.lastTriggered,
  });
  
  String get timeString => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  
  String get repeatText {
    if (repeatDays.isEmpty) return 'Однократный';
    if (repeatDays.length == 7) return 'Каждый день';
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return repeatDays.map((i) => days[i]).join(', ');
  }
  
  String get missionText {
    switch (mission) {
      case AlarmMission.math:
        return 'Решить пример (${mathLevel.label})';
      case AlarmMission.typing:
        return 'Напечатать текст';
      case AlarmMission.shake:
        return 'Встряхнуть $shakeCount раз';
      case AlarmMission.memory:
        return 'Запомнить последовательность';
      case AlarmMission.puzzle:
        return 'Собрать пазл';
    }
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'isEnabled': isEnabled,
    'label': label,
    'ringtone': ringtone.toJson(),
    'repeatDays': repeatDays,
    'isSnoozeEnabled': isSnoozeEnabled,
    'snoozeMinutes': snoozeMinutes,
    'mission': mission.index,
    'mathLevel': mathLevel.index,
    'requiresTyping': requiresTyping,
    'typingText': typingText,
    'requiresShake': requiresShake,
    'shakeCount': shakeCount,
    'gradualVolume': gradualVolume,
    'gradualDuration': gradualDuration,
    'wakeUpLight': wakeUpLight,
    'weatherReport': weatherReport,
    'weatherCity': weatherCity,
    'smartWake': smartWake,
    'smartWakeMinutes': smartWakeMinutes,
    'timesSnoozed': timesSnoozed,
    'timesCompleted': timesCompleted,
    'lastTriggered': lastTriggered?.toIso8601String(),
  };
  
  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json['id'],
    hour: json['hour'],
    minute: json['minute'],
    isEnabled: json['isEnabled'],
    label: json['label'],
    ringtone: Ringtone.fromJson(json['ringtone']),
    repeatDays: List<int>.from(json['repeatDays']),
    isSnoozeEnabled: json['isSnoozeEnabled'],
    snoozeMinutes: json['snoozeMinutes'],
    mission: AlarmMission.values[json['mission']],
    mathLevel: MathLevel.values[json['mathLevel']],
    requiresTyping: json['requiresTyping'],
    typingText: json['typingText'],
    requiresShake: json['requiresShake'],
    shakeCount: json['shakeCount'] ?? 10,
    gradualVolume: json['gradualVolume'] ?? true,
    gradualDuration: json['gradualDuration'] ?? 10,
    wakeUpLight: json['wakeUpLight'] ?? false,
    weatherReport: json['weatherReport'] ?? false,
    weatherCity: json['weatherCity'],
    smartWake: json['smartWake'] ?? false,
    smartWakeMinutes: json['smartWakeMinutes'] ?? 30,
    timesSnoozed: json['timesSnoozed'] ?? 0,
    timesCompleted: json['timesCompleted'] ?? 0,
    lastTriggered: json['lastTriggered'] != null 
        ? DateTime.parse(json['lastTriggered']) 
        : null,
  );
}