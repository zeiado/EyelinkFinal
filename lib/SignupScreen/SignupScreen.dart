import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled1/LoginScreen/LoginScreen.dart';
import 'package:untitled1/services/realtime_database_service.dart';


class Language {
  final String code;
  final String name;
  final String native;

  const Language({
    required this.code,
    required this.name,
    required this.native,
  });
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String _selectedLanguage = 'English';
  String _selectedRole = '';
  bool _showRoleError = false;
  bool _isListening = false;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;
  

final List<Language> _languages = [
  const Language(code: 'en', name: 'English', native: 'English'),
  const Language(code: 'ar', name: 'Arabic', native: 'العربية'),
];

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'volunteer',
      'title': 'Volunteer',
      'icon': Icons.volunteer_activism,
      'description': 'Help visually impaired users',
    },
    {
      'id': 'visually_impaired',
      'title': 'Visually Impaired',
      'icon': Icons.accessibility_new,
      'description': 'Get assistance from volunteers',
    },
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool _isPhoneValid(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    return phoneRegex.hasMatch(phone);
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
        _speech.listen(
          onResult: (val) => setState(() {
            controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _handleEmailSignUp() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);
    try {
      // Check if user exists
      final userExists = await _dbService.checkUserExists(emailController.text.trim());
      if (userExists) {
        _showError('Email already registered. Please use a different email.');
        return;
      }

      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Store user data
      await _dbService.createUser(
        userId: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        role: _selectedRole,
        preferredLanguage: _selectedLanguage,
        languageCode: _languages
            .firstWhere((lang) => lang.name == _selectedLanguage).code,
      );

      _showSuccessSnackBar('Account created successfully! Please verify your email.');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showError(_getErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    if (_selectedRole.isEmpty) {
      _showError('Please select your role first');
      setState(() => _showRoleError = true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if user exists
      final userExists = await _dbService.checkUserExists(googleUser.email);
      if (userExists) {
        _showError('This Google account is already registered. Please sign in instead.');
        await _googleSignIn.signOut();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Store user data
      await _dbService.createUser(
        userId: userCredential.user!.uid,
        name: googleUser.displayName ?? '',
        email: googleUser.email,
        phone: phoneController.text.trim(),
        role: _selectedRole,
        preferredLanguage: _selectedLanguage,
        languageCode: _languages
            .firstWhere((lang) => lang.name == _selectedLanguage).code,
        photoUrl: googleUser.photoUrl,
      );

      if (mounted) {
        _showSuccessSnackBar('Account created successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _handleGoogleSignUpError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
    void _handleGoogleSignUpError(dynamic error) {
    String message = 'Google sign-up failed';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          message = 'This account exists with a different sign-in method';
          break;
        case 'invalid-credential':
          message = 'Invalid credentials';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-up is not enabled';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = error.message ?? 'Authentication failed';
      }
    }
    
    _showError(message);
  }

  bool _validateInputs() {
    if (_selectedRole.isEmpty) {
      setState(() => _showRoleError = true);
      _showError("Please select your role");
      return false;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showError("Please fill all fields");
      return false;
    }

    if (!_isEmailValid(emailController.text)) {
      _showError("Please enter a valid email");
      return false;
    }

    if (!_isPhoneValid(phoneController.text)) {
      _showError("Please enter a valid phone number");
      return false;
    }

    if (!_isPasswordValid(passwordController.text)) {
      _showError("Password must be 8+ chars with letters and numbers");
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError("Passwords don't match");
      return false;
    }

    if (!_acceptedTerms) {
      _showError("Please accept the terms and conditions");
      return false;
    }

    return true;
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Invalid email address';
        default:
          return 'Sign up failed: ${error.message}';
      }
    }
    return 'An error occurred: $error';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4),
      ),
    );
    _speak(message);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'I am a:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Row(
            children: _roles.map((role) {
              bool isSelected = _selectedRole == role['id'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedRole = role['id'];
                        _showRoleError = false;
                      });
                      _speak('Selected ${role['title']}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? const Color(0xffADE0EB)
                          : Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isSelected ? 4 : 0,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          role['icon'],
                          size: 32,
                          color: isSelected ? const Color(0xFF153349) : Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          role['title'],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF153349) : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role['description'],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF153349) : Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_showRoleError)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please select your role',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Preferred Language',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Row(
            children: _languages.map((language) {
              bool isSelected = _selectedLanguage == language.name;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLanguage = language.name;
                      });
                      _speak('Selected ${language.name}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? const Color(0xffADE0EB)
                          : Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isSelected ? 4 : 0,
                    ),
                    child: Text(
                      '${language.name} (${language.native})',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF153349) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    required VoidCallback onVoiceInput,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPassword)
                IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white70,
                ),
                onPressed: onVoiceInput,
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xffADE0EB).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffADE0EB),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Please fill in the form to continue",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildRoleSelector(),

              _buildInputField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person,
                onVoiceInput: () => _listen(nameController),
              ),

              _buildInputField(
                controller: emailController,
                label: "Email Address",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                onVoiceInput: () => _listen(emailController),
              ),

              _buildInputField(
                controller: phoneController,
                label: "Phone Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onVoiceInput: () => _listen(phoneController),
              ),

              _buildLanguageSelector(),

              _buildInputField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                isPassword: true,
                onVoiceInput: () => _listen(passwordController),
              ),

              _buildInputField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock,
                isPassword: true,
                onVoiceInput: () => _listen(confirmPasswordController),
              ),

              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white70,
                ),
                child: CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() => _acceptedTerms = value ?? false);
                  },
                  title: const Text(
                    'I accept the Terms and Conditions',
                    style: TextStyle(color: Colors.white70),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xffADE0EB),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffADE0EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF153349),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    const Text(
                      "Or sign up with",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignUp,
                      icon: Image.asset(
                        'assets/images/google-icon.png',
                        height: 24,
                      ),
                      label: const Text("Sign up with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Color(0xffADE0EB),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}