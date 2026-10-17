import 'package:flutter/material.dart';
import 'package:onlinepuja_manager/theme/manager_theme.dart';

class LiveRadarScreen extends StatefulWidget {
  const LiveRadarScreen({super.key});

  @override
  State<LiveRadarScreen> createState() => _LiveRadarScreenState();
}

class _LiveRadarScreenState extends State<LiveRadarScreen> {
  bool _isLoading = false;
  final double _todayGmv = 48500.0;
  final int _activeAstrologers = 14;
  final int _ongoingCalls = 3;
  final int _pendingSankalps = 8;
  final int _totalOrdersToday = 27;

  final List<Map<String, dynamic>> _recentOrders = const [
    {
      'id': 'OP-PUJA-1049',
      'devotee': 'Rohan Sharma',
      'gotra': 'Kashyap',
      'puja': 'Varanasi Dev Deepawali 108 Deepdaan',
      'amount': '₹1,500',
      'status': 'Confirmed',
      'time': '10 mins ago'
    },
    {
      'id': 'OP-CONSULT-892',
      'devotee': 'Ananya Verma',
      'gotra': 'Vashistha',
      'puja': 'Call Consultation with Acharya Shastri',
      'amount': '₹650',
      'status': 'Completed',
      'time': '24 mins ago'
    },
    {
      'id': 'OP-PUJA-1048',
      'devotee': 'Amitabh Trivedi',
      'gotra': 'Bharadwaj',
      'puja': 'Shri Kashi Vishwanath Rudrabhishek',
      'amount': '₹2,100',
      'status': 'Awaiting Video',
      'time': '42 mins ago'
    },
    {
      'id': 'OP-PUJA-1047',
      'devotee': 'Pooja Agarwal',
      'gotra': 'Garg',
      'puja': 'Diwali Maha Lakshmi Havan',
      'amount': '₹5,100',
      'status': 'Confirmed',
      'time': '1 hour ago'
    },
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: ManagerTheme.executiveGold,
                shape: BoxShape.circle,
              ),
              child: const Text('ॐ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OnlinePuja Manager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                Text('Varanasi Live Operations Hub', style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ManagerTheme.brandGold),
            onPressed: _refresh,
          ),
        ],
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: ManagerTheme.brandGold,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: ManagerTheme.brandGold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Executive GMV Card
              _buildGmvHeroCard(),
              const SizedBox(height: 16),

              // 2. 4-Grid Operations Radar
              _buildOperationsRadarGrid(),
              const SizedBox(height: 20),

              // 3. Live Order Stream
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Bookings Stream',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ManagerTheme.brandEmerald.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: ManagerTheme.brandEmerald),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ManagerTheme.brandEmerald)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final o = _recentOrders[i];
                  return _buildOrderRow(o);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGmvHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ManagerTheme.brandAmber.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S ESTIMATED GMV",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Q4 PEAK SEASON', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_todayGmv.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          const Text(
            "+42% vs last week · Puja Sankalps & Astrologer Calls driving growth",
            style: TextStyle(fontSize: 11.5, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsRadarGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Active Pandits',
            value: '$_activeAstrologers',
            subtitle: '$_ongoingCalls ongoing calls',
            icon: Icons.person_search_rounded,
            color: ManagerTheme.brandSapphire,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            title: 'Sankalp Queue',
            value: '$_pendingSankalps',
            subtitle: '$_totalOrdersToday total today',
            icon: Icons.local_fire_department_rounded,
            color: ManagerTheme.brandEmerald,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ManagerTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> o) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ManagerTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: ManagerTheme.brandGold.withValues(alpha: 0.15),
            child: const Text('🪔', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o['puja'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  "${o['devotee']} (${o['gotra']} Gotra) · ${o['time']}",
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                o['amount'],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: ManagerTheme.brandGold),
              ),
              const SizedBox(height: 2),
              Text(
                o['status'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: o['status'] == 'Confirmed' ? ManagerTheme.brandEmerald : Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
