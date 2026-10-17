import 'package:flutter/material.dart';
import '../../theme/manager_theme.dart';
import 'dashboard/live_radar_screen.dart';
import 'studio/banner_puja_studio_screen.dart';
import 'fulfillment/sankalp_fulfillment_screen.dart';
import 'growth/growth_broadcast_screen.dart';

class ManagerShell extends StatefulWidget {
  const ManagerShell({super.key});

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LiveRadarScreen(),
    BannerPujaStudioScreen(),
    SankalpFulfillmentScreen(),
    GrowthBroadcastScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: ManagerTheme.surfaceDark,
        indicatorColor: ManagerTheme.brandGold.withValues(alpha: 0.25),
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_rounded),
            selectedIcon: Icon(Icons.radar_rounded, color: ManagerTheme.brandGold),
            label: 'Radar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_fix_high_rounded),
            selectedIcon: Icon(Icons.auto_fix_high_rounded, color: ManagerTheme.brandGold),
            label: 'Studio',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_rounded),
            selectedIcon: Icon(Icons.local_shipping_rounded, color: ManagerTheme.brandGold),
            label: 'Sankalp',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_rounded),
            selectedIcon: Icon(Icons.campaign_rounded, color: ManagerTheme.brandGold),
            label: 'Growth',
          ),
        ],
      ),
    );
  }
}
