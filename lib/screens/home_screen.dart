import '../services/trusted_contact_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/location_service.dart';
import '../services/panic_alert_service.dart';
import 'fake_call_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import '../services/audio_recording_service.dart';
import '../services/audio_upload_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendPanicAlert() async {
    if (await AudioRecordingService.hasPermission()) {
  await AudioRecordingService.startRecording();
  print('Audio recording started');
}
    print('NEW CODE RUNNING');

    try {
      final position = await LocationService.getCurrentLocation();

      print('LAT: ${position.latitude}');
      print('LNG: ${position.longitude}');

      print(Supabase.instance.client.auth.currentUser?.id);

      final alert = await PanicAlertService.createAlert(
  latitude: position.latitude,
  longitude: position.longitude,
);

print('PANIC ALERT ID: ${alert['id']}');
final fileName =
    AudioUploadService.generateFileName(alert['id']);

print('AUDIO FILE NAME: $fileName');
print('ALERT RESPONSE: $alert');

      final contacts = await TrustedContactService.getTrustedContacts();

      final message = '''
🚨 EMERGENCY ALERT

I may be in danger.

My location:
https://maps.google.com/?q=${position.latitude},${position.longitude}

Please contact me immediately.
''';

      final recipients = contacts
          .map((contact) => contact['phone_number'].toString())
          .toList();

      try {
        String result = await sendSMS(
          message: message,
          recipients: recipients,
        );

        print(result);

        print('SMS function executed');
      } catch (e) {
        print('SMS ERROR: $e');
      }

      print(message);

      print('Trusted contacts found: ${contacts.length}');

      for (final contact in contacts) {
        print(contact['name']);
        print(contact['phone_number']);
      }

      final primaryContact = contacts.firstWhere(
        (contact) => contact['is_primary'] == true,
      );

      final primaryPhone = primaryContact['phone_number'];

      final Uri callUri = Uri(
        scheme: 'tel',
        path: primaryPhone,
      );

      await launchUrl(callUri);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Primary phone: $primaryPhone'),
        ),
      );

      print('Trusted contacts found: ${contacts.length}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trusted contacts found: ${contacts.length}'),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Panic Alert Sent Successfully'),
        ),
      );
    } catch (e) {
      print('FULL ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7F7FD5),
              Color(0xFF6EA8FF),
              Color(0xFF91EAE4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                 ElevatedButton(
    onPressed: () async {
      final path = await AudioRecordingService.stopRecording();
      print('RECORDED FILE PATH: $path');
      print('RECORDING STOPPED SUCCESSFULLY');
    },
    child: const Text('Stop Recording'),
  ),


                /// 🔥 HERO PANIC
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    double scale = 1 + (_controller.value * 0.06);
                    double glow = 20 + (_controller.value * 25);

                    return Transform.scale(
                      scale: scale,
                      child: GestureDetector(
                        onTap: _sendPanicAlert,
                        child: _GlassCard(
                          height: 130,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Panic Alert",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Tap to send emergency alert",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF3B3B),
                                      Color(0xFFFF6B6B),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.6),
                                      blurRadius: glow,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                /// 🔥 CARDS
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _FeatureCard.large(
                              icon: Icons.people, title: "Trusted Circle"),
                          const SizedBox(height: 12),
                          _FeatureCard.small(
                              icon: Icons.timer, title: "Check-in"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [

                          /// 📞 FAKE CALL (CLICKABLE)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FakeCallScreen(),
                                ),
                              );
                            },
                            child: _FeatureCard.small(
                                icon: Icons.phone, title: "Fake Call"),
                          ),

                          const SizedBox(height: 12),
                          _FeatureCard.large(
                              icon: Icons.location_on,
                              title: "Live Location"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// GLASS CARD
class _GlassCard extends StatelessWidget {
  final Widget child;
  final double height;

  const _GlassCard({required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.18),
      ),
      child: child,
    );
  }
}

////////////////////////////////////////////////////////////
/// FEATURE CARD
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double height;

  const _FeatureCard.large({required this.icon, required this.title})
      : height = 140;

  const _FeatureCard.small({required this.icon, required this.title})
      : height = 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

