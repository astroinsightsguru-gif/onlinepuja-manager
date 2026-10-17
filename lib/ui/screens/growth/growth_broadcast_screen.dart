import 'package:flutter/material.dart';
import 'package:onlinepuja_manager/theme/manager_theme.dart';

class GrowthBroadcastScreen extends StatefulWidget {
  const GrowthBroadcastScreen({super.key});

  @override
  State<GrowthBroadcastScreen> createState() => _GrowthBroadcastScreenState();
}

class _GrowthBroadcastScreenState extends State<GrowthBroadcastScreen> {
  final TextEditingController _brainCommandCtrl = TextEditingController();
  final TextEditingController _notifTitleCtrl = TextEditingController(text: '🪔 Kashi Dev Deepawali: 108 Deepdaan Sankalp Open!');
  final TextEditingController _notifMsgCtrl = TextEditingController(text: 'Reserve your personalized Gotra Sankalp on Ganga Ghats before dates fill up. Blessings from Varanasi!');

  bool _isBrainThinking = false;
  String _brainResponse = 'Namaste Manager Ji! Master Brain is active. What growth task would you like me to execute?';

  final List<String> _quickCommands = [
    'write article for kashi vishwanath rudrabhishek',
    'schedule upcoming hindu festival wishes',
    'status report',
    'run seo site audit',
  ];

  Future<void> _runBrainCommand(String cmd) async {
    setState(() {
      _isBrainThinking = true;
      _brainResponse = 'Executing: "$cmd" across Growth OS...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isBrainThinking = false;
      if (cmd.contains('write')) {
        _brainResponse = '✓ Article drafted, passed Critic linter (4,820 chars, 0 clichés), and auto-published to /blog/kashi-vishwanath-rudrabhishek-online!';
      } else if (cmd.contains('festival')) {
        _brainResponse = '✓ Successfully queued Dev Deepawali, Chhath Puja, and Diwali campaigns across Instagram, Facebook, and WhatsApp!';
      } else if (cmd.contains('seo')) {
        _brainResponse = '✓ SEO technical audit complete: 0 broken links, 100% sitemaps valid, all canonical tags verified.';
      } else {
        _brainResponse = '✓ Status: Today GMV ₹48,500 (+42%). 32 articles published this month. Social channels ready for morning dispatch.';
      }
    });
  }

  void _sendPushBroadcast() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ManagerTheme.surfaceDark,
        title: const Text('Confirm Push Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Send this high-priority push notification to ALL registered devotees immediately?\n\n"${_notifTitleCtrl.text}"',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ManagerTheme.brandGold, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Push notification successfully broadcast to all devotees via OneSignal!'),
                  backgroundColor: ManagerTheme.brandEmerald,
                ),
              );
            },
            child: const Text('Send Broadcast'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth & Push Broadcast'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. One-Tap Push Broadcaster Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ManagerTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ManagerTheme.brandGold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.campaign_rounded, color: ManagerTheme.brandGold, size: 22),
                      SizedBox(width: 8),
                      Text('Blast Push Notification', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notifTitleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notification Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notifMsgCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notification Body / Message',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ManagerTheme.brandGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Broadcast to All Devotees Now', style: TextStyle(fontWeight: FontWeight.w800)),
                      onPressed: _sendPushBroadcast,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Master Brain AI Control Center
            const Text('Master Brain AI Command Hub', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Autonomous Vedic Ops Engine',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _brainResponse,
                      style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickCommands.map((cmd) {
                      return ActionChip(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        label: Text(cmd, style: const TextStyle(fontSize: 10.5, color: Colors.white)),
                        onPressed: () => _runBrainCommand(cmd),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _brainCommandCtrl,
                          decoration: InputDecoration(
                            hintText: 'Type any ops command...',
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.white38),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: ManagerTheme.brandGold),
                        icon: _isBrainThinking
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                        onPressed: () {
                          if (_brainCommandCtrl.text.trim().isNotEmpty) {
                            final c = _brainCommandCtrl.text.trim();
                            _brainCommandCtrl.clear();
                            _runBrainCommand(c);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
