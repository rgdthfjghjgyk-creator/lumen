import 'package:flutter/material.dart';

class TypingChallengeWidget extends StatefulWidget {
  final VoidCallback onSuccess;
  
  const TypingChallengeWidget({super.key, required this.onSuccess});
  
  @override
  State<TypingChallengeWidget> createState() => _TypingChallengeWidgetState();
}

class _TypingChallengeWidgetState extends State<TypingChallengeWidget> {
  final List<String> _phrases = [
    'Я просыпаюсь бодрым и полным энергии',
    'Сегодня будет отличный день',
    'Я люблю начинать день рано',
    'Каждое утро - это новый шанс',
    'Я контролирую свою жизнь',
  ];
  
  late String _targetText;
  final TextEditingController _controller = TextEditingController();
  String _message = '';
  
  @override
  void initState() {
    super.initState();
    _targetText = _phrases[_phrases.length % DateTime.now().second];
  }
  
  void _checkText() {
    if (_controller.text.trim().toLowerCase() == _targetText.toLowerCase()) {
      widget.onSuccess();
    } else {
      setState(() {
        _message = '❌ Текст не совпадает! Попробуйте еще раз';
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
            '🔐 Напечатайте текст, чтобы выключить',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _targetText,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Введите текст здесь',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _checkText(),
          ),
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_message, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkText,
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