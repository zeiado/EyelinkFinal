import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:untitled1/calling/calling.dart';
import 'package:untitled1/edit%20profile/setting.dart';
import 'package:untitled1/loading/loadingAI.dart';  

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final FlutterTts flutterTts = FlutterTts();

  // دالة لتحويل النص إلى صوت
  void _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

 void openSettingsScreen() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Settings",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75, // يجعل الشاشة تظهر بنسبة 75% من العرض
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              ),
              child: const SettingsScreen(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 40, color: Color(0xff3D7279)),
              onPressed: openSettingsScreen, // فتح شاشة الإعدادات
            ),
          ),
          const SizedBox(height: 20),
           Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              _speak("Hi, Tasneem");
            },
            child: const Text(
              'Hi, Tasneem',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _speak("Welcome back! If you need help, press in the first buttom to call volanter or second to connect AI ");
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Welcome back! If you need help, press in the middle of the screen.',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
         Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GestureDetector(
                onTap: () {
                  _speak("DoubleTap to calling volunteer");
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>const VideoCallScreen ()),
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
                      "calling volunteer now  ",
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
                  _speak("DoubleTap to connect with AI");
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>const AILoadingScreen()),
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
                      "connect to AI ",
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

