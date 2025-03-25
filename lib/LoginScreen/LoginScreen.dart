import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:untitled1/SignupScreen/SignupScreen.dart';
import 'package:untitled1/community/community_screen.dart';
import '../customtextfiled/customtextfiled.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool _isListening = false;

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void _listen(TextEditingController controller) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
              controller.text = val.recognizedWords;
            }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
  _speak(message); // قراءة الرسالة بصوت عالٍ
}

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xffADE0EB),
              ),
            ),
            SizedBox(height: height / 12),
            Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _speak("Be a one of\n Volunteers + 3.5k \nHelp Seeker + 1.5k  ");
                      },
                      child: const Text(
                        "Be a one of",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 30, color: Colors.white),
                        children: [
                          TextSpan(
                            text: "Volunteers ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "+ 3.5k\n",
                            style: TextStyle(
                                color: Color(0xff358089),
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "Help Seeker ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "+ 1.5k",
                            style: TextStyle(
                                color: Color(0xff358089),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Column(
                     children: [
                      GestureDetector(
                        onTap: () {
                          _speak(" DoubleTap and say your email address");
                          },
                           onDoubleTap: () {
                            _listen(emailcontroller);
                            },
                        child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                                ),
                                ),
                        child: const Text("say your  Email",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  ),
                                    ),
                       CustomTextField(
                        height: height,
                         text: " your email address",
                         icon: const Icon(Icons.email),
                        controller: emailcontroller,
                         ),
                         ],
                         ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                         GestureDetector(
                        onTap: () {
                          _speak("DoubleTap and say your password");
                          },
                           onDoubleTap: () {
                            _listen(emailcontroller);
                            },
                        child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                                ),
                                ),
                        child: const Text("say your password",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  ),
                                    ),
                        CustomTextField(
                          height: height,
                          text: " your Password",
                          icon: const Icon(Icons.lock),
                          controller: passwordcontroller,
                          isPassword: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: () {
                        _speak("DoubleTap to Login");
                      },
                      onDoubleTap: () {
                        if (emailcontroller.text.isEmpty ||
                            passwordcontroller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (!_isEmailValid(emailcontroller.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid email"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (!_isPasswordValid(passwordcontroller.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Password must be at least 8 characters long and include both letters and numbers"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommunityScreen()),
                          );
                        }
                      },
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffADE0EB),
                          fixedSize: const Size(220, 45),
                          shadowColor: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://th.bing.com/th/id/OIP.Fll7WPtNT6jrz1oBP8GbCgHaHj?rs=1&pid=ImgDetMain",
                          ),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://logodownload.org/wp-content/uploads/2014/09/facebook-logo-1-2.png",
                          ),
                        ),
                        SizedBox(width: 10),
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            "https://i.pinimg.com/originals/53/9f/f3/539ff32ec9d53f12952896dbbf6a28cb.png",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                       GestureDetector(
                          onTap: () {
                           _speak("Don't have an account?DoubleTap to create one new");
                           },
                          onDoubleTap: () {
                             Navigator.push(
                             context,
                               MaterialPageRoute(builder: (c) => const SignUpScreen()),
                              );
                             },
                          child: const Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                           Text("Don't have an account?",
                           style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))
                           ),
                           Text( " create one new!",
                           style: TextStyle(color: Color(0xff3D7279)),
                            ),
                              ],
                              ),
                              ),
                              ]
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}