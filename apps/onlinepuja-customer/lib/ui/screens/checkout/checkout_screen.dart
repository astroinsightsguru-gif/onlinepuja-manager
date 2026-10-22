import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:op_shared/op_shared.dart';
import 'package:provider/provider.dart';

import '../../../state/app_session.dart';
import '../profile/wallet_screen.dart';
import '../profile/family_gotra_vault_screen.dart';
import '../history/history_screen.dart';

/// Unified checkout for AstroMall products and Puja packages
/// (legacy `checkoutScreen.dart` + `deliveryAddressScreen.dart`).
///
/// Flow: pick/add delivery address → place order (`userOrder/add` for
/// products, `placedPujaOrder` for pujas — both wallet-funded server-side).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen.product({super.key, required this.product})
      : puja = null,
        package = null;

  const CheckoutScreen.puja({
    super.key,
    required this.puja,
    required this.package,
  }) : product = null;

  final Product? product;
  final Puja? puja;
  final PujaPackage? package;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<OrderAddress>? _addresses;
  OrderAddress? _selected;
  bool _loading = true;
  bool _placing = false;
  Object? _error;

  late final TextEditingController _devoteeNameCtrl;
  late final TextEditingController _gotraCtrl;
  late final TextEditingController _sankalpWishCtrl;
  late final TextEditingController _whatsappCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppSession>().user;
    _devoteeNameCtrl = TextEditingController(text: user?.name ?? '');
    _gotraCtrl = TextEditingController(text: '');
    _sankalpWishCtrl = TextEditingController(text: '');
    _whatsappCtrl = TextEditingController(text: user?.contactNo ?? '');
    _loadAddresses();
    _loadGotraVault();
  }

  Future<void> _loadGotraVault() async {
    final userId = context.read<AppSession>().user?.id ?? 0;
    if (userId > 0) {
      try {
        final vault = await MiscApi.instance.getGotraVault(userId: userId);
        final gotra = vault['gotra']?.toString();
        if (gotra != null && gotra.isNotEmpty && mounted) {
          setState(() {
            _gotraCtrl.text = gotra;
          });
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _devoteeNameCtrl.dispose();
    _gotraCtrl.dispose();
    _sankalpWishCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  double get _price {
    final p = widget.product;
    if (p != null) return p.displayPrice;
    return widget.package?.priceValue ?? 0;
  }

  String get _title {
    final p = widget.product;
    if (p != null) return p.name?.toString() ?? 'Product';
    return widget.puja?.title?.toString() ?? 'Puja';
  }

  Future<void> _loadAddresses() async {
    final userId = context.read<AppSession>().user?.id ?? 0;
    try {
      final list = await MiscApi.instance.addresses(userId: userId);
      if (!mounted) return;
      setState(() {
        _addresses = list;
        _selected ??= list.isEmpty ? null : list.first;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _addAddress() async {
    final created = await showAddAddressSheet(context);
    if (created == null) return;
    setState(() {
      _addresses = [...?_addresses, created];
      _selected = created;
    });
  }

  Future<void> _placeOrder() async {
    final session = context.read<AppSession>();
    final userId = session.user?.id ?? 0;
    if (userId == 0) {
      showSnack(context, 'Log in to place an order', error: true);
      return;
    }
    final address = _selected;
    if (address == null) {
      showSnack(context, 'Add a delivery address first.', error: true);
      return;
    }
    setState(() => _placing = true);
    try {
      final product = widget.product;
      if (product != null) {
        await MallApi.instance.placeOrder(
          userId: userId,
          productId: product.id,
          categoryId: product.categoryId,
          addressId: address.id,
          payableAmount: _price,
          totalPayable: _price,
        );
      } else {
        final res = await PujaApi.instance.placeOrder(
          userId: userId,
          pujaId: widget.puja!.id,
          packageId: widget.package!.id,
          extra: {
            'orderAddressId': address.id,
            'addressId': address.id,
            'amount': _price,
            'devoteeName': _devoteeNameCtrl.text.trim().isNotEmpty
                ? _devoteeNameCtrl.text.trim()
                : (context.read<AppSession>().user?.name ?? 'Devotee'),
            'gotra': _gotraCtrl.text.trim().isNotEmpty
                ? _gotraCtrl.text.trim()
                : 'Kashyap',
            'sankalpWish': _sankalpWishCtrl.text.trim().isNotEmpty
                ? _sankalpWishCtrl.text.trim()
                : 'Health, Prosperity & Peace',
            'whatsappNumber': _whatsappCtrl.text.trim(),
          },
        );
        final redirectUrl = res['redirect']?.toString();
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          if (!mounted) return;
          final payOnline = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Recharge or Pay Online'),
              content: const Text(
                  'Your wallet balance is insufficient for this Puja. Would you like to proceed with secure online payment?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Pay Online'),
                ),
              ],
            ),
          );
          if (payOnline == true) {
            await launchUrl(Uri.parse(redirectUrl),
                mode: LaunchMode.externalApplication);
            if (!mounted) return;
            session.refreshUser();
            final viewHistory = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Payment Initiated 🙏'),
                content: const Text(
                    'Once your payment is completed on the secure gateway, your order is automatically confirmed and sanctified. You can view and track your order updates in My Bookings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Close'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('View Bookings'),
                  ),
                ],
              ),
            );
            if (!mounted) return;
            if (viewHistory == true) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => HistoryScreen(initialTabIndex: widget.product != null ? 2 : 1)),
              );
            } else {
              Navigator.of(context).popUntil((r) => r.isFirst);
            }
          }
          return;
        }
      }
      session.refreshUser();
      if (!mounted) return;
      final viewHistory = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 48),
          title: const Text('Order placed 🙏'),
          content: Text(
              '$_title ordered successfully. We will notify you at every step.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Done'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('View Bookings'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (viewHistory == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HistoryScreen(initialTabIndex: widget.product != null ? 2 : 1)),
        );
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final msg = e.message.toLowerCase();
      if (msg.contains('insufficient') || msg.contains('balance') || msg.contains('wallet')) {
        final recharge = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Insufficient Wallet Balance'),
            content: Text(
                'Your wallet balance is insufficient for this order (₹${_price.toStringAsFixed(0)} required). Would you like to recharge your wallet now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Recharge Wallet'),
              ),
            ],
          ),
        );
        if (recharge == true && mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const WalletScreen(),
          ));
        }
        return;
      }
      showSnack(context, e.message, error: true);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = context.read<AppSession>().flags.currency;

    // Theme-adaptive color palette
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A);
    final headerText = isDark ? const Color(0xFFF59E0B) : const Color(0xFF92400E);
    final subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final fieldFill = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final fieldBorder = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final fieldTextColor = textPrimary;

    final inputDecorationTheme = InputDecoration(
      filled: true,
      fillColor: fieldFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: TextStyle(color: subText, fontSize: 13),
      hintStyle: TextStyle(color: subText.withValues(alpha: 0.7), fontSize: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
      ),
    );

    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocaleManager.instance.currentLanguage,
      builder: (context, lang, _) {
        final isHi = lang != AppLanguage.en;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.puja != null
                  ? (isHi ? 'वैदिक संकल्प एवं दक्षिणा' : 'Puja Booking & Sankalp')
                  : (isHi ? 'ऑर्डर चेकआउट' : AppStrings.checkout),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: (_placing || _loading) ? null : _placeOrder,
                child: Center(
                  child: _placing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          widget.puja != null
                              ? (isHi
                                  ? 'दक्षिणा अर्पित करें एवं संकल्प लें · $currency${_price.toStringAsFixed(0)}'
                                  : '${AppStrings.placeOrder} · $currency${_price.toStringAsFixed(0)}')
                              : '${AppStrings.placeOrder} · $currency${_price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? StatusViews.error(context, _error!, onRetry: _loadAddresses)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.puja != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.25)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.temple_hindu_rounded,
                                    size: 20, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.sankalpInformation,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: headerText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.sankalpNotice,
                              style: TextStyle(
                                  fontSize: 12, color: subText, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _devoteeNameCtrl,
                              style: TextStyle(color: fieldTextColor, fontSize: 13.5),
                              decoration: inputDecorationTheme.copyWith(
                                labelText: AppStrings.devoteeName,
                                prefixIcon: Icon(Icons.person_outline, size: 20, color: subText),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _gotraCtrl,
                                    style: TextStyle(color: fieldTextColor, fontSize: 13.5),
                                    decoration: inputDecorationTheme.copyWith(
                                      labelText: AppStrings.gotraHint,
                                      hintText: 'e.g. Kashyap, Bharadwaj',
                                      prefixIcon: Icon(Icons.stars_outlined, size: 20, color: subText),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.account_tree_outlined, size: 18, color: Color(0xFFF59E0B)),
                                        tooltip: AppStrings.familyGotraVault,
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const FamilyGotraVaultScreen()),
                                          );
                                          _loadGotraVault();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _whatsappCtrl,
                                    style: TextStyle(color: fieldTextColor, fontSize: 13.5),
                                    keyboardType: TextInputType.phone,
                                    decoration: inputDecorationTheme.copyWith(
                                      labelText: AppStrings.whatsappNumber,
                                      prefixIcon: Icon(
                                          Icons.phone_iphone_rounded,
                                          size: 20,
                                          color: subText),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _sankalpWishCtrl,
                              style: TextStyle(color: fieldTextColor, fontSize: 13.5),
                              decoration: inputDecorationTheme.copyWith(
                                labelText: AppStrings.sankalpWish,
                                hintText: AppStrings.sankalpWishHint,
                                prefixIcon: Icon(
                                    Icons.volunteer_activism_outlined,
                                    size: 20,
                                    color: subText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Text(
                        widget.puja != null
                            ? AppStrings.deliverHolyPrasadTo
                            : AppStrings.deliverTo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        )),
                    const SizedBox(height: 10),
                    if (_addresses == null || _addresses!.isEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorder),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.add_location_alt_outlined,
                              color: Color(0xFFF59E0B)),
                          title: Text(AppStrings.addDeliveryAddress,
                              style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                          onTap: _addAddress,
                        ),
                      )
                    else ...[
                      for (final a in _addresses!)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _selected == a
                                    ? const Color(0xFFF59E0B)
                                    : cardBorder,
                                width: _selected == a ? 1.5 : 1),
                          ),
                          child: RadioListTile<OrderAddress>(
                            value: a,
                            // ignore: deprecated_member_use
                            groupValue: _selected,
                            // ignore: deprecated_member_use
                            onChanged: (v) => setState(() => _selected = v),
                            activeColor: const Color(0xFFF59E0B),
                            title: Text(a.name?.toString() ?? 'Address',
                                style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                            subtitle: Text(a.fullAddress,
                                style: TextStyle(fontSize: 12, color: textSecondary)),
                            secondary: Text(a.phone?.toString() ?? '',
                                style: TextStyle(fontSize: 12, color: textSecondary)),
                          ),
                        ),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addAddress,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(AppStrings.newAddress),
                    ),
                    const Divider(height: 32),
                    _row(AppStrings.orderItem, _title, textPrimary, textSecondary),
                    _row(AppStrings.orderPrice, '$currency${_price.toStringAsFixed(0)}', textPrimary, textSecondary),
                    _row(
                        AppStrings.orderPayment,
                        '${AppStrings.walletBalanceText} $currency${context.read<AppSession>().user?.walletAmount.toStringAsFixed(0) ?? '0'}',
                        textPrimary,
                        textSecondary,
                        isHighlight: true),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.walletDeductNotice,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _row(String label, String value, Color textPrimary, Color textSecondary,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 14.5 : 13.5,
              fontWeight: FontWeight.w800,
              color: isHighlight ? const Color(0xFF10B981) : textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet form to create a delivery address
/// (legacy `orderAddress/add`). Returns the created [OrderAddress].
Future<OrderAddress?> showAddAddressSheet(BuildContext context) async {
  final name = TextEditingController();
  final phone = TextEditingController();
  final line1 = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final pincode = TextEditingController();
  final saving = ValueNotifier<bool>(false);

  Future<void> save() async {
    if (name.text.trim().isEmpty || line1.text.trim().isEmpty) return;
    saving.value = true;
    try {
      final session = context.read<AppSession>();
      final created = await MiscApi.instance.addAddress(
        userId: session.user?.id ?? 0,
        address: {
          'name': name.text.trim(),
          'phone': phone.text.trim(),
          'addressLine1': line1.text.trim(),
          'city': city.text.trim(),
          'state': state.text.trim(),
          'pincode': pincode.text.trim(),
          'country': 'India',
        },
      );
      if (context.mounted) Navigator.pop(context, created);
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.message, error: true);
    } finally {
      saving.value = false;
    }
  }

  final created = await showModalBottomSheet<OrderAddress>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New delivery address',
              style: Theme.of(ctx)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          TextField(
            controller: phone,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: line1,
            decoration: const InputDecoration(
                labelText: 'Address (house, street, area)'),
          ),
          Row(children: [
            Expanded(
                child: TextField(controller: city,
                    decoration:
                        const InputDecoration(labelText: 'City'))),
            const SizedBox(width: 10),
            Expanded(
                child: TextField(controller: state,
                    decoration:
                        const InputDecoration(labelText: 'State'))),
          ]),
          TextField(
            controller: pincode,
            decoration: const InputDecoration(labelText: 'PIN code'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<bool>(
            valueListenable: saving,
            builder: (_, busy, _) => FilledButton(
              onPressed: busy ? null : save,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save address'),
            ),
          ),
        ],
      ),
    ),
  );
  for (final c in [name, phone, line1, city, state, pincode]) {
    c.dispose();
  }
  return created;
}
