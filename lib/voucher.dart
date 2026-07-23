import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/url_service.dart';
import 'package:kltheguide/widgets/state_views.dart';
import 'generated/l10n.dart';

// Model class for Voucher Data
class VoucherData {
  final String voucher;
  final String title;
  final String image;
  final String expiryDate;

  VoucherData({
    required this.voucher,
    required this.title,
    required this.image,
    required this.expiryDate,
  });

  factory VoucherData.fromJson(Map<String, dynamic> json) {
    return VoucherData(
      voucher: json['voucher'] ?? '',
      title: json['voucher_title'] ?? '',
      image: json['voucher_image'] ?? '',
      expiryDate: json['voucher_expiry_date'] ?? '',
    );
  }
}

// Function to fetch data from the API
Future<List<VoucherData>> fetchVouchers() async {
  final response = await http.post(
    Uri.parse('https://www.kltheguide.com.my/admin/functions.php'),
    body: {'fetch_vouchers': 'true'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => VoucherData.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load vouchers');
  }
}

// Widget to display voucher data in a card format
class VoucherCardList extends StatelessWidget {
  final List<VoucherData> data;
  final HomePalette palette;

  const VoucherCardList({super.key, required this.data, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: palette.accent,
              boxShadow: [
                BoxShadow(
                  color: palette.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: VoucherPatternPainter(),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Voucher image with special styling
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl:
                                    item.image.isNotEmpty ? item.image : '',
                                fit: BoxFit.cover,
                                height: 180,
                                width: double.infinity,
                                memCacheHeight: 540,
                                errorWidget: (context, url, error) =>
                                    Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, size: 50),
                                ),
                                placeholder: (context, url) => Container(
                                  height: 180,
                                  color: palette.card,
                                  child: Center(
                                    child: CircularProgressIndicator(color: palette.accent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Special offer badge
                          Positioned(
                            top: 24,
                            right: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF8E53),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.local_offer,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'SPECIAL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Content section
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Voucher code section
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.voucher,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Expiry date
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Expires: ${item.expiryDate}",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Claim button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  UrlService.launchURL(
                                      'https://docs.google.com/forms/d/e/1FAIpQLScg1O4jn8bJk8B2Rr5rYQIUNkEI0K8Abz2ann19HYG6_GSUMA/viewform?usp=sharing');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: palette.card,
                                  foregroundColor: palette.accent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Claim Voucher',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for voucher pattern background
class VoucherPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw diagonal lines pattern
    for (double i = -size.height; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Main widget to display the vouchers
class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  _VoucherScreenState createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  late Future<List<VoucherData>> _data = fetchVouchers();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _data = fetchVouchers();
    _data.then((_) {}).catchError((error) {
      // Intentionally swallowed: the FutureBuilder in build() observes this
      // same _data future independently and already renders an ErrorStateView
      // via snapshot.hasError. This handler only exists so a fetch failure
      // doesn't surface as an unhandled zone error; it must not navigate —
      // this screen can be a pushed route (from the voucher popup) or a
      // bottom-nav tab body, and popping either on a transient network blip
      // silently booted the user out instead of showing the retry screen.
    });
  }

  void _retry() {
    setState(() {
      _fetchData();
    });
  }

  Future<void> _onRefresh() async {
    _retry();
    try {
      await _data;
    } catch (_) {
      // The FutureBuilder below renders the error state; this only needs
      // to complete so RefreshIndicator dismisses its spinner.
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).vouchers,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Exclusive deals and discounts for you',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VoucherData>>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: palette.accent),
                        const SizedBox(height: 16),
                        Text(
                          'Loading vouchers...',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return ErrorStateView(
                    message: 'Could not load vouchers.\nCheck your connection and try again.',
                    onRetry: _retry,
                  );
                } else if (snapshot.hasData) {
                  final newData = snapshot.data ?? [];
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: palette.accent,
                    child: VoucherCardList(data: newData, palette: palette),
                  );
                } else {
                  return ErrorStateView(
                    message: 'Could not load vouchers.\nCheck your connection and try again.',
                    onRetry: _retry,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
