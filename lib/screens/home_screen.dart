import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumen/models/alarm.dart';
import 'package:lumen/screens/add_alarm_screen.dart';
import 'package:lumen/services/notification_service.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Alarm> _alarms = [];
  String _greeting = 'Доброе утро';

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _updateGreeting();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Доброе утро ☀️';
      } else if (hour < 17) {
        _greeting = 'Добрый день 🌤️';
      } else {
        _greeting = 'Добрый вечер 🌙';
      }
    });
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList('alarms') ?? [];
    
    setState(() {
      _alarms = alarmsJson
          .map((json) => Alarm.fromJson(jsonDecode(json)))
          .toList();
      _alarms.sort((a, b) => a.hour.compareTo(b.hour));
    });
    
    // Перепланируем все активные будильники
    for (var alarm in _alarms) {
      if (alarm.isEnabled) {
        await NotificationService.scheduleAlarm(alarm);
      }
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = _alarms
        .map((alarm) => jsonEncode(alarm.toJson()))
        .toList();
    await prefs.setStringList('alarms', alarmsJson);
  }

  Future<void> _addAlarm(Alarm alarm) async {
    setState(() {
      _alarms.add(alarm);
      _alarms.sort((a, b) => a.hour.compareTo(b.hour));
    });
    await _saveAlarms();
    if (alarm.isEnabled) {
      await NotificationService.scheduleAlarm(alarm);
    }
  }

  Future<void> _toggleAlarm(Alarm alarm) async {
    setState(() {
      alarm.isEnabled = !alarm.isEnabled;
    });
    await _saveAlarms();
    
    if (alarm.isEnabled) {
      await NotificationService.scheduleAlarm(alarm);
    } else {
      await NotificationService.cancelAlarm(alarm.id);
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    await NotificationService.cancelAlarm(alarm.id);
    setState(() {
      _alarms.remove(alarm);
    });
    await _saveAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Lumen'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 4),
                Text(_greeting),
              ],
            ),
          ),
        ],
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 20),
                  Text(
                    'Нет будильников',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Нажмите + чтобы добавить',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Dismissible(
                  key: Key(alarm.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteAlarm(alarm),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: const Color(0xFF1C1C1E),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Switch(
                        value: alarm.isEnabled,
                        onChanged: (_) => _toggleAlarm(alarm),
                        activeColor: const Color(0xFFFF9F4A),
                      ),
                      title: Text(
                        alarm.timeString,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SFProDisplay',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alarm.label),
                          const SizedBox(height: 4),
                          Text(
                            alarm.repeatText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFFF9F4A)),
                        onPressed: () => _editAlarm(alarm),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAlarm(),
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF9F4A),
      ),
    );
  }

  void _navigateToAddAlarm() async {
    final result = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
    );
    
    if (result != null) {
      await _addAlarm(result);
    }
  }

  void _editAlarm(Alarm alarm) async {
    final result = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlarmScreen(alarm: alarm),
      ),
    );
    
    if (result != null) {
      await _deleteAlarm(alarm);
      await _addAlarm(result);
    }
  }
}