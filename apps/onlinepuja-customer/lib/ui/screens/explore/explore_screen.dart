import 'package:flutter/material.dart';
import '../../theme/customer_theme.dart';
import '../../widgets/customer_widgets.dart';

import '../blog/blog_screen.dart';
import '../charity/annadaan_screen.dart';
import '../cosmic_ai_screen.dart';
import '../darshan/live_darshan_screen.dart';
import '../horoscope/daily_horoscope_screen.dart';
import '../japa/japa_mala_screen.dart';
import '../kundli/kundli_list_screen.dart';
import '../kundli/kundli_matching_screen.dart';
import '../mall/mall_screen.dart';
import '../panchang/panchang_screen.dart';
import '../panchang/choghadiya_radar_screen.dart';
import '../puja/puja_list_screen.dart';
import '../puja/sankalp_vault_screen.dart';
import '../kp/kp_calendar_screen.dart';
import '../orders/prasadam_tracker_screen.dart';
import 'prashna_oracle_screen.dart';
import 'swapna_shastra_screen.dart';
import 'vedic_audio_screen.dart';
import 'sankalp_blessing_card_dialog.dart';
import '../kundli/dosha_remedy_bridge.dart';
import '../shorts/spiritual_shorts_screen.dart';

/// Explore sanctum: Sacred spiritual tools, Vedic rituals & AstroMall
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const route = '/explore';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'OnlinePuja',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
              const TextSpan(
                text: '.live',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD97706),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: CustomerTheme.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_rounded, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? CustomerTheme.cosmicDarkGradient
              : const LinearGradient(
                  colors: [
                    Color(0xFFFFFBEB),
                    Color(0xFFFAF7F2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Muhurat Radar Card
              _muhuratRadar(context, isDark),
              const SizedBox(height: 12),

              // 2. Cosmic Mantra & Vibrations Banner
              _cosmicMantraCard(context),
              const SizedBox(height: 20),

              // 3. Section: Vedic Astrology & Astrological Charts
              const SectionHeader(
                title: 'Vedic Astrology & Guidance',
                subtitle: 'Planetary alignments, birth charts & future insights',
                icon: Icons.auto_graph_rounded,
              ),
              const SizedBox(height: 8),
              _featuresGrid(
                context,
                [
                  _FeatureItem(
                    title: 'Kundli',
                    subtitle: 'Birth chart, planets & dasha',
                    icon: Icons.auto_graph_rounded,
                    badge: 'POPULAR',
                    gradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
                    screen: const KundliListScreen(),
                  ),
                  _FeatureItem(
                    title: 'Kundli Matching',
                    subtitle: '36 Guna Milan & compatibility',
                    icon: Icons.favorite_rounded,
                    badge: 'FREE',
                    gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
                    screen: const KundliMatchingScreen(),
                  ),
                  _FeatureItem(
                    title: 'Horoscope',
                    subtitle: 'Daily predictions by sign',
                    icon: Icons.nightlight_round,
                    gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    screen: const DailyHoroscopeScreen(),
                  ),
                  _FeatureItem(
                    title: 'Panchang',
                    subtitle: "Today's almanac",
                    icon: Icons.wb_twilight_rounded,
                    gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    screen: const PanchangScreen(),
                  ),
                  _FeatureItem(
                    title: 'Choghadiya Radar',
                    subtitle: 'Live Shubh/Labh & Rahu Kaal',
                    icon: Icons.timer_outlined,
                    badge: 'LIVE MUHURAT',
                    gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    screen: const ChoghadiyaRadarScreen(),
                  ),
                  _FeatureItem(
                    title: 'KP Calendar',
                    subtitle: '249 Sub-Lords & Ruling Planets',
                    icon: Icons.shield_moon_rounded,
                    badge: 'KP SYSTEM',
                    gradient: const [Color(0xFF4F46E5), Color(0xFF3730A3)],
                    screen: const KpCalendarScreen(),
                  ),
                  _FeatureItem(
                    title: 'Prashna Oracle',
                    subtitle: 'Instant Horary answers & guidance',
                    icon: Icons.psychology_alt_rounded,
                    gradient: const [Color(0xFF06B6D4), Color(0xFF0E7490)],
                    screen: const PrashnaOracleScreen(),
                  ),
                  _FeatureItem(
                    title: 'Swapna Shastra',
                    subtitle: 'Decode spiritual dream omens',
                    icon: Icons.bedtime_rounded,
                    gradient: const [Color(0xFF6366F1), Color(0xFF4338CA)],
                    screen: const SwapnaShastraScreen(),
                  ),
                  _FeatureItem(
                    title: 'Dosha Remedies',
                    subtitle: 'Manglik, Kaal Sarp & Sade Sati',
                    icon: Icons.shield_outlined,
                    badge: 'VEDIC REMEDIES',
                    gradient: const [Color(0xFFE11D48), Color(0xFF9F1239)],
                    onTap: () => DoshaRemedySheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Section: Sacred Rituals & Worship
              const SectionHeader(
                title: 'Sacred Rituals & Worship',
                subtitle: 'Online Pujas, live holy darshan & charity',
                icon: Icons.local_fire_department_rounded,
              ),
              const SizedBox(height: 8),
              _featuresGrid(
                context,
                [
                  _FeatureItem(
                    title: 'Vedic Audio OTT',
                    subtitle: 'Chanting, Chalisa & Aartis',
                    icon: Icons.music_note_rounded,
                    badge: 'SACRED AUDIO',
                    gradient: const [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                    screen: const VedicAudioScreen(),
                  ),
                  _FeatureItem(
                    title: 'Blessing Card',
                    subtitle: 'Personalized WhatsApp Ashirwad',
                    icon: Icons.card_giftcard_rounded,
                    badge: 'WHATSAPP CARD',
                    gradient: const [Color(0xFFD97706), Color(0xFF92400E)],
                    onTap: () => SankalpBlessingCardDialog.show(context),
                  ),
                  _FeatureItem(
                    title: 'Puja',
                    subtitle: 'Book sacred pujas',
                    icon: Icons.local_fire_department_rounded,
                    badge: 'LIVE SANKALP',
                    gradient: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
                    screen: const PujaListScreen(),
                  ),
                  _FeatureItem(
                    title: 'Sankalp Vault',
                    subtitle: 'Ritual videos & Prasad courier AWB',
                    icon: Icons.video_collection_rounded,
                    badge: 'VAULT',
                    gradient: const [Color(0xFFEA580C), Color(0xFFC2410C)],
                    screen: const SankalpVaultScreen(),
                  ),
                  _FeatureItem(
                    title: 'Live Darshan',
                    subtitle: 'Kashi, Somnath & Ganga Aarti',
                    icon: Icons.temple_hindu_rounded,
                    badge: 'LIVE 24/7',
                    gradient: const [Color(0xFFF59E0B), Color(0xFFB45309)],
                    screen: const LiveDarshanScreen(),
                  ),
                  _FeatureItem(
                    title: 'Spiritual Shorts',
                    subtitle: 'Daily AI Reels & Shubh Muhurat',
                    icon: Icons.play_circle_fill_rounded,
                    badge: 'REELS',
                    gradient: const [Color(0xFFE11D48), Color(0xFF9F1239)],
                    screen: const SpiritualShortsScreen(),
                  ),
                  _FeatureItem(
                    title: '108 Japa Mala',
                    subtitle: 'Digital Rudraksha mantra counter',
                    icon: Icons.fingerprint_rounded,
                    gradient: const [Color(0xFF10B981), Color(0xFF047857)],
                    screen: const JapaMalaScreen(),
                  ),
                  _FeatureItem(
                    title: 'Annadaan & Seva',
                    subtitle: 'Gau seva & holy temple charity',
                    icon: Icons.volunteer_activism_rounded,
                    badge: 'PUNYA',
                    gradient: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
                    screen: const AnnadaanScreen(),
                  ),
                  _FeatureItem(
                    title: 'Prasad Tracker',
                    subtitle: 'Track holy temple dispatch & AWB',
                    icon: Icons.delivery_dining_rounded,
                    badge: 'DOORSTEP',
                    gradient: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                    screen: const PrasadamTrackerScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Section: Cosmic Mall & Wisdom
              const SectionHeader(
                title: 'AstroMall & Cosmic AI',
                subtitle: 'Energized remedies, certified gems & AI chats',
                icon: Icons.storefront_rounded,
              ),
              const SizedBox(height: 8),
              _featuresGrid(
                context,
                [
                  _FeatureItem(
                    title: 'AstroMall',
                    subtitle: 'Gemstones & spiritual items',
                    icon: Icons.storefront_rounded,
                    badge: 'CERTIFIED',
                    gradient: const [Color(0xFFF97316), Color(0xFFC2410C)],
                    screen: const MallScreen(),
                  ),
                  _FeatureItem(
                    title: 'OnlinePuja AI',
                    subtitle: 'Acharya Vashistha • 24/7 Vedic Astrologer',
                    icon: Icons.auto_awesome,
                    badge: 'INTELLIGENT AI',
                    gradient: const [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
                    screen: const OnlinePujaAiScreen(),
                  ),
                  _FeatureItem(
                    title: 'Vedic Blogs',
                    subtitle: 'Planetary transits & wisdom',
                    icon: Icons.menu_book_rounded,
                    gradient: const [Color(0xFF059669), Color(0xFF065F46)],
                    screen: const BlogScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _muhuratRadar(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final hour = now.hour;
    final isAuspicious = hour >= 11 && hour <= 13;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAuspicious
            ? CustomerTheme.sacredEmerald.withValues(alpha: isDark ? 0.15 : 0.1)
            : CustomerTheme.brandGold.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAuspicious
              ? CustomerTheme.sacredEmerald.withValues(alpha: 0.35)
              : CustomerTheme.brandGold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAuspicious
                  ? CustomerTheme.sacredEmerald.withValues(alpha: 0.2)
                  : CustomerTheme.brandGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAuspicious ? Icons.verified_rounded : Icons.schedule_rounded,
              color: isAuspicious
                  ? CustomerTheme.sacredEmerald
                  : CustomerTheme.brandGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAuspicious
                      ? 'Abhijit Muhurat Active - Highly Auspicious'
                      : 'Rahu Kaal Radar - Favorable Window Ahead',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: isAuspicious
                        ? (isDark ? Colors.greenAccent : const Color(0xFF065F46))
                        : (isDark ? Colors.amberAccent : const Color(0xFF78350F)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAuspicious
                      ? 'Ideal time for new investments, prayers, and consultations'
                      : 'Next auspicious window: 11:45 AM - 12:35 PM',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cosmicMantraCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: CustomerTheme.heroCosmicGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CustomerTheme.brandGold.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: CustomerTheme.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CustomerTheme.brandGold.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Text('Om', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Daily Cosmic Vibrations',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Mantra: Om Namah Shivaya - Chant 11x for inner peace',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomerTheme.brandSaffron,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const JapaMalaScreen()),
              );
            },
            child: const Text(
              'Chant',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresGrid(BuildContext context, List<_FeatureItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final f = items[i];
        return SacredCard(
          padding: const EdgeInsets.all(12),
          elevation: 1,
          onTap: f.onTap ??
              (f.screen != null
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => f.screen!),
                      )
                  : null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: f.gradient),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: f.gradient.first.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(f.icon, color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  if (f.badge != null)
                    SacredBadge(
                      label: f.badge!,
                      fontSize: 8.5,
                      color: CustomerTheme.brandGold.withValues(alpha: 0.2),
                      textColor: CustomerTheme.brandDarkGold,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                f.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                f.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureItem {
  _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.screen,
    this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget? screen;
  final VoidCallback? onTap;
  final String? badge;
}

