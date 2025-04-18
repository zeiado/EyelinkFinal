import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/services/realtime_database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  final _formKey = GlobalKey<FormState>();
  
  bool isLoading = true;
  bool _isEditing = false;
  String _selectedLanguage = 'English';
  
  // User data
  String _name = '';
  String _email = '';
  String _role = '';
  String _preferredLanguage = '';
  String? _photoUrl;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _loadUserData();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _dbService.getUserData(user.uid);
        if (userData != null) {
          setState(() {
            _name = userData['name'] ?? '';
            _email = userData['email'] ?? '';
            _role = userData['role'] ?? '';
            _preferredLanguage = userData['preferredLanguage'] ?? 'English';
            _selectedLanguage = _preferredLanguage;
            _photoUrl = userData['photoUrl'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      _speak('Error loading user data');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.updateUserProfile(
          userId: user.uid,
          name: _name,
          preferredLanguage: _selectedLanguage,
        );
        
        setState(() => _isEditing = false);
        _speak('Profile updated successfully');
      }
    } catch (e) {
      _speak('Error updating profile');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _speak('Logging out');
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      _speak('Error logging out');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileSection(),
                          const SizedBox(height: 20),
                          if (_isEditing) _buildEditForm(),
                          if (!_isEditing) _buildSettingsOptions(),
                        ],
                      ),
                    ),
                  ),
                  _buildLogoutButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xffADE0EB)),
            onPressed: () {
              _speak('Going back');
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffADE0EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () => _speak('Your profile information'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xffADE0EB),
              backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
              child: _photoUrl == null
                  ? Text(
                      _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFF153349),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffADE0EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _role.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF153349),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions() {
    return Column(
      children: [
        ListTile(
          onTap: () {
            _speak('Double tap to edit profile');
            setState(() => _isEditing = true);
          },
          tileColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: const Icon(Icons.edit, color: Color(0xffADE0EB)),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xffADE0EB),
            size: 16,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          onTap: () => _speak('Language settings'),
          tileColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: const Icon(Icons.language, color: Color(0xffADE0EB)),
          title: const Text(
            'Language',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Text(
            _selectedLanguage,
            style: const TextStyle(color: Color(0xffADE0EB)),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          onTap: () => _speak('Help and support'),
          tileColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: const Icon(Icons.help_outline, color: Color(0xffADE0EB)),
          title: const Text(
            'Help & Support',
            style: TextStyle(color: Colors.white),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xffADE0EB),
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                TextFormField(
                  initialValue: _name,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.person, color: Color(0xffADE0EB)),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffADE0EB)),
                    ),
                  ),
                  onChanged: (value) => _name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildLanguageSelector(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffADE0EB),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF153349),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Language',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _languages.map((language) {
            bool isSelected = _selectedLanguage == language['name'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedLanguage = language['name']!);
                    _speak('Selected ${language['name']}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? const Color(0xffADE0EB)
                        : Colors.white.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    language['native']!,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF153349)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}