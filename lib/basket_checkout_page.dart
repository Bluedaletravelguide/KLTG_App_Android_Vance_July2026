import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/services/book_basket_service.dart';

Map<String, dynamic>? _decodeCheckoutResponse(String body) {
  final normalized = body.replaceFirst('\uFEFF', '').trim();
  final candidates = <String>[normalized];
  final responseObjects = RegExp(
    r'\{[^{}]*"success"\s*:\s*(?:true|false)[^{}]*\}',
    dotAll: true,
  );
  candidates.addAll(
    responseObjects.allMatches(normalized).map((match) => match.group(0)!),
  );

  for (final candidate in candidates) {
    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } on FormatException {
      continue;
    }
  }
  return null;
}

class BasketCheckoutPage extends StatefulWidget {
  final List<BasketItem> items;

  const BasketCheckoutPage({super.key, required this.items});

  @override
  State<BasketCheckoutPage> createState() => _BasketCheckoutPageState();
}

class _BasketCheckoutPageState extends State<BasketCheckoutPage> {
  static const _teal = Color(0xFF0B597B);
  static const _brightTeal = Color(0xFF08A1BF);
  static const _paleBlue = Color(0xFFEAF7FB);
  static const _states = [
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
  static const _eastMalaysiaRanges = [
    (87000, 87999),
    (88000, 91999),
    (93000, 98999),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postcodeController = TextEditingController();
  String? _state;
  PlatformFile? _receipt;
  bool _isSending = false;
  bool _submissionUnconfirmed = false;

  String get _postcode => _postcodeController.text.trim();
  bool get _hasValidPostcode => RegExp(r'^\d{5}$').hasMatch(_postcode);
  bool get _isEastMalaysia {
    final postcode = int.tryParse(_postcode) ?? -1;
    return _eastMalaysiaRanges
        .any((range) => postcode >= range.$1 && postcode <= range.$2);
  }

  String get _regionLabel => _isEastMalaysia ? 'East Malaysia' : 'Peninsular';

  double _unitPrice(BasketItem item) {
    final isOtherBook = item.category == 'OtherBooks';
    if (isOtherBook) return _isEastMalaysia ? 179.90 : 159.90;
    return _isEastMalaysia ? 22.90 : 17.90;
  }

  double get _total => widget.items.fold(
        0,
        (total, item) => total + _unitPrice(item) * item.quantity,
      );

  @override
  void initState() {
    super.initState();
    _postcodeController.addListener(_onPostcodeChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postcodeController
      ..removeListener(_onPostcodeChanged)
      ..dispose();
    super.dispose();
  }

  void _onPostcodeChanged() => setState(() {});

  String _money(double value) => 'RM ${value.toStringAsFixed(2)}';

  InputDecoration _decoration(String label, IconData icon, String hint) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: _teal.withValues(alpha: 0.55)),
        labelStyle: const TextStyle(
            color: _teal, fontWeight: FontWeight.w700, fontSize: 12),
        hintStyle:
            TextStyle(color: _teal.withValues(alpha: 0.45), fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: _teal.withValues(alpha: 0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: _teal.withValues(alpha: 0.18)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: _brightTeal, width: 1.5),
        ),
      );

  Future<void> _pickReceipt() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      if (!mounted || result == null) return;
      final receipt = result.files.single;
      if (receipt.bytes == null || receipt.bytes!.isEmpty) {
        throw Exception('Could not read the selected file.');
      }
      if (receipt.size > 5 * 1024 * 1024) {
        throw Exception('Receipt must be 5 MB or smaller.');
      }
      setState(() => _receipt = receipt);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to select receipt: $error')),
        );
      }
    }
  }

  Future<void> _reviewOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_receipt?.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your payment receipt.')),
      );
      return;
    }
    final confirmed = await _showConfirmation();
    if (confirmed == true) await _submitOrder();
  }

  Future<bool?> _showConfirmation() => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _brightTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.fact_check_outlined,
                    color: _brightTeal, size: 21),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review your order',
                      style: TextStyle(
                        color: _teal,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Check your details before sending',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _confirmationSectionTitle('ORDER ITEMS'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _paleBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0;
                          index < widget.items.length;
                          index++) ...[
                        if (index > 0)
                          Divider(
                            height: 1,
                            color: _teal.withValues(alpha: 0.12),
                          ),
                        _confirmationItem(widget.items[index]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ORDER TOTAL',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                          ],
                        ),
                      ),
                      Text(
                        _money(_total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _confirmationSectionTitle('DELIVERY DETAILS'),
                _confirmationDetail('Name', _nameController.text.trim()),
                _confirmationDetail('Email', _emailController.text.trim()),
                _confirmationDetail('Phone', _phoneController.text.trim()),
                _confirmationDetail('Address', _addressController.text.trim()),
                _confirmationDetail(
                  'Location',
                  '${_postcodeController.text.trim()}, $_state',
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FAFC),
                    border: Border.all(color: _teal.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.attach_file,
                          color: _brightTeal, size: 17),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          _receipt?.name ?? '-',
                          style: const TextStyle(
                            color: _teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Text(
                    'PAYMENT RECEIPT',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: _teal),
              child: const Text('EDIT DETAILS'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.send_outlined, size: 16),
              label: const Text('CONFIRM & SEND'),
              style: FilledButton.styleFrom(
                backgroundColor: _brightTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _confirmationSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(
          title,
          style: const TextStyle(
            color: _brightTeal,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      );

  Widget _confirmationItem(BasketItem item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _money(_unitPrice(item) * item.quantity),
              style: const TextStyle(
                color: _teal,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  Widget _confirmationDetail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 62,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: _teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _submitOrder() async {
    setState(() => _isSending = true);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(kApiUrl));
      request.fields.addAll({
        'appCheckout': 'true',
        'items': jsonEncode(widget.items.map((item) {
          final id = int.tryParse(item.id);
          if (id == null || id <= 0) {
            throw Exception('A basket item is missing its book ID.');
          }
          return {'ebook_id': id, 'quantity': item.quantity};
        }).toList()),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'state': _state!,
        'postcode': _postcode,
      });
      request.files.add(http.MultipartFile.fromBytes(
        'receipt',
        _receipt!.bytes!,
        filename: _receipt!.name,
      ));

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      final decoded = _decodeCheckoutResponse(response.body);
      if (decoded == null) {
        if (mounted) {
          setState(() => _submissionUnconfirmed = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'The order may have been received. Check your email before trying again.',
              ),
              duration: Duration(seconds: 8),
            ),
          );
        }
        return;
      }
      if (decoded['success'] != true) {
        final message = decoded['message'] ??
            decoded['error'] ??
            'Order submission failed (HTTP ${response.statusCode}).';
        throw Exception(message);
      }

      if (mounted) {
        Navigator.pop(
          context,
          (decoded['message'] ?? 'Your order was submitted successfully.')
              .toString(),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to submit order: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paleBlue,
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: const Text('Complete Your Purchase'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOrderPanel(),
              const SizedBox(height: 14),
              _buildDetailsPanel(),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed:
                    _isSending || _submissionUnconfirmed ? null : _reviewOrder,
                icon: _isSending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  _isSending
                      ? 'SENDING RECEIPT...'
                      : _submissionUnconfirmed
                          ? 'CHECK EMAIL BEFORE RETRYING'
                          : 'REVIEW ORDER',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _brightTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              if (_submissionUnconfirmed) ...[
                const SizedBox(height: 8),
                const Text(
                  'We could not read the server confirmation. Check your inbox or contact enquiry@bluedale.com.my before submitting again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'For purchases outside Malaysia, please email enquiry@bluedale.com.my.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle('YOUR ORDER', Icons.shopping_cart_outlined),
          const SizedBox(height: 12),
          for (final item in widget.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item.imageUrl,
                      width: 54,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 54,
                        height: 76,
                        child: Icon(Icons.menu_book_outlined, color: _teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: const TextStyle(
                                color: _teal, fontWeight: FontWeight.w800)),
                        Text('Quantity: ${item.quantity}',
                            style: const TextStyle(fontSize: 12)),
                        Text(
                          _hasValidPostcode
                              ? '$_regionLabel: ${_money(_unitPrice(item))} each · ${_money(_unitPrice(item) * item.quantity)}'
                              : 'Peninsular ${_money(item.category == 'OtherBooks' ? 159.90 : 17.90)} · East Malaysia ${_money(item.category == 'OtherBooks' ? 179.90 : 22.90)}',
                          style: const TextStyle(
                              color: _brightTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          const SizedBox(height: 12),
          _bankDetails(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              Text(
                _hasValidPostcode ? _money(_total) : 'Enter postcode',
                style: const TextStyle(
                    color: _brightTeal,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() => _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panelTitle('YOUR DETAILS', Icons.person_outline),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              decoration: _decoration(
                  'Full name *', Icons.person_outline, 'Enter your full name'),
              validator: _required,
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoration(
                  'Email *', Icons.email_outlined, 'you@example.com'),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                  'Phone number *', Icons.phone_outlined, '+60 12 345 6789'),
              validator: _required,
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: _decoration('Delivery address *',
                  Icons.location_on_outlined, 'Full delivery address'),
              validator: _required,
            ),
            const SizedBox(height: 11),
            DropdownButtonFormField<String>(
              initialValue: _state,
              decoration: _decoration(
                  'State *', Icons.map_outlined, 'Select your state'),
              items: _states
                  .map((state) => DropdownMenuItem(
                        value: state,
                        child: Text(state),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _state = value),
              validator: (value) => value == null ? 'Select your state' : null,
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _postcodeController,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: _decoration(
                      'Postcode *', Icons.markunread_mailbox_outlined, '81300')
                  .copyWith(counterText: ''),
              validator: (value) =>
                  RegExp(r'^\d{5}$').hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Enter a valid 5-digit postcode',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isSending ? null : _pickReceipt,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(_receipt?.name ?? 'Upload payment receipt *'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 5),
            const Text('JPG, PNG, or PDF · maximum 5 MB',
                style: TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      );

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _teal.withValues(alpha: 0.12)),
        ),
        child: child,
      );

  Widget _panelTitle(String title, IconData icon) => Row(
        children: [
          Icon(icon, color: _brightTeal, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: _teal, fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      );

  Widget _bankDetails() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _paleBlue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PAYMENT BY BANK TRANSFER',
                style: TextStyle(
                    color: _teal, fontWeight: FontWeight.w900, fontSize: 12)),
            SizedBox(height: 6),
            Text('Bank: Alliance Bank Malaysia Berhad'),
            Text('Account name: Bluedale Publishing (M) Sdn Bhd'),
            Text('Account number: 1218-10-010008-350'),
          ],
        ),
      );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}
