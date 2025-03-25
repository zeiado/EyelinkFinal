import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:untitled1/volunteer/volunteer.dart';
import 'package:untitled1/need_help/need_help.dart';

class CommunityScreen extends StatelessWidget {
  final FlutterTts flutterTts = FlutterTts();

  CommunityScreen({super.key});

  // دالة لتحويل النص إلى صوت
  void _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
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
                width: 140,
                height: 140,
                fit: BoxFit.cover, // لضبط حجم الصورة
                ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _speak("Join the community.\nSee the world together.");
                    },
                    child: Semantics(
                      label: "Join the community.\nSee the world together.",
                      child: const Text(
                        "Join the community.\nSee the world together.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  _speak("DoubleTap if you need visual assistance");
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
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
                      "I need visual assistance",
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
                  _speak("DoubleTap if you like to volunteer");
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreenvolunteer()),
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
                      "I'd like to volunteer",
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