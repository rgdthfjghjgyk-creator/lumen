import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lumen/models/alarm.dart';
import 'package:lumen/services/ringtone_service.dart';

class AddAlarmScreen extends StatefulWidget {
  final Alarm? alarm;
  const AddAlarmScreen({super.key, this.alarm});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late int _hour;
  late int _minute;
  late String _label;
  late Ringtone _ringtone;
  late List<int> _repeatDays;
  late bool _snoozeEnabled;
  late int _snoozeMinutes;
  late AlarmMission _mission;
  late MathLevel _mathLevel;
  late bool _requiresTyping;
  late bool _requiresShake;
  late int _shakeCount;
  late bool _gradualVolume;
  late int _gradualDuration;
  late bool _weatherReport;
  late bool _smartWake;
  late int _smartWakeMinutes;
  
  final RingtoneService _ringtoneService = RingtoneService();
  List<Ringtone> _availableRingtones = [];
  
  @override
  void initState() {
    super.initState();
    _loadRingtones();
    
    if (widget.alarm != null) {
      _hour = widget.alarm!.hour;
      _minute = widget.alarm!.minute;
      _label = widget.alarm!.label;
      _ringtone = widget.alarm!.ringtone;
      _repeatDays = List.from(widget.alarm!.repeatDays);
      _snoozeEnabled = widget.alarm!.isSnoozeEnabled;
      _snoozeMinutes = widget.alarm!.snoozeMinutes;
      _mission = widget.alarm!.mission;
      _mathLevel = widget.alarm!.mathLevel;
      _requiresTyping = widget.alarm!.requiresTyping;
      _requiresShake = widget.alarm!.requiresShake;
      _shakeCount = widget.alarm!.shakeCount;
      _gradualVolume = widget.alarm!.gradualVolume;
      _gradualDuration = widget.alarm!.gradualDuration;
      _weatherReport = widget.alarm!.weatherReport;
      _smartWake = widget.alarm!.smartWake;
      _smartWakeMinutes = widget.alarm!.smartWakeMinutes;
    } else {
      final now = TimeOfDay.now();
      _hour = now.hour + 1 > 23 ? 0 : now.hour + 1;
      _minute = 0;
      _label = 'Будильник';
      _ringtone = RingtoneService().defaultRingtones.first;
      _repeatDays = [];
      _snoozeEnabled = true;
      _snoozeMinutes = 5;
      _mission = AlarmMission.math;
      _mathLevel = MathLevel.easy;
      _requiresTyping = false;
      _requiresShake = false;
      _shakeCount = 10;
      _gradualVolume = true;
      _gradualDuration = 10;
      _weatherReport = false;
      _smartWake = false;
      _smartWakeMinutes = 30;
    }
  }
  
  Future<void> _loadRingtones() async {
    final ringtones = await _ringtoneService.getOnlineRingtones();
    setState(() {
      _availableRingtones = [..._ringtoneService.defaultRingtones, ...ringtones];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Новый будильник' : 'Редактирование'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Сохранить', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Время
            SizedBox(
              height: 250,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(hours: _hour, minutes: _minute),
                onTimerDurationChanged: (duration) {
                  setState(() {
                    _hour = duration.inHours;
                    _minute = duration.inMinutes.remainder(60);
                  });
                },
              ),
            ),
            
            // Настройки
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    icon: Icons.label,
                    title: 'Название',
                    value: _label,
                    onTap: () => _showLabelDialog(),
                  ),
                  _buildDivider(),
                  _buildPicker(
                    icon: Icons.music_note,
                    title: 'Мелодия',
                    value: _ringtone.name,
                    onTap: () => _showRingtoneDialog(),
                  ),
                  _buildDivider(),
                  _buildPicker(
                    icon: Icons.repeat,
                    title: 'Повтор',
                    value: _getRepeatText(),
                    onTap: () => _showRepeatDialog(),
                  ),
                ],
              ),
            ),
            
            // Расширенные настройки
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader('🎯 Отключение будильника'),
                  _buildPicker(
                    icon: Icons.psychology,
                    title: 'Миссия',
                    value: _mission.label,
                    onTap: () => _showMissionDialog(),
                  ),
                  if (_mission == AlarmMission.math) ...[
                    _buildDivider(),
                    _buildPicker(
                      icon: Icons.calculate,
                      title: 'Сложность',
                      value: _mathLevel.label,
                      onTap: () => _showMathLevelDialog(),
                    ),
                  ],
                  if (_mission == AlarmMission.shake) ...[
                    _buildDivider(),
                    _buildSlider(
                      icon: Icons.shake,
                      title: 'Количество встряхиваний',
                      value: _shakeCount,
                      min: 5,
                      max: 50,
                      onChanged: (v) => setState(() => _shakeCount = v),
                    ),
                  ],
                ],
              ),
            ),
            
            // Умные функции
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader('🧠 Умные функции'),
                  _buildSwitch(
                    icon: Icons.volume_up,
                    title: 'Плавное увеличение громкости',
                    value: _gradualVolume,
                    onChanged: (v) => setState(() => _gradualVolume = v),
                  ),
                  if (_gradualVolume) ...[
                    _buildDivider(),
                    _buildSlider(
                      icon: Icons.timer,
                      title: 'Длительность (сек)',
                      value: _gradualDuration,
                      min: 5,
                      max: 30,
                      onChanged: (v) => setState(() => _gradualDuration = v),
                    ),
                  ],
                  _buildDivider(),
                  _buildSwitch(
                    icon: Icons.wb_sunny,
                    title: 'Умное пробуждение',
                    subtitle: 'Будильник сработает за X минут до времени',
                    value: _smartWake,
                    onChanged: (v) => setState(() => _smartWake = v),
                  ),
                  if (_smartWake) ...[
                    _buildDivider(),
                    _buildSlider(
                      icon: Icons.access_time,
                      title: 'За сколько минут',
                      value: _smartWakeMinutes,
                      min: 5,
                      max: 60,
                      onChanged: (v) => setState(() => _smartWakeMinutes = v),
                    ),
                  ],
                  _buildDivider(),
                  _buildSwitch(
                    icon: Icons.cloud,
                    title: 'Прогноз погоды',
                    subtitle: 'Показывать погоду на экране будильника',
                    value: _weatherReport,
                    onChanged: (v) => setState(() => _weatherReport = v),
                  ),
                ],
              ),
            ),
            
            // Откладывание
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSwitch(
                    icon: Icons.snooze,
                    title: 'Отложить',
                    value: _snoozeEnabled,
                    onChanged: (v) => setState(() => _snoozeEnabled = v),
                  ),
                  if (_snoozeEnabled) ...[
                    _buildDivider(),
                    _buildSlider(
                      icon: Icons.timer,
                      title: 'Интервал (минут)',
                      value: _snoozeMinutes,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setState(() => _snoozeMinutes = v),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Widget _buildPicker({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Widget _buildSwitch({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.orange),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange,
    );
  }
  
  Widget _buildSlider({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Text(title),
              const Spacer(),
              Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.orange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade800, height: 1);
  }
  
  void _showLabelDialog() {
    final controller = TextEditingController(text: _label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Название'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Введите название'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              setState(() => _label = controller.text.isEmpty ? 'Будильник' : controller.text);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
  
  void _showRingtoneDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Выберите мелодию', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ..._availableRingtones.map((ringtone) => ListTile(
            leading: Icon(Icons.music_note, color: _ringtone.id == ringtone.id ? Colors.orange : Colors.white),
            title: Text(ringtone.name),
            trailing: _ringtone.id == ringtone.id ? const Icon(Icons.check, color: Colors.orange) : null,
            onTap: () {
              setState(() => _ringtone = ringtone);
              Navigator.pop(context);
            },
          )),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Добавить свою мелодию'),
            onTap: () async {
              Navigator.pop(context);
              final newRingtone = await _ringtoneService.pickLocalRingtone();
              if (newRingtone != null) {
                setState(() {
                  _availableRingtones.add(newRingtone);
                  _ringtone = newRingtone;
                });
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  void _showRepeatDialog() {
    List<bool> selected = List.generate(7, (i) => _repeatDays.contains(i));
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Дни повторения'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (index) {
                return CheckboxListTile(
                  title: Text(days[index]),
                  value: selected[index],
                  onChanged: (value) {
                    setStateDialog(() {
                      selected[index] = value ?? false;
                    });
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _repeatDays = [];
                    for (int i = 0; i < selected.length; i++) {
                      if (selected[i]) _repeatDays.add(i);
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showMissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите миссию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AlarmMission.values.map((mission) {
            return RadioListTile<AlarmMission>(
              title: Text(mission.label),
              value: mission,
              groupValue: _mission,
              onChanged: (value) {
                setState(() => _mission = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showMathLevelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сложность математики'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MathLevel.values.map((level) {
            return RadioListTile<MathLevel>(
              title: Text(level.label),
              value: level,
              groupValue: _mathLevel,
              onChanged: (value) {
                setState(() => _mathLevel = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  String _getRepeatText() {
    if (_repeatDays.isEmpty) return 'Никогда';
    if (_repeatDays.length == 7) return 'Каждый день';
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return _repeatDays.map((i) => days[i]).join(', ');
  }
  
  void _save() {
    final alarm = Alarm(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      hour: _hour,
      minute: _minute,
      label: _label,
      ringtone: _ringtone,
      repeatDays: _repeatDays,
      isSnoozeEnabled: _snoozeEnabled,
      snoozeMinutes: _snoozeMinutes,
      mission: _mission,
      mathLevel: _mathLevel,
      requiresTyping: _requiresTyping,
      requiresShake: _requiresShake,
      shakeCount: _shakeCount,
      gradualVolume: _gradualVolume,
      gradualDuration: _gradualDuration,
      weatherReport: _weatherReport,
      smartWake: _smartWake,
      smartWakeMinutes: _smartWakeMinutes,
    );
    Navigator.pop(context, alarm);
  }
}