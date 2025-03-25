import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // استيراد مكتبة Text-to-Speech
import 'package:untitled1/help/RequestHelp.dart';
import 'package:untitled1/how_to_use/Tutorial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // دالة لتحويل النص إلى صوت
  void _speak(String text) async {
    await flutterTts.setLanguage("en-us");  // تعيين اللغة الإنجليزية
    await flutterTts.setPitch(1.0); // تعيين درجة الصوت (اختياري)
    await flutterTts.setSpeechRate(0.5); // تعيين سرعة الصوت (اختياري)
    await flutterTts.speak(text); // تحويل النص إلى صوت
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349), // لون الخلفية
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', // استبدل بمسار الصورة الصحيح
                width: 100,
                height: 100,
                fit: BoxFit.cover, // لضبط حجم الصورة
                ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _speak("Welcome to Eyelink!");
                    },
                    child: Semantics(
                      label: 'Welcome to Eyelink',
                      child: const Text(
                        "Welcome to Eyelink!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        _speak(" We are here to help you navigate the world with ease. Whether it's reading, identifying objects, or just getting assistance, our AI and volunteers are ready to assist you.");
                      },
                      child: Semantics(
                        label: "Text: We are here to help you navigate the world with ease. Whether it's reading, identifying objects, or just getting assistance, our AI and volunteers are ready to assist you.",
                        child: const Text(
                          "We're here to help you navigate the world with ease. Whether it's reading, identifying objects, or just getting assistance, our AI and volunteers are ready to assist you.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  _speak("DoubleTap to Request Help");
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestHelp()),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: null, // تعطيل onPressed لأننا نستخدم GestureDetector
                    child: const Text(
                      "Request Help",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  _speak("DoubleTap to know How to Use");
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Tutorial()),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: null, // تعطيل onPressed لأننا نستخدم GestureDetector
                    child: const Text(
                      "Tutorial / How to Use",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}