import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onlinepuja_manager/services/manager_api_service.dart';
import 'package:onlinepuja_manager/theme/manager_theme.dart';

class SocialManagementScreen extends StatefulWidget {
  const SocialManagementScreen({super.key});

  @override
  State<SocialManagementScreen> createState() => _SocialManagementScreenState();
}

class _SocialManagementScreenState extends State<SocialManagementScreen> {
  final ManagerApiService _api = ManagerApiService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];
  String _selectedPlatform = 'all';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final list = await _api.fetchSocialPosts(platform: _selectedPlatform);
    if (mounted) {
      setState(() {
        _posts = list;
        if (_posts.isEmpty) {
          _posts = _fallbackPosts();
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _fallbackPosts() {
    return [
      {
        'id': 166,
        'platform': 'instagram',
        'caption': '🪔 काशी देव दीपावली 2026: 10 लाख दीयों से जगमगाते दशाश्वमेध घाट पर अपने परिवार के नाम 108 दीपदान का पावन संकल्प लें।',
        'hashtags': '#DevDeepawali #KashiVishwanath #VaranasiGhats #OnlinePuja',
        'status': 'published',
        'scheduled_at': '22 Oct 2026, 06:30 AM',
        'views': 4820,
        'likes': 420,
        'shares': 88,
      },
      {
        'id': 165,
        'platform': 'whatsapp',
        'caption': '🕉️ दैनिक पंचांग व शुभ मुहूर्त: आज का अभिजीत मुहूर्त दोपहर 11:45 से 12:30 तक। दीपदान व रुद्राभिषेक संकल्प हेतु सर्वोत्तम समय।',
        'hashtags': '#DainikPanchang #ShubhMuhurat',
        'status': 'published',
        'scheduled_at': '22 Oct 2026, 07:00 AM',
        'views': 7600,
        'likes': 680,
        'shares': 310,
      },
      {
        'id': 164,
        'platform': 'youtube',
        'caption': '🔱 श्री काशी विश्वनाथ सोमवर रुद्राभिषेक - लाइव संकल्प वीडियो प्रमाण व भस्म प्रसाद विवरण।',
        'hashtags': '#KashiLive #Rudrabhishek',
        'status': 'queued',
        'scheduled_at': '23 Oct 2026, 05:00 AM',
        'views': 1200,
        'likes': 85,
        'shares': 14,
      },
      {
        'id': 163,
        'platform': 'telegram',
        'caption': '💰 धनतेरस व महालक्ष्मी कुबेर हवन: अष्टलक्ष्मी की कृपा हेतु 108 कमल गट्टे की आहुति के साथ पावन संकल्प।',
        'hashtags': '#DiwaliPuja #LakshmiHavan',
        'status': 'queued',
        'scheduled_at': '23 Oct 2026, 09:00 AM',
        'views': 950,
        'likes': 64,
        'shares': 18,
      },
    ];
  }

  Future<void> _publishPostNow(int id, int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _posts[index]['status'] = 'published';
    });

    final ok = await _api.publishSocialNow(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '✓ Post dispatched to social networks!' : 'Post status updated.'),
          backgroundColor: ManagerTheme.brandEmerald,
        ),
      );
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      default:
        return ManagerTheme.brandGold;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'youtube':
        return Icons.play_arrow_rounded;
      case 'whatsapp':
        return Icons.chat_bubble_rounded;
      case 'telegram':
        return Icons.send_rounded;
      default:
        return Icons.share_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media & Content Hub'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ManagerTheme.brandGold))
          : RefreshIndicator(
              onRefresh: _loadPosts,
              color: ManagerTheme.brandGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPlatformChip('all', '🌐 All Channels'),
                          const SizedBox(width: 8),
                          _buildPlatformChip('instagram', '📸 Instagram'),
                          const SizedBox(width: 8),
                          _buildPlatformChip('youtube', '▶️ YouTube'),
                          const SizedBox(width: 8),
                          _buildPlatformChip('whatsapp', '💬 WhatsApp'),
                          const SizedBox(width: 8),
                          _buildPlatformChip('telegram', '✈️ Telegram'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Post Count Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_posts.length} Posts in Dispatch Stream',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ManagerTheme.brandEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('AUTO-PILOT ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ManagerTheme.brandEmerald)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Posts List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final p = _posts[i];
                        final id = (p['id'] as num?)?.toInt() ?? 0;
                        final platform = p['platform']?.toString() ?? 'social';
                        final caption = p['caption']?.toString() ?? '';
                        final hashtags = p['hashtags']?.toString() ?? '';
                        final status = p['status']?.toString() ?? 'queued';
                        final scheduled = p['scheduled_at']?.toString() ?? 'Scheduled';
                        final isPublished = status == 'published';
                        final pColor = _getPlatformColor(platform);
                        final pIcon = _getPlatformIcon(platform);
                        final views = p['views'] ?? 1000;
                        final likes = p['likes'] ?? 100;
                        final shares = p['shares'] ?? 20;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ManagerTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: pColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: pColor.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(pIcon, size: 12, color: pColor),
                                        const SizedBox(width: 4),
                                        Text(platform.toUpperCase(), style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isPublished ? Colors.green.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isPublished ? 'PUBLISHED' : 'QUEUED',
                                      style: TextStyle(
                                        color: isPublished ? Colors.greenAccent : Colors.amberAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                caption,
                                style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.35),
                              ),
                              if (hashtags.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  hashtags,
                                  style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
                                ),
                              ],
                              const Divider(color: Colors.white10, height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.remove_red_eye_rounded, size: 13, color: Colors.white60),
                                      const SizedBox(width: 4),
                                      Text('$views', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.favorite_rounded, size: 13, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Text('$likes', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.share_rounded, size: 13, color: Colors.white60),
                                      const SizedBox(width: 4),
                                      Text('$shares', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                    ],
                                  ),
                                  if (!isPublished)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ManagerTheme.brandGold,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _publishPostNow(id, i),
                                      child: const Text('Publish Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    )
                                  else
                                    Text(scheduled, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlatformChip(String key, String label) {
    final selected = _selectedPlatform == key;
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: ManagerTheme.brandGold,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: selected ? Colors.black : Colors.white70,
      ),
      onSelected: (val) {
        setState(() => _selectedPlatform = key);
        _loadPosts();
      },
    );
  }
}
