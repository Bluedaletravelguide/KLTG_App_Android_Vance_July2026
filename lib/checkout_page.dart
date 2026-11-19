import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/basket_service.dart';
import 'package:kltheguide/services/api_service.dart';

const String _bankName = 'Alliance Bank Malaysia Berhad';
const String _bankAccountName = 'Bluedale Publishing (M) Sdn Bhd';
const String _bankAccountNumber = '1218-10-010008-350';
const String _orderEmail = 'enquiry@bluedale.com.my';

// Labuan, Sabah, Sarawak (sama macam EAST_MALAYSIA_RANGES dalam PHP)
const List<List<int>> _eastRanges = [
  [87000, 87999],
  [88000, 91999],
  [93000, 98999],
];

const List<String> _states = [
  'Johor',
  'Kedah',
  'Kelantan',
  'Melaka',
  'Negeri Sembilan',
  'Pahang',
  'Perak',
  'Perlis',
  'Pulau Pinang',
  'Sabah',
  'Sarawak',
  'Selangor',
  'Terengganu',
  'Kuala Lumpur',
  'Labuan',
  'Putrajaya',
];

bool _isEast(int postcode) =>
    _eastRanges.any((r) => postcode >= r[0] && postcode <= r[1]);

class CheckoutPage extends StatefulWidget {
  final List<BasketEntry> entries;

  const CheckoutPage({super.key, required this.entries});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _postcode = TextEditingController();

  late final Map<int, int> _qty;
  String? _state;
  PlatformFile? _receipt;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _qty = {for (final e in widget.entries) e.id: e.qty};
  }

  @override
  void dispose() {
    _scroll.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _postcode.dispose();
    super.dispose();
  }

  // null = postcode belum lengkap / tak valid
  String? get _region {
    final pc = _postcode.text.trim();
    if (!RegExp(r'^\d{5}$').hasMatch(pc)) return null;
    return _isEast(int.parse(pc)) ? 'east' : 'peninsular';
  }

  double _unit(BasketEntry e, String region) =>
      region == 'east' ? e.eastPrice : e.peninsularPrice;

  // Shipping sentiasa 0 (dah termasuk dalam harga)
  double? get _total {
    final region = _region;
    if (region == null) return null;
    return widget.entries
        .fold<double>(0, (sum, e) => sum + _unit(e, region) * _qty[e.id]!);
  }

  void _changeQty(BasketEntry e, int delta) {
    final next = (_qty[e.id]! + delta).clamp(1, e.stock < 1 ? 1 : e.stock);
    setState(() => _qty[e.id] = next);
  }

  Future<void> _pickReceipt() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _receipt = res.files.single);
    }
  }

  // Urutan semakan sama macam checkout.php
  String? _validate() {
    if (widget.entries.length != 1) {
      return 'Please order one book at a time. Return to your basket and remove the other books.';
    }
    final email = _email.text.trim();
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (_name.text.trim().isEmpty ||
        !emailOk ||
        _phone.text.trim().isEmpty ||
        _address.text.trim().isEmpty ||
        _state == null) {
      return 'Please complete all customer details.';
    }
    if (_region == null) return 'Please enter a valid 5-digit postcode.';
    final r = _receipt;
    if (r == null || r.path == null || r.size > 5 * 1024 * 1024) {
      return 'Please upload a JPG, PNG, or PDF payment receipt up to 5 MB.';
    }
    return null;
  }

  void _showError(String msg) {
    setState(() => _error = msg);
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onSubmit() async {
    if (_submitting) return;
    final err = _validate();
    if (err != null) {
      _showError(err);
      return;
    }
    setState(() => _error = null);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _confirmDialog(ctx),
    );
    if (confirmed == true) await _send();
  }

  Future<void> _send() async {
    setState(() => _submitting = true);
    final result = await submitOrder(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      state: _state!,
      postcode: _postcode.text.trim(),
      product: widget.entries.single.title,
      quantity: _qty[widget.entries.single.id]!,
      unitPrice: _unit(widget.entries.single, _region!),
      receiptPath: _receipt!.path!,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      BasketService.instance.clear();
      Navigator.pop(context, result.message);
    } else {
      _showError(result.message);
    }
  }

  Widget _confirmDialog(BuildContext ctx) {
    final region = _region!;
    final names = widget.entries.map((e) => '${e.title} × ${_qty[e.id]}');
    final units = widget.entries
        .map((e) => 'RM ${_unit(e, region).toStringAsFixed(2)}')
        .toSet()
        .join(' / ');
    final count = _qty.values.fold<int>(0, (a, b) => a + b);

    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '$k: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: v),
            ]),
          ),
        );

    return AlertDialog(
      title: const Text('Please confirm your order'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            row('Book', names.join(', ')),
            row('Quantity', '$count'),
            row('Unit price', units),
            row('Total', 'RM ${_total!.toStringAsFixed(2)}'),
            const Divider(),
            row('Name', _name.text.trim()),
            row('Email', _email.text.trim()),
            row('Phone', _phone.text.trim()),
            row('Address', _address.text.trim()),
            row('State', _state ?? '-'),
            row('Postcode', _postcode.text.trim()),
            row('Receipt', _receipt?.name ?? '-'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Go back & edit'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Confirm & send'),
        ),
      ],
    );
  }

  InputDecoration _dec(HomePalette p, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: p.textSecondary.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, size: 18, color: p.textSecondary),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: p.accent, width: 1.5),
      ),
    );
  }

  Widget _field(HomePalette p, String label, Widget input) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          input,
        ],
      ),
    );
  }

  Widget _panel(HomePalette p, String title, IconData icon, List<Widget> kids) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: p.accent.withValues(alpha: 0.15),
                child: Icon(icon, size: 18, color: p.accent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...kids,
        ],
      ),
    );
  }

  Widget _orderItem(HomePalette p, BasketEntry e) {
    final region = _region;
    final line = region == null
        ? '-'
        : (_unit(e, region) * _qty[e.id]!).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            height: 108,
            child: Image.network(
              e.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.menu_book_outlined, color: p.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Peninsular RM ${e.peninsularPrice.toStringAsFixed(2)} · '
                  'East Malaysia RM ${e.eastPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(color: p.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _changeQty(e, -1),
                            icon: Icon(Icons.remove, size: 18, color: p.accent),
                          ),
                          Text(
                            '${_qty[e.id]}',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _changeQty(e, 1),
                            icon: Icon(Icons.add, size: 18, color: p.accent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Line total: RM $line',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final total = _total;
    final hasSoldOut = widget.entries.any((e) => e.stock < 1);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
        title: Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: p.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E3A5B), Color(0xFF087398)],
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'SECURE  •  SIMPLE  •  FAST',
                    style: TextStyle(
                      color: Color(0xFF08B4D3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Complete Your Purchase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Fill in your details and confirm your order. We will take care of the rest!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFB42318)),
                ),
              ),

            // YOUR ORDER
            _panel(p, 'YOUR ORDER', Icons.shopping_cart_outlined, [
              for (final e in widget.entries) _orderItem(p, e),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEFAFD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment by bank transfer',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF173B58),
                      ),
                    ),
                    SizedBox(height: 8),
                    _BankRow('Bank', _bankName),
                    _BankRow('Account name', _bankAccountName),
                    _BankRow('Account number', _bankAccountNumber),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F8FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: p.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      total == null ? '-' : 'RM ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: p.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            // YOUR DETAILS
            _panel(p, 'YOUR DETAILS', Icons.person, [
              _field(
                p,
                'Full Name *',
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      _dec(p, 'Enter your full name', Icons.person_outline),
                ),
              ),
              _field(
                p,
                'Email *',
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec(p, 'you@example.com', Icons.mail_outline),
                ),
              ),
              _field(
                p,
                'Phone Number *',
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _dec(p, '+60 12 345 6789', Icons.phone_outlined),
                ),
              ),
              _field(
                p,
                'Full Delivery Address (We do not deliver to pure box numbers) *',
                TextField(
                  controller: _address,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _dec(
                      p, 'Enter your full address', Icons.location_on_outlined),
                ),
              ),
              _field(
                p,
                'State *',
                DropdownButtonFormField<String>(
                  value: _state,
                  isExpanded: true,
                  hint: const Text('Select your state'),
                  decoration: _dec(p, '', Icons.map_outlined),
                  items: [
                    for (final s in _states)
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (v) => setState(() => _state = v),
                ),
              ),
              _field(
                p,
                'Postcode *',
                TextField(
                  controller: _postcode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration:
                      _dec(p, 'e.g. 81300', Icons.markunread_mailbox_outlined),
                ),
              ),
              _field(
                p,
                'Payment Receipt *',
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickReceipt,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _receipt?.name ?? 'Choose JPG, PNG or PDF (max 5 MB)',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.accent,
                    minimumSize: const Size.fromHeight(46),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: (_submitting || hasSoldOut) ? null : _onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: _submitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('SENDING RECEIPT...'),
                          ],
                        )
                      : const Text(
                          'SEND PAYMENT RECEIPT',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'For purchases outside Malaysia, please email us at $_orderEmail.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.textSecondary, fontSize: 13),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF173B58),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF173B58), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
