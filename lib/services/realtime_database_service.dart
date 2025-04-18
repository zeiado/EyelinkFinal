// lib/services/realtime_database_service.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealtimeDatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Setup online presence system
  void setupOnlinePresence() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
  
    final userStatusRef = _database.child('users').child(userId);
    final connectionRef = _database.child('.info/connected');
  
    connectionRef.onValue.listen((event) {
      bool connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        print('Connected to database');
        
        userStatusRef.onDisconnect().update({
          'isOnline': false,
          'lastSeen': ServerValue.timestamp,
        }).then((_) {
          userStatusRef.update({
            'isOnline': true,
            'lastSeen': ServerValue.timestamp,
          });
        });
      } else {
        print('Disconnected from database');
      }
    });
  }

  // User Operations
  Future<void> createUser({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String preferredLanguage,
    required String languageCode,
    String? photoUrl,
  }) async {
    try {
      await _database.child('users').child(userId).set({
        'userId': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'preferredLanguage': preferredLanguage,
        'languageCode': languageCode,
        'photoUrl': photoUrl,
        'isOnline': true,
        'isAvailable': role == 'volunteer' ? true : null,
        'lastSeen': ServerValue.timestamp,
        'createdAt': ServerValue.timestamp,
        'signUpMethod': 'email',
        'isRegistered': true,
        'emailVerified': false,
        'callsMade': 0,
      });
      
      setupOnlinePresence();
    } catch (e) {
      _handleError('Error creating user', e);
    }
  }

  // Basic User Operations
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final snapshot = await _database.child('users').child(userId).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      _handleError('Error getting user data', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snapshot = await _database
          .child('users')
          .orderByChild('email')
          .equalTo(email)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> values = 
            snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(values.values.first);
      }
      return null;
    } catch (e) {
      _handleError('Error getting user by email', e);
      return null;
    }
  }

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _database.child('users').child(userId).update({
        'isOnline': isOnline,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      _handleError('Error updating user status', e);
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _database.child('users').child(userId).update({
        'role': role,
        'isAvailable': role == 'volunteer' ? true : null,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      _handleError('Error updating user role', e);
    }
  }

  Future<void> updateUserLanguage(
    String userId, 
    String language, 
    String languageCode
  ) async {
    try {
      await _database.child('users').child(userId).update({
        'preferredLanguage': language,
        'languageCode': languageCode,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      _handleError('Error updating language', e);
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String preferredLanguage,
  }) async {
    try {
      await _database.child('users/$userId').update({
        'name': name,
        'preferredLanguage': preferredLanguage,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      _handleError('Error updating user profile', e);
    }
  }

  Future<void> updateUserAvailability(String userId, bool isAvailable) async {
    try {
      await _database.child('users').child(userId).update({
        'isAvailable': isAvailable,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      _handleError('Error updating user availability', e);
    }
  }
    // Call-Related Operations
  Future<String?> findAvailableVolunteer(String preferredLanguage) async {
    try {
      final snapshot = await _database
          .child('users')
          .orderByChild('role')
          .equalTo('volunteer')
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> volunteers = 
            snapshot.value as Map<dynamic, dynamic>;
        
        // Filter for available and online volunteers
        final availableVolunteers = volunteers.entries
            .where((entry) => 
                entry.value['isAvailable'] == true && 
                entry.value['isOnline'] == true)
            .toList();
        
        if (availableVolunteers.isEmpty) {
          return null;
        }
        
        // Try to find volunteer with matching language
        final languageMatch = availableVolunteers.firstWhere(
          (entry) => entry.value['preferredLanguage'] == preferredLanguage,
          orElse: () => availableVolunteers.first,
        );
        
        return languageMatch.key;
      }
      return null;
    } catch (e) {
      _handleError('Error finding available volunteer', e);
      return null;
    }
  }

  Future<String> createCallRequest({
    required String userId,
    required String volunteerId,
  }) async {
    try {
      const timestamp = ServerValue.timestamp;
      final callId = 'call_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Get user data
      final userData = await getUserData(userId);
      final userName = userData?['name'] ?? 'Unknown User';
      final language = userData?['preferredLanguage'] ?? 'en';
      
      // Create call data
      final callData = {
        'callId': callId,
        'userId': userId,
        'userName': userName,
        'volunteerId': volunteerId,
        'status': 'pending',
        'timestamp': timestamp,
        'language': language,
        'channelName': 'channel_$callId',
        'createdAt': timestamp,
      };
      
      // Save call request
      await _database.child('calls').child(callId).set(callData);
      
      // Update user's call history
      await _database.child('users').child(userId).update({
        'lastCallTime': timestamp,
        'callsMade': ServerValue.increment(1),
      });
      
      // Update volunteer status
      await updateUserAvailability(volunteerId, false);
      
      return callId;
    } catch (e) {
      _handleError('Error creating call request', e);
      throw Exception('Failed to create call request');
    }
  }

  Future<void> updateCallStatus(String callId, String status) async {
    try {
      final updates = {
        'status': status,
        'updateTime': ServerValue.timestamp,
      };

      // Add additional timestamps based on status
      if (status == 'accepted' || status == 'rejected') {
        updates['responseTime'] = ServerValue.timestamp;
      }
      if (status == 'ended') {
        updates['endTime'] = ServerValue.timestamp;
      }

      await _database.child('calls').child(callId).update(updates);

      // Handle volunteer availability if call ends or is rejected
      if (status == 'ended' || status == 'rejected') {
        final callData = await _database.child('calls').child(callId).get();
        if (callData.exists) {
          final volunteerId = (callData.value as Map)['volunteerId'];
          if (volunteerId != null) {
            await updateUserAvailability(volunteerId, true);
          }
        }
      }
    } catch (e) {
      _handleError('Error updating call status', e);
    }
  }

  void listenForCallResponse(String callId, Function(String) onStatusChange) {
    _database
        .child('calls')
        .child(callId)
        .child('status')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        onStatusChange(event.snapshot.value.toString());
      }
    });
  }

  Stream<DatabaseEvent> getActiveCalls(String userId) {
    return _database
        .child('calls')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue;
  }

  Stream<DatabaseEvent> getPendingCalls(String volunteerId) {
    return _database
        .child('calls')
        .orderByChild('volunteerId')
        .equalTo(volunteerId)
        .onValue;
  }

  Future<Map<String, dynamic>?> getCallData(String callId) async {
    try {
      final snapshot = await _database.child('calls').child(callId).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      _handleError('Error getting call data', e);
      return null;
    }
  }

  // Utility Methods
  Future<bool> checkUserExists(String email) async {
    try {
      final snapshot = await _database
          .child('users')
          .orderByChild('email')
          .equalTo(email)
          .get();
      return snapshot.exists;
    } catch (e) {
      _handleError('Error checking user existence', e);
      return false;
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('role')
          .get();
      return snapshot.value as String?;
    } catch (e) {
      _handleError('Error getting user role', e);
      return null;
    }
  }

  Future<void> deleteUserData(String userId) async {
    try {
      await _database.child('users').child(userId).remove();
    } catch (e) {
      _handleError('Error deleting user data', e);
    }
  }

  // Cleanup Methods
  Future<void> cleanup() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await updateUserStatus(userId, false);
    }
  }

  Future<void> cleanupCall(String callId) async {
    try {
      final callData = await getCallData(callId);
      if (callData != null) {
        final volunteerId = callData['volunteerId'];
        if (volunteerId != null) {
          await updateUserAvailability(volunteerId, true);
        }
        await updateCallStatus(callId, 'ended');
      }
    } catch (e) {
      _handleError('Error cleaning up call', e);
    }
  }

  void _handleError(String message, dynamic error) {
    print('$message: $error');
    throw Exception('$message: $error');
  }
}