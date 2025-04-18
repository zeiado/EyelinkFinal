import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:untitled1/edit%20profile/setting.dart';
import 'package:untitled1/services/realtime_database_service.dart';
import 'package:untitled1/calling/calling.dart'; // Ensure this import path is correct
import 'package:untitled1/services/notification_service.dart'; // Add this import
import 'package:untitled1/services/ringtone_service.dart'; // Add this import

class ProfileScreenVolunteer extends StatefulWidget {
  const ProfileScreenVolunteer({super.key});

  @override
  _ProfileScreenVolunteerState createState() => _ProfileScreenVolunteerState();
}

class _ProfileScreenVolunteerState extends State<ProfileScreenVolunteer> {
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final NotificationService _notificationService = NotificationService();
  final RingtoneService _ringtoneService = RingtoneService();
  late Stream<DatabaseEvent> _callRequestsStream;
  bool isOnline = false;
  bool isLoading = true;
  String userName = '';
  String userEmail = '';
  int helpedUsers = 0;
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupCallListener();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _dbService.getUserData(user.uid);
        if (userData != null) {
          setState(() {
            isOnline = userData['isOnline'] ?? false;
            userName = userData['name'] ?? 'Volunteer';
            userEmail = userData['email'] ?? '';
            helpedUsers = userData['helpedUsers'] ?? 0;
            rating = (userData['rating'] ?? 0.0).toDouble();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _setupCallListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService.getPendingCalls(user.uid).listen((event) {
        if (event.snapshot.exists) {
          final calls = Map<dynamic, dynamic>.from(
              event.snapshot.value as Map);
          
          calls.forEach((callId, callData) {
            if (callData['status'] == 'pending') {
              // Show notification and play ringtone
              _notificationService.showIncomingCallNotification(
                callId: callId,
                userName: callData['userName'] ?? 'Unknown User',
                language: callData['language'] ?? 'Unknown Language',
              );
              // Show in-app dialog
              _showIncomingCallDialog(callId, callData);
            }
          });
        }
      });
    }
  }

  void _showIncomingCallDialog(String callId, Map<dynamic, dynamic> callData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text('Incoming Call from ${callData['userName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Language: ${callData['language']}'),
              const SizedBox(height: 16),
              const Text('Someone needs your assistance'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _ringtoneService.stopRingtone();
                _handleCallResponse(callId, 'rejected');
                Navigator.pop(context);
              },
              child: const Text('Decline'),
            ),
            ElevatedButton(
              onPressed: () {
                _ringtoneService.stopRingtone();
                _handleCallResponse(callId, 'accepted');
                Navigator.pop(context);
                _startVideoCall(callId, callData);
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  void _startVideoCall(String callId, Map<dynamic, dynamic> callData) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int uid = int.parse(user.uid.hashCode.toString().substring(0, 7));
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            channelName: callData['channelName'] ?? callId,
            uid: uid,
          ),
        ),
      ).then((_) {
        // Cleanup after call ends
        _dbService.cleanupCall(callId);
      });
    }
  }

  Future<void> _handleCallResponse(String callId, String status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _database.child('calls/$callId').update({
        'status': status,
        'responseTime': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error handling call response: $e');
    }
  }

  Future<void> toggleOnlineStatus(bool value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _dbService.updateUserStatus(user.uid, value);
        setState(() {
          isOnline = value;
        });
      }
    } catch (e) {
      _showError('Error updating status: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProfileInfo(),
                  _buildStats(),
                  if (isOnline) _buildOnlineMessage(),
                  const Spacer(),
                  _buildFooter(),
                ],
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
          Row(
            children: [
              Switch(
                value: isOnline,
                onChanged: toggleOnlineStatus,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
              ),
              Text(
                isOnline ? "Online" : "Offline",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu, size: 40, color: Color(0xff3D7279)),
            onPressed: openSettingsScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xff3D7279),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Hi, $userName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffADE0EB),
          ),
        ),
        Text(
          userEmail,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Helped Users', helpedUsers.toString()),
          _buildStatItem('Rating', rating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff3D7279).withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffADE0EB),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineMessage() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff3D7279),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(height: 10),
          Text(
            'You will receive a notification when someone needs your help.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        'Thank you for being a volunteer!',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop ringtone and cleanup
    _ringtoneService.dispose();
    
    // Update user status when leaving
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService.updateUserStatus(user.uid, false);
    }
    super.dispose();
  }
}