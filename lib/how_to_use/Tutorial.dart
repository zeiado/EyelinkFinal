import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // استيراد مكتبة Text-to-Speech
import 'package:untitled1/LoginScreen/LoginScreen.dart';

class Tutorial extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();

  Tutorial({super.key});

  // دالة لتحويل النص إلى صوت
  void _speak(String text) async {
    await flutterTts.setLanguage("en-US");  // تعيين اللغة الإنجليزية
    await flutterTts.setPitch(1.0); // تعيين درجة الصوت (اختياري)
    await flutterTts.setSpeechRate(0.5); // تعيين سرعة الصوت (اختياري)
    await flutterTts.speak(text); // تحويل النص إلى صوت
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      appBar: AppBar(
        title: const Text('Tutorial / How to Use'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _speak('Learn how to use Eyelink step by step:');
              },
              child: const Text(
                'Learn how to use Eyelink step by step:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _speak('Step 1: Open the app and navigate to the main menu.');
              },
              child: const Text(
                'Step 1: Open the app and navigate to the main menu.',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _speak('Step 2: Select the feature you want to use, such as "Request Help" or "Connect to AI".');
              },
              child: const Text(
                'Step 2: Select the feature you want to use, such as "Request Help" or "Connect to AI".',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _speak('Step 3: Follow the instructions provided on the screen for each feature.');
              },
              child: const Text(
                'Step 3: Follow the instructions provided on the screen for each feature.',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _speak('Step 4: If you need further assistance, contact a volunteer or use AI help.');
              },
              child: const Text(
                'Step 4: If you need further assistance, contact a volunteer or use AI help.',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: () {
                  _speak('DoubleTap TO start login!');
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ElevatedButton(
                    onPressed: null, // تعطيل onPressed لأننا نستخدم GestureDetector
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Got It!',
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}