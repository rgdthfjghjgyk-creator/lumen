import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeChallengeWidget extends StatefulWidget {
  final int requiredShakes;
  final VoidCallback onSuccess;
  
  const ShakeChallengeWidget({
    super.key,
    required this.requiredShakes,
    required this.onSuccess,
  });
  
  @override
  State<ShakeChallengeWidget> createState() => _ShakeChallengeWidgetState();
}

class _ShakeChallengeWidgetState extends State<ShakeChallengeWidget> {
  int _shakeCount = 0;
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  DateTime _lastShake = DateTime.now();
  late StreamSubscription<AccelerometerEvent> _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEvents.listen((event) {
      final now = DateTime.now();
      final diff = now.difference(_lastShake).inMilliseconds;
      
      final dx = (event.x - _lastX).abs();
      final dy = (event.y - _lastY).abs();
      final dz = (event.z - _lastZ).abs();
      
      if ((dx > 15 || dy > 15 || dz > 15) && diff > 200) {
        setState(() {
          _shakeCount++;
          _lastShake = now;
          
          if (_shakeCount >= widget.requiredShakes) {
            widget.onSuccess();
          }
        });
      }
      
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = _shakeCount / widget.requiredShakes;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '🔐 Встряхните телефон, чтобы выключить',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.green,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 10),
          Text(
            '$_shakeCount / ${widget.requiredShakes}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}