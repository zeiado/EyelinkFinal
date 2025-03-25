import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:untitled1/community/community_screen.dart';

class PrivacyTerms extends StatefulWidget {
  const PrivacyTerms({super.key});

  @override
  _PrivacyTermsState createState() => _PrivacyTermsState();
}

class _PrivacyTermsState extends State<PrivacyTerms> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isAgreed = false;

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
      backgroundColor: const Color(0xFF153349),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _speak("Privacy and Terms");
              },
              child: const Text(
                "Privacy and Terms",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock, size: 100, color: Color(0xff3D7279)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _speak("To use Eyelink, I agree to the following");
              },
              child: const Text(
                "To use Eyelink, I agree to the following",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _speak(
                    "I will not use Eyelink as a mobility device. Eyelink can record, review, and share videos and images for safety, quality, and as further described in the privacy policy. The data, videos, images, and personal information I submit to Eyelink may be stored and processed.");
              },
              child: const Text(
                "I will not use Eyelink as a mobility device.\n\n"
                "Eyelink can record, review, and share videos and images for safety, quality, and as further described in the privacy policy.\n\n"
                "The data, videos, images, and personal information I submit to Eyelink may be stored and processed.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value!;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _speak("I agree to Terms of Service");
                  },
                  child: const Text(
                    "I agree to ",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _speak("Terms of Service");
                  },
                  child: const Text(
                    "Terms of Service",
                    style: TextStyle(
                      fontSize: 14,
                      color:Color(0xff3D7279),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _speak("DoubleTab to Next");
              },
              onDoubleTap: () {
                if (_isAgreed) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommunityScreen()),
                  );
                } else {
                  _speak("You must agree to the terms and privacy policy.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You must agree to the terms and privacy policy."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAgreed ? Colors.teal.shade300 : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _speak("By clicking 'agree', I agree to everything above and accept terms of service and privacy policy.");
              },
              child: const Text(
                "By clicking 'agree', I agree to everything above and accept terms of service and privacy policy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}