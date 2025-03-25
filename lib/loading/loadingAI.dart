import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled1/obj_detaction/ai.dart';

class AILoadingScreen extends StatefulWidget {
  const AILoadingScreen({super.key});

  @override
  _AILoadingScreenState createState() => _AILoadingScreenState();
}

class _AILoadingScreenState extends State<AILoadingScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _progress += 0.1;
      });

      if (_progress >= 1.0) {
        timer.cancel();
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    // استبدل بـ الشاشة التي تريد الانتقال إليها
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ObjectDetectionScreen()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349), 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة الذكاء الاصطناعي
            Image.asset(
              'assets/images/ai.png', 
              width: 150,
              height: 150,
            ),

            const SizedBox(height: 20),

            // النص العلوي
            const Text(
              "AI is here to assist you",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),

            const SizedBox(height: 30),

            // زر تحميل متفاعل
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "AI is analyzing your request...",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),

            const SizedBox(height: 20),

            // شريط التحميل
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white24,
              color: Colors.lightBlueAccent,
              minHeight: 10,
            ),

            const SizedBox(height: 10),

            // نسبة التحميل
            Text(
              "${(_progress * 100).toInt()}% Completed",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),

            const SizedBox(height: 30),

            // زر "Next"
            ElevatedButton(
              onPressed: () {
                if (_progress >= 1.0) {
                  _navigateToNextScreen();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

