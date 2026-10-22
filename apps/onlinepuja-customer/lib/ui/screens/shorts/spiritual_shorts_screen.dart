import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/customer_theme.dart';
import '../puja/puja_list_screen.dart';

/// Full-screen vertical swipeable Spiritual Shorts & Daily AI Reels Feed
class SpiritualShortsScreen extends StatefulWidget {
  const SpiritualShortsScreen({super.key, this.initialIndex = 0});

  static const route = '/spiritual-shorts';
  final int initialIndex;

  @override
  State<SpiritualShortsScreen> createState() => _SpiritualShortsScreenState();
}

class _SpiritualShortsScreenState extends State<SpiritualShortsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _shorts = [];
  final Set<String> _likedIds = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _loadShorts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadShorts() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('https://onlinepuja.live/api/feed/shorts'),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final items = List<Map<String, dynamic>>.from(decoded['data']);
          if (mounted) {
            setState(() {
              _shorts = items;
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _shorts = _fallbackShorts();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _fallbackShorts() {
    return [
      {
        'id': 'kashi_deepdaan_2026',
        'title': '🪔 Dev Deepawali 108 Deepdaan at Dashashwamedh Ghat',
        'category': 'Dev Deepawali 2026',
        'icon': '🪔',
        'thumbnail_url': 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=1080&q=80',
        'caption': 'Witness 10 Lakh sacred lamps illuminating the holy ghats of Varanasi on Kartik Purnima. Offer your family gotra sankalp with sanctum video proof.',
        'cta_label': 'Offer 108 Deepdaan ₹1,500',
        'cta_route': '/puja-list',
        'likes_count': 4820,
        'views_count': 18400,
        'shares_count': 1240,
        'is_liked': true,
      },
      {
        'id': 'panchang_daily_reel',
        'title': '☀️ Dainik Vedic Panchang & Shubh Muhurat',
        'category': 'Dainik Panchang',
        'icon': '🕉️',
        'thumbnail_url': 'https://images.unsplash.com/photo-1596402184320-417e7178b2cd?auto=format&fit=crop&w=1080&q=80',
        'caption': 'Today Tithi, Nakshatra, Abhijit Muhurat & Rahu Kaal. Discover the most auspicious hour for sacred deeds and gotra sankalp.',
        'cta_label': 'View Pujas & Muhurat',
        'cta_route': '/puja-list',
        'likes_count': 3120,
        'views_count': 12100,
        'shares_count': 840,
        'is_liked': false,
      },
      {
        'id': 'rudrabhishek_kashi',
        'title': '🔱 Shri Kashi Vishwanath Somwar Rudrabhishek',
        'category': 'Jyotirlinga Seva',
        'icon': '🔱',
        'thumbnail_url': 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=1080&q=80',
        'caption': 'Panchamrit Abhishek with sacred Ganga Jal and sacred Bhasma. Individual Gotra recitation for removal of planetary doshas and health.',
        'cta_label': 'Book Rudrabhishek ₹1,501',
        'cta_route': '/puja-list',
        'likes_count': 6100,
        'views_count': 24500,
        'shares_count': 1950,
        'is_liked': false,
      },
    ];
  }

  void _toggleLike(String shortId, int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_likedIds.contains(shortId)) {
        _likedIds.remove(shortId);
        _shorts[index]['likes_count'] = (_shorts[index]['likes_count'] as int) - 1;
      } else {
        _likedIds.add(shortId);
        _shorts[index]['likes_count'] = (_shorts[index]['likes_count'] as int) + 1;
      }
    });

    http.post(
      Uri.parse('https://onlinepuja.live/api/feed/shorts/like'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'short_id': shortId}),
    ).catchError((_) => http.Response('', 500));
  }

  void _shareShort(Map<String, dynamic> item) {
    HapticFeedback.lightImpact();
    final title = item['title'] ?? 'Spiritual Reel';
    final shareText = '🕉️ Watch "$title" on OnlinePuja.live:\nhttps://onlinepuja.live/shorts?id=${item['id']}\n\nExperience divine blessings with family Gotra Sankalp.';
    final waUrl = 'https://wa.me/?text=${Uri.encodeComponent(shareText)}';
    launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: CustomerTheme.brandGold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _shorts.length,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemBuilder: (context, index) {
              final item = _shorts[index];
              return _buildShortPage(item, index);
            },
          ),

          // Top App Bar Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪔', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'Shorts ${_currentIndex + 1}/${_shorts.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortPage(Map<String, dynamic> item, int index) {
    final shortId = item['id'].toString();
    final isLiked = _likedIds.contains(shortId) || (item['is_liked'] == true && !_likedIds.contains('unliked_$shortId'));
    final likesCount = item['likes_count'] ?? 1000;
    final viewsCount = item['views_count'] ?? 5000;
    final thumbUrl = item['thumbnail_url'] ?? '';
    final title = item['title'] ?? 'Sacred Vedic Reel';
    final category = item['category'] ?? 'Devotional';
    final caption = item['caption'] ?? '';
    final ctaLabel = item['cta_label'] ?? 'Book Sacred Puja';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image / Video Poster
        if (thumbUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumbUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: const Color(0xFF0F172A)),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF0F172A),
              child: const Center(child: Icon(Icons.temple_hindu_rounded, size: 64, color: Colors.white30)),
            ),
          )
        else
          Container(color: const Color(0xFF0F172A)),

        // High-Contrast Dark Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.95),
              ],
              stops: const [0.0, 0.35, 0.75, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Center Pulsing Play / Reel Indicator
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
          ),
        ),

        // Right-Side Action Bar
        Positioned(
          right: 14,
          bottom: 120,
          child: Column(
            children: [
              // Like Button
              GestureDetector(
                onTap: () => _toggleLike(shortId, index),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: isLiked ? CustomerTheme.brandGold : Colors.white24),
                      ),
                      child: Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? Colors.redAccent : Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$likesCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Share Button
              GestureDetector(
                onTap: () => _shareShort(item),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.share_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 4),
                    const Text('Share', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Views Count
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.remove_red_eye_rounded, color: Colors.white70, size: 24),
                  ),
                  const SizedBox(height: 4),
                  Text('$viewsCount', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        // Bottom Info & CTA
        Positioned(
          left: 16,
          right: 80,
          bottom: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CustomerTheme.brandAmber.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CustomerTheme.brandGold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: CustomerTheme.brandGold, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Caption
              Text(
                caption,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Prominent Action Button
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.brandGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(Icons.flare_rounded, size: 18),
                  label: Text(ctaLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PujaListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
