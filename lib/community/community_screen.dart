// community_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/services/realtime_database_service.dart';
import 'package:untitled1/need_help/need_help.dart'; // Add this import
import 'package:untitled1/volunteer/volunteer.dart'; // Add this import
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Our Community",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffADE0EB),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Choose how you'd like to participate",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildRoleButton(
                context: context,
                title: "I Need Visual Assistance",
                icon: Icons.accessibility_new,
                description: "Get help from our volunteers",
                role: 'visually_impaired',
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                context: context,
                title: "I'd Like to Volunteer",
                icon: Icons.volunteer_activism,
                description: "Help visually impaired users",
                role: 'volunteer',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required String role,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => _selectRole(context, role),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 50,
              color: const Color(0xffADE0EB),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xffADE0EB),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectRole(BuildContext context, String role) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update user role in database
      await RealtimeDatabaseService().updateUserRole(user.uid, role);

      // Navigate to appropriate screen
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'volunteer'
                ? const ProfileScreenVolunteer()
                : const HelpScreen(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}