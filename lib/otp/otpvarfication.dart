import 'package:flutter/material.dart';
import 'PrivacyTerms.dart';


class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  void verifyOtp() {
    String otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length == 4 && otp.runes.every((char) => char >= 48 && char <= 57)) {
      print("OTP Entered: $otp");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PrivacyTerms()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all 4 digits correctly")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF153349),
      appBar: AppBar(
        title: const Text('Enter OTP'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ إضافة الصورة هنا
            Image.asset(
              'assets/images/otp.png',  
              width: 300, 
              height: 250, 
              fit: BoxFit.cover,
               // جعل الصورة متناسقة
            ),

            const SizedBox(height: 20),

            // ✅ مربعات إدخال OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            const Text("Check your email and enter the 4-digit code",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text("Verify", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
