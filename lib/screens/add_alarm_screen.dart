import 'package:flutter/material.dart';
import 'package:lumen/models/alarm.dart';

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
  late String _sound;
  late List<int> _repeatDays;
  late bool _snoozeEnabled;
  
  final List<String> _sounds = ['alarm.mp3', 'gentle_alarm.mp3', 'morning_alarm.mp3'];
  final List<String> _soundNames = ['Классический', 'Нежный', 'Мелодичный'];

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _hour = widget.alarm!.hour;
      _minute = widget.alarm!.minute;
      _label = widget.alarm!.label;
      _sound = widget.alarm!.sound;
      _repeatDays = List.from(widget.alarm!.repeatDays);
      _snoozeEnabled = widget.alarm!.isSnoozeEnabled;
    } else {
      final now = TimeOfDay.now();
      _hour = now.hour + 1 > 23 ? 0 : now.hour + 1;
      _minute = 0;
      _label = 'Будильник';
      _sound = 'alarm.mp3';
      _repeatDays = [];
      _snoozeEnabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Новый будильник' : 'Редактирование'),
      ),
      body: Column(
        children: [
          // Time picker
          SizedBox(
            height: 300,
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
          
          Expanded(
            child: ListView(
              children: [
                _buildTextField(
                  icon: Icons.label,
                  title: 'Название',
                  value: _label,
                  onTap: () => _showLabelDialog(),
                ),
                _buildPicker(
                  icon: Icons.music_note,
                  title: 'Звук',
                  value: _soundNames[_sounds.indexOf(_sound)],
                  onTap: () => _showSoundDialog(),
                ),
                _buildPicker(
                  icon: Icons.repeat,
                  title: 'Повтор',
                  value: _getRepeatText(),
                  onTap: () => _showRepeatDialog(),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.alarm_snooze, color: Color(0xFFFF9F4A)),
                  title: const Text('Отложить'),
                  value: _snoozeEnabled,
                  onChanged: (value) => setState(() => _snoozeEnabled = value),
                  activeColor: const Color(0xFFFF9F4A),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F4A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
      leading: Icon(icon, color: const Color(0xFFFF9F4A)),
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
      leading: Icon(icon, color: const Color(0xFFFF9F4A)),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLabelDialog() {
    final controller = TextEditingController(text: _label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Название будильника'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Введите название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _label = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showSoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите звук'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_sounds.length, (index) {
            return RadioListTile<String>(
              title: Text(_soundNames[index]),
              value: _sounds[index],
              groupValue: _sound,
              onChanged: (value) {
                setState(() => _sound = value!);
                Navigator.pop(context);
              },
            );
          }),
        ),
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
      sound: _sound,
      repeatDays: _repeatDays,
      isSnoozeEnabled: _snoozeEnabled,
    );
    Navigator.pop(context, alarm);
  }
}

// Добавьте CupertinoTimerPicker импорт
import 'package:flutter/cupertino.dart';