import 'package:flutter/material.dart';
import 'dart:async';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool isCalling = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    /// auto switch to "call active"
    timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isCalling = false;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // ✅ prevent memory issues
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(
              isCalling ? "Incoming Call" : "Call Connected",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 8),

            const Text(
              "Mom ❤️",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            isCalling
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      /// DECLINE
                      _callButton(
                        color: Colors.red,
                        icon: Icons.call_end,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),

                      /// ACCEPT
                      _callButton(
                        color: Colors.green,
                        icon: Icons.call,
                        onTap: () {
                          setState(() {
                            isCalling = false;
                          });
                        },
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const SizedBox(height: 20),

                      /// END CALL
                      _callButton(
                        color: Colors.red,
                        icon: Icons.call_end,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
