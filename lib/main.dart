import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen/splash_screen.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart'; // Import the notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('✅ Notification service initialized successfully');

    // Configure Realtime Database
    try {
      // Configure database
      FirebaseDatabase.instance.setLoggingEnabled(true);
      
      // Test database connection
      final DatabaseReference testRef = FirebaseDatabase.instance.ref().child('test');
      await testRef.set({
        'connection_test': 'successful',
        'timestamp': ServerValue.timestamp,
      });

      print('✅ Realtime Database connection successful');

      // Listen for connection state
      FirebaseDatabase.instance
          .ref('.info/connected')
          .onValue
          .listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        print(connected ? '🟢 Connected to Realtime Database' : '🔴 Disconnected from Realtime Database');
      });

    } catch (dbError) {
      _handleDatabaseError(dbError);
    }

  } catch (firebaseError) {
    _handleFirebaseError(firebaseError);
  }

  runApp(const MyApp());
}

void _handleDatabaseError(dynamic error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        print('❌ Database Error: Please update Realtime Database rules');
        break;
      case 'unavailable':
        print('❌ Database Error: Service is unavailable');
        break;
      default:
        print('❌ Database Error: ${error.message}');
    }
  } else {
    print('❌ Database Error: $error');
  }
}

void _handleFirebaseError(dynamic error) {
  print('❌ Firebase initialization error: $error');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Be My Eyes Clone',
      theme: ThemeData(
        primaryColor: const Color(0xFF153349),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffADE0EB),
          primary: const Color(0xFF153349),
          secondary: const Color(0xffADE0EB),
        ),
        useMaterial3: true,
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xffADE0EB),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.red.shade300,
            ),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffADE0EB),
            foregroundColor: const Color(0xFF153349),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xffADE0EB),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
        // Snackbar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF153349),
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Optional: Add a connection status widget
class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('.info/connected').onValue,
      builder: (context, snapshot) {
        final connected = snapshot.data?.snapshot.value as bool? ?? false;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color: connected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            connected ? 'Connected' : 'Offline',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      },
    );
  }
}