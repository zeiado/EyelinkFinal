import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled1/SignupScreen/SignupScreen.dart';
import 'package:untitled1/community/community_screen.dart';
import 'package:untitled1/services/realtime_database_service.dart';
import 'package:untitled1/need_help/need_help.dart'; // Add this import
import 'package:untitled1/volunteer/volunteer.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isListening = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkPreviousSession();
  }

  //@override
  //void dispose() {
    // Update user status when leaving
    //final user = _auth.currentUser;
    //if (user != null) {
      //_dbService.updateUserStatus(user.uid, false);
    //}
    //emailController.dispose();
    //passwordController.dispose();
    //super.dispose();
  //}

  Future<void> _checkPreviousSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userExists = await _checkUserExists(user.uid);
      if (!userExists) {
        await user.delete();
        await _auth.signOut();
      }
    }
  }

  Future<bool> _checkUserExists(String uid) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref().child('users').child(uid).get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
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

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
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

  void _navigateBasedOnRole(String role) {
    if (role.isEmpty) {
      // If no role is set, go to community screen for role selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CommunityScreen()),
      );
    } else {
      // Navigate based on existing role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => role == 'volunteer' 
              ? const ProfileScreenVolunteer()    // Your existing VolunteerScreen
              : const HelpScreen(),  // Your existing VisuallyImpairedScreen
        ),
      );
    }
  }

Future<void> _handleEmailPasswordLogin() async {
  if (!_validateInputs()) return;

  setState(() => _isLoading = true);
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    
    if (!userCredential.user!.emailVerified) {
      _showSnackBar("Please verify your email first");
      await userCredential.user!.sendEmailVerification();
      return;
    }
    
    // Get user data to check role
    final userData = await _dbService.getUserData(userCredential.user!.uid);
    final userRole = userData?['role'] as String? ?? '';
    
    // Setup online presence (handles status update)
    _dbService.setupOnlinePresence();
    
    if (mounted) {
      _showSnackBar('Login successful!', isError: false);
      _navigateBasedOnRole(userRole);
    }
  } on FirebaseAuthException catch (e) {
    _showSnackBar(_getFirebaseErrorMessage(e));
  } catch (e) {
    _showSnackBar('An error occurred. Please try again.');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);
  try {
    await _googleSignIn.signOut();
    
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    
    // Get user data to check role
    final userData = await _dbService.getUserData(userCredential.user!.uid);
    final userRole = userData?['role'] as String? ?? '';
    
    // Setup online presence (handles status update)
    _dbService.setupOnlinePresence();

    if (mounted) {
      _showSnackBar('Login successful!', isError: false);
      _navigateBasedOnRole(userRole);
    }
  } catch (e) {
    if (mounted) {
      _handleGoogleSignInError(e);
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  void _handleGoogleSignInError(dynamic error) {
    String message = 'Google sign-in failed';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
          message = 'This account exists with a different sign-in method';
          break;
        case 'invalid-credential':
          message = 'Invalid credentials';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-in is not enabled';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = error.message ?? 'Authentication failed';
      }
    }
    
    _showSnackBar(message);
  }

  Future<void> _handleForgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      _showSnackBar("Please enter your email address first");
      return;
    }

    if (!_isEmailValid(emailController.text.trim())) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      _showSnackBar(
        "Password reset link sent to ${emailController.text}",
        isError: false,
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_getFirebaseErrorMessage(e));
    }
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Please fill all fields");
      return false;
    }

    if (!_isEmailValid(emailController.text)) {
      _showSnackBar("Please enter a valid email");
      return false;
    }

    return true;
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Login failed: ${e.message}';
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
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
                onPressed: () => _listen(controller),
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
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffADE0EB),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildInputField(
                controller: emailController,
                label: "Email Address",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              _buildInputField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                isPassword: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xffADE0EB),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailPasswordLogin,
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
                          "Login",
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
                      "Or continue with",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: Image.asset(
                        'assets/images/google-icon.png',
                        height: 24,
                      ),
                      label: const Text("Login with Google"),
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
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  ),
                  child: const Text(
                    "Don't have an account? Sign Up",
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