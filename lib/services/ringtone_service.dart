import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../models/alarm.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();
  
  final Dio _dio = Dio();
  final AudioPlayer _player = AudioPlayer();
  List<Ringtone> _onlineRingtones = [];
  
  // Предустановленные мелодии
  final List<Ringtone> defaultRingtones = [
    Ringtone(
      id: 'default_1',
      name: 'Классический',
      url: 'assets/sounds/classic.mp3',
      isLocal: true,
    ),
    Ringtone(
      id: 'default_2',
      name: 'Нежный рассвет',
      url: 'assets/sounds/gentle.mp3',
      isLocal: true,
    ),
    Ringtone(
      id: 'default_3',
      name: 'Энергичный',
      url: 'assets/sounds/energetic.mp3',
      isLocal: true,
    ),
    Ringtone(
      id: 'default_4',
      name: 'Природа',
      url: 'assets/sounds/nature.mp3',
      isLocal: true,
    ),
  ];
  
  // Популярные онлайн мелодии
  final List<Map<String, String>> onlineSources = [
    {'name': 'Morning Rain', 'url': 'https://actions.google.com/sound/morning_rain.mp3'},
    {'name': 'Ocean Waves', 'url': 'https://actions.google.com/sound/ocean_waves.mp3'},
    {'name': 'Forest Birds', 'url': 'https://actions.google.com/sound/forest_birds.mp3'},
  ];
  
  Future<List<Ringtone>> getOnlineRingtones() async {
    try {
      // Здесь можно добавить API для получения мелодий
      // Пока возвращаем тестовые
      return onlineSources.map((source) => Ringtone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: source['name']!,
        url: source['url']!,
        isLocal: false,
      )).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<Ringtone?> downloadRingtone(String url, String name) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ringtones/$name.mp3';
      final file = File(filePath);
      
      if (!await file.exists()) {
        await file.create(recursive: true);
        await _dio.download(url, filePath);
      }
      
      return Ringtone.local(filePath, name);
    } catch (e) {
      return null;
    }
  }
  
  Future<Ringtone?> pickLocalRingtone() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Копируем в папку приложения
        final appDir = await getApplicationDocumentsDirectory();
        final newPath = '${appDir.path}/custom_ringtones/$fileName';
        final newFile = File(newPath);
        
        await newFile.create(recursive: true);
        await file.copy(newPath);
        
        return Ringtone.local(newPath, fileName.replaceAll('.mp3', '').replaceAll('.wav', ''));
      }
    } catch (e) {
      print('Error picking ringtone: $e');
    }
    return null;
  }
  
  Future<void> playRingtone(Ringtone ringtone, {bool loop = true}) async {
    try {
      if (ringtone.isLocal && ringtone.localPath != null) {
        await _player.play(DeviceFileSource(ringtone.localPath!));
      } else {
        await _player.play(UrlSource(ringtone.url));
      }
      
      if (loop) {
        await _player.setReleaseMode(ReleaseMode.loop);
      }
    } catch (e) {
      print('Error playing ringtone: $e');
    }
  }
  
  Future<void> stopRingtone() async {
    await _player.stop();
  }
  
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }
  
  Future<void> saveRingtones(List<Ringtone> ringtones) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = ringtones.map((r) => r.toJson().toString()).toList();
    await prefs.setStringList('custom_ringtones', jsonList);
  }
  
  Future<List<Ringtone>> loadCustomRingtones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('custom_ringtones') ?? [];
    return jsonList
        .map((json) => Ringtone.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  void dispose() {
    _player.dispose();
  }
}