import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String _language = 'Select';
  String _username = 'User 1';
  String _email = 'user24525785436';
  bool _isEditing = false;

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
      body: Column(
        children: [
          const SizedBox(height: 40), // مساحة علوية
          
          // زر الرجوع
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          const SizedBox(height: 10),
          Image.asset(
            'assets/images/logo.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          Text(_username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(_email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              _speak("DoubleTap to Edit profile");
            },
            onDoubleTap: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: const ListTile(
              leading: Icon(Icons.edit, color: Colors.white),
              title: Text('Edit profile', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.edit, color: Colors.white),
              tileColor: Color(0xFF153349),
            ),
          ),

          if (_isEditing) _buildEditForm(),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: const Text('Language', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: _language,
              items: <String>['Select', 'English', 'Arabic'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _language = newValue!;
                });
              },
            ),
            tileColor: const Color(0xFF153349),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _speak("Log out");
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Log out', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: 'Username',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _username = value;
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email),
              hintText: 'Email',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
          ),
          const SizedBox(height: 10),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              hintText: 'Phone number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue[200],
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Submit', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
