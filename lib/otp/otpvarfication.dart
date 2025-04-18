import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PrivacyTerms.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _otpControllers = 
      List.generate(4, (index) => TextEditingController());
  bool _isLoading = false;

  Future<void> _verifyEmail() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      await user?.reload();
      if (user?.emailVerified ?? false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyTerms()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email not verified yet")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email resent")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Verification sent to ${widget.email}"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => SizedBox(
                width: 50,
                child: TextField(
                  controller: _otpControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyEmail,
                    child: const Text("Verify Email")),
            TextButton(
              onPressed: _resendVerification,
              child: const Text("Resend Verification")),
          ],
        ),
      ),
    );
  }
}