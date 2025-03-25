import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; 
import 'package:untitled1/homescreen/home_screen.dart'; 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // دالة لتحويل النص إلى صوت
  void _speak(String text) async {
    await flutterTts.setLanguage("en-us"); 
    await flutterTts.setPitch(1.0); 
    await flutterTts.setSpeechRate(0.5); 
    await flutterTts.speak(text); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover, 
                ),

                const SizedBox(height: 10),
                
                
                GestureDetector(
                  onTap: () {
                    _speak("Eyelink");
                  },
                  child: Semantics(
                    label: 'Eyelink Logo',
                    child: const Text(
                      "Eyelink",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                GestureDetector(
                  onTap: () {
                    _speak("Your personal vision assistant powered by AI");
                  },
                  child: Semantics(
                    label: 'Tagline: Your personal vision assistant\n powered by AI',
                    child: const Text(
                      "Your personal vision assistant\n powered by AI",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Semantics(
              label: 'Get Started Button',
              button: true, 
              child: GestureDetector(
                onTap: () {
                  _speak("DoubleTap to Get Started!");
                },
                onDoubleTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: null,
                    child: const Text(
                      "Get Started!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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