import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:untitled1/LoginScreen/LoginScreen.dart';

class RequestHelp extends StatefulWidget {
  const RequestHelp({super.key});

  @override
  _RequestHelpState createState() => _RequestHelpState();
}

class _RequestHelpState extends State<RequestHelp> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  // دالة لتحويل النص إلى صوت
  void _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  // دالة لبدء الاستماع
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
              _text = val.recognizedWords;
            }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      appBar: AppBar(
        backgroundColor: const Color(0xFF153349),
        title: const Text('Request Help'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _speak('Choose your preferred method to request help:');
              },
              child: const Text(
                'Choose your preferred method to request help:',
                style: TextStyle(fontSize: 18, color: Colors.white, decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
               GestureDetector(
                 onTap: () {
                _speak('DoubleTap to  Record Your Voice Request');
              },
              onDoubleTap: () {
                _listen();
              },
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[100],
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: null,
                child: const Text(
                  'Record Your Voice Request',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.mic, size: 50, color: Colors.white),
              onPressed: _listen,
            ),
            const SizedBox(height: 20),
             GestureDetector(
              onTap: () {
                _speak('DoubleTap Submit Request');
              },
              onDoubleTap: () {
                _speak('DONE YOUR Request HAS BEEN SENT');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[100],
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const Divider(),
            const Text('OR', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: _text),
              decoration: InputDecoration(
                hintText: 'Type your request here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
             GestureDetector(
              onTap: () {
                _speak('DoubleTap Submit Request');
              },
              onDoubleTap: () {
                _speak('DONE YOUR Request HAS BEEN SENT');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[100],
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}