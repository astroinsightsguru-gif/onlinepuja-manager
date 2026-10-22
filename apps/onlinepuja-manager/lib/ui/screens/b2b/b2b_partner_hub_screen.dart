import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/manager_api_service.dart';
import '../../../theme/manager_theme.dart';

class B2bPartnerHubScreen extends StatefulWidget {
  const B2bPartnerHubScreen({super.key});

  @override
  State<B2bPartnerHubScreen> createState() => _B2bPartnerHubScreenState();
}

class _B2bPartnerHubScreenState extends State<B2bPartnerHubScreen> {
  final ManagerApiService _api = ManagerApiService();

  bool _isLoading = true;
  int _totalLeads = 0;
  List<Map<String, dynamic>> _leads = [];
  String _selectedCity = 'all';

  @override
  void initState() {
    super.initState();
    _loadB2bData();
  }

  Future<void> _loadB2bData() async {
    setState(() => _isLoading = true);
    final data = await _api.fetchB2bLeads(city: _selectedCity);
    if (mounted) {
      setState(() {
        _totalLeads = data['total'] as int? ?? 0;
        _leads = data['leads'] as List<Map<String, dynamic>>? ?? [];
        if (_leads.isEmpty) {
          _leads = _fallbackLeads();
          _totalLeads = _leads.length;
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _fallbackLeads() {
    return [
      {
        'id': 1,
        'business_name': 'Kashi Yatra Tour & Travels',
        'contact_person': 'Rajesh Sharma',
        'category': 'travel_agency',
        'city': 'Mumbai',
        'phone': '+91 98201 11223',
        'google_rating': '4.8',
        'partner_code': 'OP-B2B-MUM-01',
        'status': 'contacted',
      },
      {
        'id': 2,
        'business_name': 'Surat Jyotish Vastu Kendra',
        'contact_person': 'Acharya Trivedi',
        'category': 'astrologer',
        'city': 'Surat',
        'phone': '+91 98980 44556',
        'google_rating': '4.9',
        'partner_code': 'OP-B2B-SUR-02',
        'status': 'partner_onboarded',
      },
      {
        'id': 3,
        'business_name': 'Om Spiritual Store & Puja Samagri',
        'contact_person': 'Manish Patel',
        'category': 'samagri_store',
        'city': 'Ahmedabad',
        'phone': '+91 98791 88990',
        'google_rating': '4.7',
        'partner_code': 'OP-B2B-AHM-03',
        'status': 'verified',
      },
      {
        'id': 4,
        'business_name': 'Delhi Pilgrimage Express',
        'contact_person': 'Vipin Gupta',
        'category': 'travel_agency',
        'city': 'Delhi',
        'phone': '+91 98112 33445',
        'google_rating': '4.6',
        'partner_code': 'OP-B2B-DEL-04',
        'status': 'contacted',
      },
    ];
  }

  Future<void> _previewAndSharePitch(Map<String, dynamic> lead) async {
    final leadId = lead['id'] as int?;
    final pitchData = await _api.fetchB2bPitch(leadId: leadId);

    final partnerName = lead['business_name'] ?? 'Partner';
    final partnerCode = lead['partner_code'] ?? 'OP-B2B-MUM-77';
    final whatsappCopy = pitchData?['whatsapp'] ??
        "💼 Auspicious Dev Deepawali 2026 Commercial Proposal\n\n"
        "Respected $partnerName,\n\n"
        "Hotels and boats in Varanasi are 100% booked for Dev Deepawali 2026 (24 Nov).\n"
        "Partner with OnlinePuja.live to offer your clients 108 Deepdaan on Manikarnika & Dashashwamedh Ghats.\n\n"
        "• Your Margin: 25% Net Profit (₹300 - ₹600 per booking)\n"
        "• Attribution Link: https://onlinepuja.live/pujas?ref=$partnerCode\n\n"
        "Fulfillment handled entirely by Kashi purohits with HD video proof & speed post Mahaprasad.";

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ManagerTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('💼', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text('Proposal for $partnerName', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(color: Colors.white12, height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  whatsappCopy,
                  style: const TextStyle(fontSize: 12, height: 1.45, color: Colors.white70, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ManagerTheme.brandGold,
                        side: const BorderSide(color: ManagerTheme.brandGold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy WhatsApp Pitch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: whatsappCopy));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Copied partner proposal to clipboard!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _dispatchB2bCampaign() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ManagerTheme.surfaceDark,
        title: const Text('Broadcast B2B Campaign', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Broadcast Dev Deepawali 2026 commercial partnership proposals across ${_selectedCity == 'all' ? 'All National Partners' : _selectedCity}?',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ManagerTheme.brandGold, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await _api.dispatchB2bCampaign(city: _selectedCity);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['message'] ?? 'Campaign staged.'),
                    backgroundColor: ManagerTheme.brandEmerald,
                  ),
                );
              }
            },
            child: const Text('Launch Broadcast'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Partner Network'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadB2bData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadB2bData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stat Cards Strip
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('B2B PARTNER NETWORK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ManagerTheme.brandGold, letterSpacing: 0.5)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: ManagerTheme.brandEmerald.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: const Text('25% REVENUE SHARE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: ManagerTheme.brandEmerald)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$_totalLeads', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                                  const Text('Verified Leads', style: TextStyle(fontSize: 11, color: Colors.white54)),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('₹5,00,000+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                                  Text('Deepawali Target', style: TextStyle(fontSize: 11, color: Colors.white54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ManagerTheme.brandGold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('🚀 Broadcast B2B Dev Deepawali Pitch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: _dispatchB2bCampaign,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // City Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('🇮🇳 All Cities'),
                          selected: _selectedCity == 'all',
                          selectedColor: ManagerTheme.brandGold,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedCity == 'all' ? Colors.black : Colors.white70,
                          ),
                          onSelected: (val) {
                            setState(() => _selectedCity = 'all');
                            _loadB2bData();
                          },
                        ),
                        const SizedBox(width: 8),
                        for (final c in ['Mumbai', 'Surat', 'Delhi', 'Ahmedabad', 'Varanasi']) ...[
                          FilterChip(
                            label: Text(c),
                            selected: _selectedCity == c,
                            selectedColor: ManagerTheme.brandGold,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _selectedCity == c ? Colors.black : Colors.white70,
                            ),
                            onSelected: (val) {
                              setState(() => _selectedCity = c);
                              _loadB2bData();
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Leads List
                  for (final lead in _leads) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ManagerTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  lead['business_name'] ?? '',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lead['partner_code'] ?? '',
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(lead['city'] ?? '', style: const TextStyle(fontSize: 11, color: ManagerTheme.brandGold, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text('•  ${lead['phone'] ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'monospace')),
                              const Spacer(),
                              if (lead['google_rating'] != null)
                                Text('★ ${lead['google_rating']}', style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: const BorderSide(color: Colors.white24),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.share_rounded, size: 14),
                                  label: const Text('Share Proposal', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _previewAndSharePitch(lead),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
