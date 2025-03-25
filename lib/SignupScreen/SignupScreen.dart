import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:untitled1/LoginScreen/LoginScreen.dart';
import 'package:untitled1/otp/otpvarfication.dart';
import '../customtextfiled/customtextfiled.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmPasswordcontroller = TextEditingController();
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
              "Sign up",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xffADE0EB),
              ),
            ),
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
                        _speak("Be a one of\n Volunteers + 3.5k\n Help Seeker + 1.5k");
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
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 255, 255, 255)),
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
                            _speak("DoubleTap and say your email address");
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
                            child: const Text(
                              "say your Email",
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
                            _listen(passwordcontroller);
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
                            child: const Text(
                              "say your Password",
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
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _speak(" DoubleTap and say the same password");
                          },
                          onDoubleTap: () {
                            _listen(confirmPasswordcontroller);
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
                            child: const Text(
                              "say Confirm Password",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        CustomTextField(
                          height: height,
                          text: "Confirm Password ",
                          icon: const Icon(Icons.lock),
                          controller: confirmPasswordcontroller,
                          isPassword: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: () {
                        _speak(" DoubleTap to Sign up");
                      },
                      onDoubleTap: () {
                        if (emailcontroller.text.isEmpty ||
                            passwordcontroller.text.isEmpty ||
                            confirmPasswordcontroller.text.isEmpty) {
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
                        } else if (passwordcontroller.text !=
                            confirmPasswordcontroller.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Passwords do not match"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OtpScreen()),
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
                          "Sign up",
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       GestureDetector(
                          onTap: () {
                           _speak("Already have an account? DoubleTap to Login");
                           },
                          onDoubleTap: () {
                             Navigator.push(
                             context,
                               MaterialPageRoute(builder: (c) => const LoginScreen()),
                              );
                             },
                          child: const Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                           Text("Already have an account?",
                           style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))
                           ),
                           Text( " Login",
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