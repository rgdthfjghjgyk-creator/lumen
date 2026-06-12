import 'dart:math';
import 'package:flutter/material.dart';
import '../models/alarm.dart';

class MathChallengeWidget extends StatefulWidget {
  final MathLevel level;
  final VoidCallback onSuccess;
  
  const MathChallengeWidget({
    super.key,
    required this.level,
    required this.onSuccess,
  });
  
  @override
  State<MathChallengeWidget> createState() => _MathChallengeWidgetState();
}

class _MathChallengeWidgetState extends State<MathChallengeWidget> {
  late int _num1;
  late int _num2;
  late String _operator;
  late int _answer;
  final TextEditingController _controller = TextEditingController();
  String _message = '';
  int _attempts = 0;
  
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }
  
  void _generateQuestion() {
    final maxValue = widget.level.maxValue;
    _num1 = _random.nextInt(maxValue) + 1;
    _num2 = _random.nextInt(maxValue) + 1;
    
    final operators = ['+', '-', '×'];
    _operator = operators[_random.nextInt(operators.length)];
    
    switch (_operator) {
      case '+':
        _answer = _num1 + _num2;
        break;
      case '-':
        if (_num1 < _num2) {
          final temp = _num1;
          _num1 = _num2;
          _num2 = temp;
        }
        _answer = _num1 - _num2;
        break;
      case '×':
        _answer = _num1 * _num2;
        break;
    }
  }
  
  void _checkAnswer() {
    final userAnswer = int.tryParse(_controller.text);
    
    if (userAnswer == _answer) {
      widget.onSuccess();
    } else {
      setState(() {
        _attempts++;
        _message = '❌ Неправильно! Попробуйте еще раз';
        _controller.clear();
        
        if (_attempts >= 3) {
          _message = 'Подсказка: $_num1 $_operator $_num2 = $_answer';
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '🔐 Решите пример, чтобы выключить',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            '$_num1 $_operator $_num2 = ?',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Введите ответ',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _message,
                style: TextStyle(
                  color: _message.contains('❌') ? Colors.red : Colors.green,
                ),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Проверить', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}