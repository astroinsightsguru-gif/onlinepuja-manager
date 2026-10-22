import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:op_shared/op_shared.dart';
import '../../../app.dart';

/// Combined 3-tab order & consultation history center:
/// - Consultations (Chat & Call)
/// - Puja Bookings & Doorstep Prasadam Tracker
/// - AstroMall Product Orders
class HistoryScreen extends StatefulWidget {
  static const route = '/history';

  final int initialTabIndex;

  const HistoryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _consultationsFuture;
  late Future<List<Map<String, dynamic>>> _pujaOrdersFuture;
  late Future<List<Map<String, dynamic>>> _mallOrdersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _reloadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadAll() {
    setState(() {
      _consultationsFuture = _loadConsultations();
      _pujaOrdersFuture = _loadPujaOrders();
      _mallOrdersFuture = _loadMallOrders();
    });
  }

  Future<List<Map<String, dynamic>>> _loadConsultations() async {
    try {
      final uid = SessionStore.instance.user?.id;
      final decoded = await ApiClient.instance.post('/getallhistorydetail', body: {
        if (uid != null && uid > 0) 'userId': uid,
      });
      if (decoded is Map<String, dynamic>) {
        final rl = decoded['recordList'];
        if (rl is List) return rl.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<Map<String, dynamic>>> _loadPujaOrders() async {
    try {
      final uid = SessionStore.instance.user?.id;
      final decoded = await ApiClient.instance.post('/getUserPujaOrders', body: {
        if (uid != null && uid > 0) 'userId': uid,
      });
      if (decoded is Map<String, dynamic>) {
        final rl = decoded['recordList'];
        if (rl is List) return rl.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<Map<String, dynamic>>> _loadMallOrders() async {
    try {
      final uid = SessionStore.instance.user?.id;
      final decoded = await ApiClient.instance.post('/getUserOrders', body: {
        if (uid != null && uid > 0) 'userId': uid,
      });
      if (decoded is Map<String, dynamic>) {
        final rl = decoded['recordList'];
        if (rl is List) return rl.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order & Session History'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandSaffron,
          labelColor: AppTheme.brandSaffron,
          unselectedLabelColor: scheme.outline,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Consultations'),
            Tab(text: 'Puja & Seva'),
            Tab(text: 'AstroMall'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Consultations
          RefreshIndicator(
            onRefresh: () async => _reloadAll(),
            child: _buildConsultationsTab(),
          ),
          // Tab 2: Puja Orders
          RefreshIndicator(
            onRefresh: () async => _reloadAll(),
            child: _buildPujaOrdersTab(),
          ),
          // Tab 3: AstroMall Orders
          RefreshIndicator(
            onRefresh: () async => _reloadAll(),
            child: _buildMallOrdersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _consultationsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return StatusViews.skeletonList(context, items: 5);
        }
        if (snap.hasError) {
          return ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: StatusViews.error(context, snap.error!, onRetry: _reloadAll),
              ),
            ],
          );
        }
        final items = snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No consultation sessions yet — start a chat or call with an astrologer.'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _consultationRow(context, items[i]),
        );
      },
    );
  }

  Widget _consultationRow(BuildContext context, Map<String, dynamic> row) {
    final scheme = Theme.of(context).colorScheme;
    final type = row['type']?.toString() ?? 'session';
    final name = row['astrologerName']?.toString() ?? row['name']?.toString() ?? 'Astrologer';
    final amount = double.tryParse(row['amount']?.toString() ?? '') ?? 0;
    final minutes = int.tryParse(row['minutes']?.toString() ?? '') ?? 0;
    final date = row['created_at']?.toString() ?? '';
    final isCall = type.toLowerCase().contains('call');

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            isCall ? Icons.call_rounded : Icons.chat_rounded,
            color: scheme.primary,
          ),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          [if (date.isNotEmpty) date.split('T').first, if (minutes > 0) '$minutes min'].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '₹${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppTheme.brandSaffron),
        ),
      ),
    );
  }

  Widget _buildPujaOrdersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pujaOrdersFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return StatusViews.skeletonList(context, items: 3);
        }
        final items = snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No Puja bookings found. Book a sacred temple ritual or holy Annadaan seva.'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _pujaOrderCard(context, items[i]),
        );
      },
    );
  }

  Widget _pujaOrderCard(BuildContext context, Map<String, dynamic> row) {
    final scheme = Theme.of(context).colorScheme;
    final id = row['id']?.toString() ?? '';
    final name = (row['puja_name'] ?? row['pujaTitle'] ?? 'Vedic Temple Puja').toString();
    final amount = row['order_total_price'] ?? row['totalPrice'] ?? row['order_price'] ?? 0;
    final status = (row['puja_order_status'] ?? row['orderStatus'] ?? 'Confirmed').toString();
    final date = (row['created_at'] ?? '').toString();
    final temple = (row['templeLocation'] ?? row['puja_place'] ?? 'Kashi Vishwanath Sanctum, Varanasi').toString();
    final packageTitle = (row['packageTitle'] ?? row['package_name'] ?? '').toString();
    final videoUrl = (row['videoUrl'] ?? row['puja_video'] ?? '').toString().trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.brandSaffron.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Order #OP-PUJA-$id', style: const TextStyle(color: AppTheme.brandSaffron, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(status, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (packageTitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(packageTitle, style: TextStyle(color: AppTheme.brandSaffron, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Text('₹$amount', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              if (date.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('• ${date.split("T").first}', style: TextStyle(color: scheme.outline, fontSize: 12)),
              ],
            ],
          ),
          if (videoUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                label: const Text('📹 Watch Sacred Sankalp Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                onPressed: () async {
                  final uri = Uri.tryParse(videoUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.brandSaffron),
                foregroundColor: AppTheme.brandSaffron,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Track Doorstep Prasadam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              onPressed: () {
                context.openPrasadamTracker(
                  orderId: 'OP-PUJA-$id',
                  pujaName: name,
                  temple: temple,
                  trackingCode: 'BD-${id}9824',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMallOrdersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _mallOrdersFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return StatusViews.skeletonList(context, items: 3);
        }
        final items = snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No AstroMall orders yet. Explore certified gemstones, yantras, and rudrakshas.'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final row = items[i];
            final name = (row['productName'] ?? row['name'] ?? 'AstroMall Item').toString();
            final price = row['productAmount'] ?? row['productPrice'] ?? row['amount'] ?? 0;
            final date = (row['created_at'] ?? '').toString();

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.amber),
                ),
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(date.isNotEmpty ? date.split('T').first : 'Dispatched', style: const TextStyle(fontSize: 11.5)),
                trailing: Text('₹$price', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            );
          },
        );
      },
    );
  }
}
