import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/calling/calling.dart';
import 'package:untitled1/edit%20profile/setting.dart';
import 'package:untitled1/loading/loadingAI.dart';
import 'package:untitled1/services/realtime_database_service.dart';
// Import the AgoraConfig class

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isLoading = true;
  String userName = '';
  String preferredLanguage = 'en-US';
  int callsMade = 0;
  DateTime? lastCallTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    _speakWelcome();
  }

  void _speakWelcome() async {
    await flutterTts.speak("Welcome back! Double tap anywhere to hear instructions.");
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _dbService.getUserData(user.uid);
        if (userData != null) {
          setState(() {
            userName = userData['name'] ?? 'User';
            preferredLanguage = userData['preferredLanguage'] ?? 'en-US';
            callsMade = userData['callsMade'] ?? 0;
            lastCallTime = userData['lastCallTime'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(userData['lastCallTime'])
                : null;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void openSettingsScreen() {
    _speak("Opening settings");
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
              width: MediaQuery.of(context).size.width * 0.75,
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
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

// In HelpScreen class

void onCallVolunteer() async {
  setState(() => isLoading = true);
  try {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      _showError("User not logged in");
      return;
    }
    
    // Find available volunteer
    final volunteerId = await _dbService.findAvailableVolunteer(preferredLanguage);
    if (volunteerId == null) {
      _showNoVolunteersMessage();
      setState(() => isLoading = false);
      return;
    }

    // Create call request
    final callId = await _dbService.createCallRequest(
      userId: currentUserId,
      volunteerId: volunteerId,
    );

    // Listen for volunteer's response
    _dbService.listenForCallResponse(callId, (status) async {
      if (status == 'accepted') {
        _speak("Call accepted. Connecting to volunteer.");
        
        // Get call data to get channel name
        final callData = await _dbService.getCallData(callId);
        final channelName = callData?['channelName'] ?? callId;
        
        // Generate unique UID for video call
        int uid = int.parse(currentUserId.hashCode.toString().substring(0, 7));
        
        // Navigate to video call screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              channelName: channelName,
              uid: uid,
            ),
          ),
        ).then((_) {
          // Cleanup after call ends
          _dbService.cleanupCall(callId);
        });
      } else if (status == 'rejected') {
        _speak("Volunteer is unavailable. Please try again later.");
        _showVolunteerUnavailableMessage();
        setState(() => isLoading = false);
      } else if (status == 'ended') {
        setState(() => isLoading = false);
      }
    });

  } catch (e) {
    print('Error making call: $e');
    _showError(e.toString());
    setState(() => isLoading = false);
  }
}

void _showNoVolunteersMessage() {
  _speak("No volunteers are available at the moment. Please try again later.");
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("No Volunteers Available"),
      content: const Text(
        "There are no volunteers available at the moment. Please try again later."
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _showVolunteerUnavailableMessage() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Volunteer Unavailable"),
      content: const Text(
        "The volunteer is currently unavailable. Please try again."
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _showError(String message) {
  _speak("An error occurred. Please try again.");
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildWelcomeSection(),
                      const Spacer(),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
                      if (lastCallTime != null) _buildLastCallInfo(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'app_logo',
            child: Image.asset(
              'assets/images/logo.png',
              height: 60,
              width: 60,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xffADE0EB),
              size: 30,
            ),
            onPressed: openSettingsScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _speak("Welcome back, $userName"),
            child: Text(
              "Welcome back, $userName!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xffADE0EB),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _speak("How can we assist you today?"),
            child: Text(
              "How can we assist you today?",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildActionButton(
            title: "Call a Volunteer",
            description: "Get help from a real person",
            icon: Icons.video_call,
            color: const Color(0xff3D7279),
            onTap: () => _speak("Double tap to call a volunteer"),
            onDoubleTap: onCallVolunteer,
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            title: "AI Assistant",
            description: "Get instant AI-powered help",
            icon: Icons.auto_awesome,
            color: const Color(0xff2C5D63),
            onTap: () => _speak("Double tap to use AI assistance"),
            onDoubleTap: () {
              _speak("Starting AI assistant");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AILoadingScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onDoubleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Double tap to activate",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastCallInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Last call: ${_formatDateTime(lastCallTime!)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
}