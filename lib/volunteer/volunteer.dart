import 'package:flutter/material.dart';
import 'package:untitled1/edit%20profile/setting.dart';

class ProfileScreenvolunteer extends StatefulWidget {
  const ProfileScreenvolunteer({super.key});

  @override
  _ProfileScreenvolunteerState createState() => _ProfileScreenvolunteerState();
}

class _ProfileScreenvolunteerState extends State<ProfileScreenvolunteer> {
  bool isOnline = false; // حالة المتطوع (أونلاين أو أوفلاين)

  void toggleOnlineStatus(bool value) {
    setState(() {
      isOnline = value;
    });
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
              width: MediaQuery.of(context).size.width * 0.75, // يجعل الشاشة تظهر بنسبة 75% من العرض
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
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
              ),
              IconButton(
                icon: const Icon(Icons.menu, size: 40, color: Color(0xff3D7279)),
                onPressed: openSettingsScreen,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/logo.png',
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 30),
          const Text(
            'Hi, Felopater',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 60),
          if (isOnline) // إظهار الرسالة فقط إذا كان المتطوع أونلاين
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff3D7279),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'You will receive a notification when someone needs your help.',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
